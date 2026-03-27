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

Describe 'Set-TlsProtocolRegistryValue' -Tag 'Private' {
    Context 'When enabling a single protocol for Server' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
        }

        It 'Should call New-Item and New-ItemProperty with correct values' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $null = Set-TlsProtocolRegistryValue -Protocol ([SChannelSslProtocols]::Tls12) -Enable -Force
            }

            Should -Invoke -CommandName New-Item -ParameterFilter { $Path -like '*\TLS 1.2\Server' } -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'Enabled' -and $Value -eq 1 } -Exactly -Times 1 -Scope It
        }
    }

    Context 'When enabling a single protocol for Client' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
        }

        It 'Should target the Client registry path' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $null = Set-TlsProtocolRegistryValue -Protocol ([SChannelSslProtocols]::Tls12) -Enable -Client -Force
            }

            Should -Invoke -CommandName New-Item -ParameterFilter { $Path -like '*\TLS 1.2\Client' } -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'Enabled' -and $Value -eq 1 } -Exactly -Times 1 -Scope It
        }
    }

    Context 'When enabling a protocol with SetDisabledByDefault' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
        }

        It 'Should set DisabledByDefault to 0' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $null = Set-TlsProtocolRegistryValue -Protocol ([SChannelSslProtocols]::Tls12) -Enable -SetDisabledByDefault -Force
            }

            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'DisabledByDefault' -and $Value -eq 0 } -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'Enabled' -and $Value -eq 1 } -Exactly -Times 1 -Scope It
        }
    }

    Context 'When enabling without SetDisabledByDefault' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
        }

        It 'Should not set DisabledByDefault' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $null = Set-TlsProtocolRegistryValue -Protocol ([SChannelSslProtocols]::Tls12) -Enable -Force
            }

            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'DisabledByDefault' } -Exactly -Times 0 -Scope It
        }
    }

    Context 'When disabling a single protocol for Server' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
        }

        It 'Should call New-Item and New-ItemProperty with correct values' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $null = Set-TlsProtocolRegistryValue -Protocol ([SChannelSslProtocols]::Ssl3) -Disable -Force
            }

            Should -Invoke -CommandName New-Item -ParameterFilter { $Path -like '*\SSL 3.0\Server' } -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'Enabled' -and $Value -eq 0 } -Exactly -Times 1 -Scope It
        }
    }

    Context 'When disabling a single protocol for Client' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
        }

        It 'Should target the Client registry path' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $null = Set-TlsProtocolRegistryValue -Protocol ([SChannelSslProtocols]::Ssl3) -Disable -Client -Force
            }

            Should -Invoke -CommandName New-Item -ParameterFilter { $Path -like '*\SSL 3.0\Client' } -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'Enabled' -and $Value -eq 0 } -Exactly -Times 1 -Scope It
        }
    }

    Context 'When disabling a protocol with SetDisabledByDefault' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
        }

        It 'Should set DisabledByDefault to 1' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $null = Set-TlsProtocolRegistryValue -Protocol ([SChannelSslProtocols]::Ssl3) -Disable -SetDisabledByDefault -Force
            }

            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'DisabledByDefault' -and $Value -eq 1 } -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'Enabled' -and $Value -eq 0 } -Exactly -Times 1 -Scope It
        }
    }

    Context 'When disabling without SetDisabledByDefault' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
        }

        It 'Should not set DisabledByDefault' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $null = Set-TlsProtocolRegistryValue -Protocol ([SChannelSslProtocols]::Ssl3) -Disable -Force
            }

            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'DisabledByDefault' } -Exactly -Times 0 -Scope It
        }
    }

    Context 'When enabling multiple protocols' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
        }

        It 'Should process each protocol' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $null = Set-TlsProtocolRegistryValue -Protocol @(
                    [SChannelSslProtocols]::Tls12,
                    [SChannelSslProtocols]::Tls13
                ) -Enable -Force
            }

            Should -Invoke -CommandName New-Item -Exactly -Times 2 -Scope It
            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'Enabled' -and $Value -eq 1 } -Exactly -Times 2 -Scope It
        }
    }

    Context 'When disabling multiple protocols' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
        }

        It 'Should process each protocol' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $null = Set-TlsProtocolRegistryValue -Protocol @(
                    [SChannelSslProtocols]::Ssl2,
                    [SChannelSslProtocols]::Ssl3
                ) -Disable -Force
            }

            Should -Invoke -CommandName New-Item -Exactly -Times 2 -Scope It
            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'Enabled' -and $Value -eq 0 } -Exactly -Times 2 -Scope It
        }
    }

    Context 'When New-Item fails to create the registry key' {
        BeforeAll {
            Mock -CommandName New-Item -MockWith { throw 'Failed to create registry key' }
            Mock -CommandName New-ItemProperty
        }

        It 'Should throw a terminating error with error id STPRV0001 when enabling' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { Set-TlsProtocolRegistryValue -Protocol ([SChannelSslProtocols]::Tls12) -Enable -Force } | Should -Throw -ErrorId 'STPRV0001,Set-TlsProtocolRegistryValue'
            }
        }

        It 'Should throw a terminating error with error id STPRV0002 when disabling' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { Set-TlsProtocolRegistryValue -Protocol ([SChannelSslProtocols]::Tls12) -Disable -Force } | Should -Throw -ErrorId 'STPRV0002,Set-TlsProtocolRegistryValue'
            }
        }
    }

    Context 'When New-ItemProperty fails to set the registry value' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty -MockWith { throw 'Failed to set registry value' }
        }

        It 'Should throw a terminating error with error id STPRV0001 when enabling' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { Set-TlsProtocolRegistryValue -Protocol ([SChannelSslProtocols]::Tls12) -Enable -Force } | Should -Throw -ErrorId 'STPRV0001,Set-TlsProtocolRegistryValue'
            }
        }

        It 'Should throw a terminating error with error id STPRV0002 when disabling' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { Set-TlsProtocolRegistryValue -Protocol ([SChannelSslProtocols]::Tls12) -Disable -Force } | Should -Throw -ErrorId 'STPRV0002,Set-TlsProtocolRegistryValue'
            }
        }
    }

    Context 'When WhatIf is specified' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
        }

        It 'Should not make any changes' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $null = Set-TlsProtocolRegistryValue -Protocol ([SChannelSslProtocols]::Tls12) -Enable -WhatIf
            }

            Should -Invoke -CommandName New-Item -Exactly -Times 0 -Scope It
            Should -Invoke -CommandName New-ItemProperty -Exactly -Times 0 -Scope It
        }
    }
}
