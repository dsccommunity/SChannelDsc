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

Describe 'Get-TlsProtocol' -Tag 'Public' {
    It 'Should have the correct parameters in parameter set <ExpectedParameterSetName>' -ForEach @(
        @{
            ExpectedParameterSetName = '__AllParameterSets'
            ExpectedParameters       = '[[-Protocol] <SChannelSslProtocols[]>] [-Client] [<CommonParameters>]'
        }
    ) {
        $result = (Get-Command -Name 'Get-TlsProtocol').ParameterSets |
            Where-Object -FilterScript { $_.Name -eq $ExpectedParameterSetName } |
            Select-Object -Property @(
                @{ Name = 'ParameterSetName'; Expression = { $_.Name } },
                @{ Name = 'ParameterListAsString'; Expression = { $_.ToString() } }
            )

        $result.ParameterSetName | Should -Be $ExpectedParameterSetName
        $result.ParameterListAsString | Should -Be $ExpectedParameters
    }

    Context 'When registry has Enabled=1 and DisabledByDefault=0' {
        BeforeAll {
            Mock -CommandName Get-TlsProtocolRegistryPath -MockWith {
                return 'HKLM:\Software\Test\Tls12\Server'
            }

            Mock -CommandName Get-TlsProtocolTargetRegistryName -MockWith {
                return 'Server'
            } -ParameterFilter {
                -not $Client
            }

            Mock -CommandName Get-RegistryPropertyValue -MockWith {
                return 1
            } -ParameterFilter {
                $Path -like '*\Server' -and $Name -eq 'Enabled'
            }

            Mock -CommandName Get-RegistryPropertyValue -MockWith {
                return 0
            } -ParameterFilter {
                $Path -like '*\Server' -and $Name -eq 'DisabledByDefault'
            }
        }

        It 'Should return object with expected properties and values' {
            $result = Get-TlsProtocol -Protocol Tls12

            $result | Should -Not -BeNull
            $result.Protocol | Should -Be 'Tls12'
            $result.Target | Should -Be 'Server'
            $result.Enabled | Should -Be 1
            $result.DisabledByDefault | Should -Be 0
            $result.RegistryPath | Should -Be 'HKLM:\Software\Test\Tls12\Server'
        }
    }

    Context 'When protocol key is missing' {
        BeforeAll {
            Mock -CommandName Get-TlsProtocolRegistryPath -MockWith {
                return 'HKLM:\Software\Test\Tls12\Server'
            }

            Mock -CommandName Get-TlsProtocolTargetRegistryName
            Mock -CommandName Get-RegistryPropertyValue
        }

        It 'Should return null for Enabled and DisabledByDefault' {
            $result = Get-TlsProtocol -Protocol Tls12

            $result.Enabled | Should -BeNull
            $result.DisabledByDefault | Should -BeNull
        }
    }

    Context 'When registry returns string values that are numeric' {
        BeforeAll {
            Mock -CommandName Get-TlsProtocolRegistryPath -MockWith {
                return 'HKLM:\Software\Test\Tls12\Server'
            }

            Mock -CommandName Get-TlsProtocolTargetRegistryName -MockWith {
                return 'Server'
            } -ParameterFilter {
                -not $Client
            }

            Mock -CommandName Get-RegistryPropertyValue -MockWith {
                return '1'
            } -ParameterFilter {
                $Path -like '*\Server' -and $Name -eq 'Enabled'
            }

            Mock -CommandName Get-RegistryPropertyValue -MockWith {
                return '0'
            } -ParameterFilter {
                $Path -like '*\Server' -and $Name -eq 'DisabledByDefault'
            }
        }

        It 'Should cast string numeric values to integer types' {
            $result = Get-TlsProtocol -Protocol Tls12

            $result.Enabled | Should -Be 1
            $result.Enabled | Should -BeOfType 'System.UInt32'
            $result.DisabledByDefault | Should -Be 0
            $result.DisabledByDefault | Should -BeOfType 'System.UInt32'
        }
    }

    Context 'When using the Client switch' {
        BeforeAll {
            Mock -CommandName Get-TlsProtocolRegistryPath -MockWith {
                return 'HKLM:\Software\Test\Tls12\Client'
            }

            Mock -CommandName Get-TlsProtocolTargetRegistryName -MockWith {
                return 'Client'
            } -ParameterFilter {
                $Client
            }

            Mock -CommandName Get-RegistryPropertyValue -MockWith {
                return 1
            } -ParameterFilter {
                $Path -like '*\Client' -and $Name -eq 'Enabled'
            }

            Mock -CommandName Get-RegistryPropertyValue -MockWith {
                return 0
            } -ParameterFilter {
                $Path -like '*\Client' -and $Name -eq 'DisabledByDefault'
            }
        }

        It 'Should check Client registry keys and return Client target' {
            $result = Get-TlsProtocol -Protocol Tls12 -Client

            $result.Target | Should -Be 'Client'
            $result.Enabled | Should -Be 1
            $result.DisabledByDefault | Should -Be 0

            Should -Invoke -CommandName Get-TlsProtocolRegistryPath -ParameterFilter {
                $Protocol -eq 'Tls12' -and $Client
            } -Exactly -Times 1 -Scope It

            Should -Invoke -CommandName Get-TlsProtocolTargetRegistryName -ParameterFilter {
                $Client
            } -Exactly -Times 1 -Scope It
        }
    }

    Context 'When Protocol parameter is omitted' {
        BeforeAll {
            # Return a predictable registry path for any protocol
            Mock -CommandName Get-TlsProtocolRegistryPath -MockWith {
                return "HKLM:\Software\Test\$Protocol\Server"
            }

            Mock -CommandName Get-TlsProtocolTargetRegistryName -MockWith {
                return 'Server'
            } -ParameterFilter {
                -not $Client
            }

            Mock -CommandName Get-RegistryPropertyValue -MockWith {
                return 1
            } -ParameterFilter {
                $Name -eq 'Enabled'
            }

            Mock -CommandName Get-RegistryPropertyValue -MockWith {
                return 0
            } -ParameterFilter {
                $Name -eq 'DisabledByDefault'
            }
        }

        It 'Should return entries for all supported protocols' {
            $result = Get-TlsProtocol

            $result | Should -Not -BeNull
            $result.Count | Should -Be 8
            $result.Target | Should -Not -Contain $null
        }
    }

    Context 'When validating parameters' {
        BeforeAll {
            $commandInfo = Get-Command -Name 'Get-TlsProtocol'
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
    }
}
