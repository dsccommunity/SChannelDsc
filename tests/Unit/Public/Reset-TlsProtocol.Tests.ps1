[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Suppressing this rule because Script Analyzer does not understand Pester syntax.')]
param ()

BeforeDiscovery {
    try
    {
        if (-not (Get-Module -Name 'DscResource.Test'))
        {
            if (-not (Get-Module -Name 'DscResource.Test' -ListAvailable))
            {
                & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 3>&1 4>&1 5>&1 6>&1 > $null
            }

            Import-Module -Name 'DscResource.Test' -Force -ErrorAction 'Stop'
        }
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks build" first.'
    }
}

BeforeAll {
    $script:moduleName = 'SChannelDsc'

    Import-Module -Name $script:moduleName -ErrorAction 'Stop'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:moduleName -All | Remove-Module -Force
}

Describe 'Reset-TlsProtocol' -Tag 'Public' {
    It 'Should have the correct parameters in parameter set <ExpectedParameterSetName>' -ForEach @(
        @{
            ExpectedParameterSetName = '__AllParameterSets'
            ExpectedParameters       = '[[-Protocol] <SChannelSslProtocols[]>] [-Client] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]'
        }
    ) {
        $result = (Get-Command -Name 'Reset-TlsProtocol').ParameterSets |
            Where-Object -FilterScript { $_.Name -eq $ExpectedParameterSetName } |
            Select-Object -Property @(
                @{ Name = 'ParameterSetName'; Expression = { $_.Name } },
                @{ Name = 'ParameterListAsString'; Expression = { $_.ToString() } }
            )

        $result.ParameterSetName | Should -Be $ExpectedParameterSetName
        $result.ParameterListAsString | Should -Be $ExpectedParameters
    }

    Context 'When resetting a protocol and registry key exists' {
        BeforeAll {
            Mock -CommandName ConvertTo-TlsProtocolRegistryKeyName -MockWith { return 'SSL 3.0' }
            Mock -CommandName Get-TlsProtocolTargetRegistryName -MockWith { return 'Server' }
            Mock -CommandName Get-TlsProtocolRegistryPath -MockWith {
                return 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server'
            }
            Mock -CommandName Test-Path -MockWith { return $true }
            Mock -CommandName Get-ChildItem -MockWith {
                # Return a child item to simulate that Client key still exists
                return @([PSCustomObject] @{ Name = 'Client' })
            }
            Mock -CommandName Remove-Item
        }

        It 'Should call Remove-Item to remove registry key' {
            $null = Reset-TlsProtocol -Protocol Ssl3 -Force

            Should -Invoke -CommandName ConvertTo-TlsProtocolRegistryKeyName -ParameterFilter {
                $Protocol -eq 'Ssl3'
            } -Exactly -Times 1 -Scope It

            Should -Invoke -CommandName Get-TlsProtocolTargetRegistryName -ParameterFilter {
                $Client -eq $false
            } -Exactly -Times 1 -Scope It

            Should -Invoke -CommandName Get-TlsProtocolRegistryPath -ParameterFilter {
                $Protocol -eq 'Ssl3' -and
                $Client -eq $false
            } -Exactly -Times 1 -Scope It

            Should -Invoke -CommandName Test-Path -Exactly -Times 2 -Scope It
            Should -Invoke -CommandName Remove-Item -Exactly -Times 1 -Scope It
        }
    }

    Context 'When Remove-Item fails' {
        BeforeAll {
            Mock -CommandName ConvertTo-TlsProtocolRegistryKeyName -MockWith { return 'TLS 1.2' }
            Mock -CommandName Get-TlsProtocolTargetRegistryName -MockWith { return 'Server' }
            Mock -CommandName Get-TlsProtocolRegistryPath -MockWith {
                return 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server'
            }
            Mock -CommandName Test-Path -MockWith { return $true }
            Mock -CommandName Remove-Item -MockWith {
                throw 'Access denied'
            }
        }

        It 'Should throw a terminating error with error ID RTP0001' {
            $mockErrorMessage = InModuleScope -ScriptBlock {
                $script:localizedData.Reset_TlsProtocol_FailedToReset
            }

            { Reset-TlsProtocol -Protocol Tls12 -Force } |
                Should -Throw -ExpectedMessage ($mockErrorMessage -f 'Tls12') -ErrorId 'RTP0001*'
        }
    }

    Context 'When resetting a protocol and registry key does not exist' {
        BeforeAll {
            Mock -CommandName ConvertTo-TlsProtocolRegistryKeyName -MockWith { return 'TLS 1.2' }
            Mock -CommandName Get-TlsProtocolTargetRegistryName -MockWith { return 'Server' }
            Mock -CommandName Get-TlsProtocolRegistryPath -MockWith {
                return 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server'
            }
            Mock -CommandName Test-Path -MockWith { return $false }
            Mock -CommandName Remove-Item
        }

        It 'Should not call Remove-Item when registry key does not exist' {
            $null = Reset-TlsProtocol -Protocol Tls12 -Force

            Should -Invoke -CommandName Test-Path -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Remove-Item -Exactly -Times 0 -Scope It
        }
    }

    Context 'When resetting a protocol for Client' {
        BeforeAll {
            Mock -CommandName ConvertTo-TlsProtocolRegistryKeyName -MockWith { return 'TLS 1.2' }
            Mock -CommandName Get-TlsProtocolTargetRegistryName -MockWith { return 'Client' }
            Mock -CommandName Get-TlsProtocolRegistryPath -MockWith {
                return 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'
            }
            Mock -CommandName Test-Path -MockWith { return $true }
            Mock -CommandName Get-ChildItem -MockWith {
                # Return a child item to simulate that Server key still exists
                return @([PSCustomObject] @{ Name = 'Server' })
            }
            Mock -CommandName Remove-Item
        }

        It 'Should pass Client to helper functions' {
            $null = Reset-TlsProtocol -Protocol Tls12 -Client -Force

            Should -Invoke -CommandName Get-TlsProtocolTargetRegistryName -ParameterFilter {
                $Client -eq $true
            } -Exactly -Times 1 -Scope It

            Should -Invoke -CommandName Get-TlsProtocolRegistryPath -ParameterFilter {
                $Client -eq $true
            } -Exactly -Times 1 -Scope It

            Should -Invoke -CommandName Remove-Item -Exactly -Times 1 -Scope It
        }
    }

    Context 'When resetting multiple protocols' {
        BeforeAll {
            Mock -CommandName ConvertTo-TlsProtocolRegistryKeyName -MockWith { return 'MockProtocol' }
            Mock -CommandName Get-TlsProtocolTargetRegistryName -MockWith { return 'Server' }
            Mock -CommandName Get-TlsProtocolRegistryPath -MockWith { return 'HKLM:\MockPath' }
            Mock -CommandName Test-Path -MockWith { return $true }
            Mock -CommandName Get-ChildItem -MockWith {
                # Return a child item to simulate that sibling key still exists
                return @([PSCustomObject] @{ Name = 'MockChild' })
            }
            Mock -CommandName Remove-Item
        }

        It 'Should call Remove-Item for each protocol' {
            $null = Reset-TlsProtocol -Protocol @(
                'Ssl2',
                'Ssl3'
            ) -Force

            Should -Invoke -CommandName Remove-Item -Exactly -Times 2 -Scope It
        }
    }

    Context 'When no Protocol is specified' {
        BeforeAll {
            Mock -CommandName Get-TlsProtocol -MockWith {
                return @(
                    [PSCustomObject] @{ Protocol = 'Tls12' },
                    [PSCustomObject] @{ Protocol = 'Tls13' }
                )
            }
            Mock -CommandName ConvertTo-TlsProtocolRegistryKeyName -MockWith { return 'MockProtocol' }
            Mock -CommandName Get-TlsProtocolTargetRegistryName -MockWith { return 'Server' }
            Mock -CommandName Get-TlsProtocolRegistryPath -MockWith { return 'HKLM:\MockPath' }
            Mock -CommandName Test-Path -MockWith { return $true }
            Mock -CommandName Get-ChildItem -MockWith {
                # Return a child item to simulate that sibling key still exists
                return @([PSCustomObject] @{ Name = 'MockChild' })
            }
            Mock -CommandName Remove-Item
        }

        It 'Should call Get-TlsProtocol to get all supported protocols' {
            $null = Reset-TlsProtocol -Force

            Should -Invoke -CommandName Get-TlsProtocol -ParameterFilter {
                $Client -eq $false
            } -Exactly -Times 1 -Scope It

            Should -Invoke -CommandName Remove-Item -Exactly -Times 2 -Scope It
        }

        It 'Should pass Client switch to Get-TlsProtocol when specified' {
            $null = Reset-TlsProtocol -Client -Force

            Should -Invoke -CommandName Get-TlsProtocol -ParameterFilter {
                $Client -eq $true
            } -Exactly -Times 1 -Scope It
        }
    }

    Context 'When resetting a protocol removal should preserve root registry path' -Skip:(-not ($PSVersionTable.PSEdition -eq 'Desktop' -or $IsWindows)) {
        BeforeAll {
            # Create the parent Protocols key
            $null = New-Item -Path 'TestRegistry:\SCHANNEL\Protocols' -Force

            # Create TLS 1.2 Server with Enabled and DisabledByDefault properties
            $null = New-Item -Path 'TestRegistry:\SCHANNEL\Protocols\TLS 1.2\Server' -Force
            $null = New-ItemProperty -Path 'TestRegistry:\SCHANNEL\Protocols\TLS 1.2\Server' -Name 'Enabled' -Value 1 -Force
            $null = New-ItemProperty -Path 'TestRegistry:\SCHANNEL\Protocols\TLS 1.2\Server' -Name 'DisabledByDefault' -Value 0 -Force

            # Create TLS 1.2 Client with Enabled and DisabledByDefault properties
            $null = New-Item -Path 'TestRegistry:\SCHANNEL\Protocols\TLS 1.2\Client' -Force
            $null = New-ItemProperty -Path 'TestRegistry:\SCHANNEL\Protocols\TLS 1.2\Client' -Name 'Enabled' -Value 1 -Force
            $null = New-ItemProperty -Path 'TestRegistry:\SCHANNEL\Protocols\TLS 1.2\Client' -Name 'DisabledByDefault' -Value 0 -Force

            # Create TLS 1.3 Server with Enabled property
            $null = New-Item -Path 'TestRegistry:\SCHANNEL\Protocols\TLS 1.3\Server' -Force
            $null = New-ItemProperty -Path 'TestRegistry:\SCHANNEL\Protocols\TLS 1.3\Server' -Name 'Enabled' -Value 1 -Force

            # Mock Get-TlsProtocolRegistryPath to return TestRegistry path for TLS 1.2 Server
            Mock -CommandName Get-TlsProtocolRegistryPath -ParameterFilter {
                $Protocol -eq 'Tls12' -and -not $Client
            } -MockWith {
                return 'TestRegistry:\SCHANNEL\Protocols\TLS 1.2\Server'
            }

            # Mock Get-TlsProtocolRegistryPath to return TestRegistry path for TLS 1.2 Client
            Mock -CommandName Get-TlsProtocolRegistryPath -ParameterFilter {
                $Protocol -eq 'Tls12' -and $Client
            } -MockWith {
                return 'TestRegistry:\SCHANNEL\Protocols\TLS 1.2\Client'
            }

            # Mock Get-TlsProtocolRegistryPath to return TestRegistry path for TLS 1.3 Server
            Mock -CommandName Get-TlsProtocolRegistryPath -ParameterFilter {
                $Protocol -eq 'Tls13' -and -not $Client
            } -MockWith {
                return 'TestRegistry:\SCHANNEL\Protocols\TLS 1.3\Server'
            }

            # Mock Get-TlsProtocolRegistryPath to return TestRegistry path for TLS 1.3 Client
            Mock -CommandName Get-TlsProtocolRegistryPath -ParameterFilter {
                $Protocol -eq 'Tls13' -and $Client
            } -MockWith {
                return 'TestRegistry:\SCHANNEL\Protocols\TLS 1.3\Client'
            }
        }

        It 'Should remove only the Server key and preserve the Client key' {
            $null = Reset-TlsProtocol -Protocol Tls12 -Force

            # Server key should be removed
            Test-Path -Path 'TestRegistry:\SCHANNEL\Protocols\TLS 1.2\Server' | Should -BeFalse

            # Client key should still exist
            Test-Path -Path 'TestRegistry:\SCHANNEL\Protocols\TLS 1.2\Client' | Should -BeTrue

            # Client properties should still exist
            Get-ItemPropertyValue -Path 'TestRegistry:\SCHANNEL\Protocols\TLS 1.2\Client' -Name 'Enabled' | Should -Be 1

            # Parent Protocols key should still exist
            Test-Path -Path 'TestRegistry:\SCHANNEL\Protocols' | Should -BeTrue

            # TLS 1.2 parent key should still exist (because Client is still there)
            Test-Path -Path 'TestRegistry:\SCHANNEL\Protocols\TLS 1.2' | Should -BeTrue
        }

        It 'Should remove only the Client key and preserve the Server key' {
            $null = Reset-TlsProtocol -Protocol Tls13 -Client -Force

            # Since TLS 1.3 Client does not exist, nothing should be removed
            # TLS 1.3 Server key should still exist
            Test-Path -Path 'TestRegistry:\SCHANNEL\Protocols\TLS 1.3\Server' | Should -BeTrue

            Get-ItemPropertyValue -Path 'TestRegistry:\SCHANNEL\Protocols\TLS 1.3\Server' -Name 'Enabled' | Should -Be 1
        }

        It 'Should preserve other protocol keys when resetting a specific protocol' {
            $null = Reset-TlsProtocol -Protocol Tls13 -Force

            # TLS 1.3 Server should be removed
            Test-Path -Path 'TestRegistry:\SCHANNEL\Protocols\TLS 1.3\Server' | Should -BeFalse
            Test-Path -Path 'TestRegistry:\SCHANNEL\Protocols\TLS 1.3' | Should -BeFalse

            # TLS 1.2 Client should still exist (from first test we removed Server, but Client remains)
            Test-Path -Path 'TestRegistry:\SCHANNEL\Protocols\TLS 1.2\Client' | Should -BeTrue

            # Parent Protocols key should still exist
            Test-Path -Path 'TestRegistry:\SCHANNEL\Protocols' | Should -BeTrue
        }
    }

    Context 'When validating parameters' {
        BeforeAll {
            $commandInfo = Get-Command -Name 'Reset-TlsProtocol'
        }

        It 'Should have Protocol as a non-mandatory parameter' {
            $parameterInfo = $commandInfo.Parameters['Protocol']

            $parameterInfo.Attributes.Mandatory | Should -BeFalse
        }

        It 'Should have Protocol declared as an array type' {
            $parameterInfo = $commandInfo.Parameters['Protocol']

            $parameterInfo.ParameterType.IsArray | Should -BeTrue
        }

        It 'Should have Client as a non-mandatory parameter' {
            $parameterInfo = $commandInfo.Parameters['Client']

            $parameterInfo.Attributes.Mandatory | Should -BeFalse
        }

        It 'Should have Client defined as a switch parameter' {
            $parameterInfo = $commandInfo.Parameters['Client']

            $parameterInfo.ParameterType.Name | Should -Be 'SwitchParameter'
        }

        It 'Should have Force defined as a switch parameter' {
            $parameterInfo = $commandInfo.Parameters['Force']

            $parameterInfo.ParameterType.Name | Should -Be 'SwitchParameter'
        }
    }
}
