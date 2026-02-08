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

Describe 'Test-TlsProtocol' -Tag 'Public' {
    It 'Should have the correct parameters in parameter set <ExpectedParameterSetName>' -ForEach @(
        @{
            ExpectedParameterSetName = '__AllParameterSets'
            ExpectedParameters       = '[-Protocol] <SChannelSslProtocols[]> [-Client] [-Disabled] [<CommonParameters>]'
        }
    ) {
        $result = (Get-Command -Name 'Test-TlsProtocol').ParameterSets |
            Where-Object -FilterScript { $_.Name -eq $ExpectedParameterSetName } |
            Select-Object -Property @(
                @{ Name = 'ParameterSetName'; Expression = { $_.Name } },
                @{ Name = 'ParameterListAsString'; Expression = { $_.ToString() } }
            )

        $result.ParameterSetName | Should -Be $ExpectedParameterSetName
        $result.ParameterListAsString | Should -Be $ExpectedParameters
    }

    Context 'When protocol is enabled in registry' {
        BeforeAll {
            Mock -CommandName Get-RegistryPropertyValue -MockWith {
                return 1
            } -ParameterFilter { $Path -like '*\Server' -and $Name -eq 'Enabled' }

            Mock -CommandName Get-RegistryPropertyValue -MockWith {
                return 0
            } -ParameterFilter { $Path -like '*\Server' -and $Name -eq 'DisabledByDefault' }
        }

        It 'Should return $true' {
            $result = Test-TlsProtocol -Protocol Tls12

            $result | Should -BeTrue
        }
    }

    Context 'When protocol key is missing' {
        BeforeAll {
            Mock -CommandName Get-RegistryPropertyValue
        }

        It 'Should return $true' {
            $result = Test-TlsProtocol -Protocol Tls12

            $result | Should -BeTrue
        }
    }

    Context 'When DisabledByDefault is set to 1' {
        BeforeAll {
            Mock -CommandName Get-RegistryPropertyValue -MockWith {
                return 1
            } -ParameterFilter { $Path -like '*\Server' -and $Name -eq 'Enabled' }

            Mock -CommandName Get-RegistryPropertyValue -MockWith {
                return 1
            } -ParameterFilter { $Path -like '*\Server' -and $Name -eq 'DisabledByDefault' }
        }

        It 'Should return false' {
            $result = Test-TlsProtocol -Protocol Tls12

            $result | Should -BeFalse
        }
    }

    Context 'When using the Client switch' {
        BeforeAll {
            Mock -CommandName Get-RegistryPropertyValue -MockWith {
                return 1
            } -ParameterFilter { $Path -like '*\Client' -and $Name -eq 'Enabled' }

            Mock -CommandName Get-RegistryPropertyValue -MockWith {
                return 0
            } -ParameterFilter { $Path -like '*\Client' -and $Name -eq 'DisabledByDefault' }
        }

        It 'Should check the Client registry key' {
            $result = Test-TlsProtocol -Protocol Tls12 -Client

            $result | Should -BeTrue

            Should -Invoke -CommandName Get-RegistryPropertyValue -ParameterFilter {
                $Path -like '*\Client' -and $Name -eq 'Enabled'
            } -Exactly -Times 1 -Scope It

            Should -Invoke -CommandName Get-RegistryPropertyValue -ParameterFilter {
                $Path -like '*\Client' -and $Name -eq 'DisabledByDefault'
            } -Exactly -Times 1 -Scope It
        }
    }

    Context 'When testing for Disabled protocols' {
        Context 'When protocol is explicitly disabled' {
            BeforeAll {
                Mock -CommandName Get-RegistryPropertyValue -MockWith {
                    return 0
                } -ParameterFilter { $Path -like '*\Server' -and $Name -eq 'Enabled' }

                Mock -CommandName Get-RegistryPropertyValue -MockWith {
                    return 1
                } -ParameterFilter { $Path -like '*\Server' -and $Name -eq 'DisabledByDefault' }
            }

            It 'Should return true' {
                $result = Test-TlsProtocol -Protocol Tls12 -Disabled

                $result | Should -BeTrue
            }
        }

        Context 'When protocol is enabled' {
            BeforeAll {
                Mock -CommandName Get-RegistryPropertyValue -MockWith {
                    return 1
                } -ParameterFilter { $Path -like '*\Server' -and $Name -eq 'Enabled' }

                Mock -CommandName Get-RegistryPropertyValue -MockWith {
                    return 0
                } -ParameterFilter { $Path -like '*\Server' -and $Name -eq 'DisabledByDefault' }
            }

            It 'Should return false' {
                $result = Test-TlsProtocol -Protocol Tls12 -Disabled

                $result | Should -BeFalse
            }
        }

        Context 'When protocol key is missing' {
            BeforeAll {
                Mock -CommandName Get-RegistryPropertyValue
            }

            It 'Should return false' {
                $result = Test-TlsProtocol -Protocol Tls12 -Disabled

                $result | Should -BeFalse
            }
        }
    }

    Context 'When validating parameters' {
        BeforeAll {
            $commandInfo = Get-Command -Name 'Test-TlsProtocol'
        }

        It 'Should have Protocol as a mandatory parameter' {
            $parameterInfo = $commandInfo.Parameters['Protocol']

            $parameterInfo.Attributes.Mandatory | Should -BeTrue
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

        It 'Should have Disabled defined as a switch parameter' {
            $parameterInfo = $commandInfo.Parameters['Disabled']

            $parameterInfo.ParameterType.Name | Should -Be 'SwitchParameter'
        }
    }
}
