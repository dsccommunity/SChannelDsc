<#
    .SYNOPSIS
        Unit test for SChannelProtocolBase DSC resource.
#>

# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

BeforeDiscovery {
    try
    {
        if (-not (Get-Module -Name 'DscResource.Test'))
        {
            # Assumes dependencies has been resolved, so if this module is not available, run 'noop' task.
            if (-not (Get-Module -Name 'DscResource.Test' -ListAvailable))
            {
                # Redirect all streams to $null, except the error stream (stream 2)
                & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 3>&1 4>&1 5>&1 6>&1 > $null
            }

            # If the dependencies has not been resolved, this will throw an error.
            Import-Module -Name 'DscResource.Test' -Force -ErrorAction 'Stop'
        }
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks build" first.'
    }
}

BeforeAll {
    $script:dscModuleName = 'SChannelDsc'

    Import-Module -Name $script:dscModuleName

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe 'SChannelProtocolBase' {
    Context 'When class is instantiated' {
        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { [SChannelProtocolBase]::new() } | Should -Not -Throw
            }
        }

        It 'Should have a default or empty constructor' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [SChannelProtocolBase]::new()
                $instance | Should -Not -BeNullOrEmpty
            }
        }

        It 'Should be the correct type' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [SChannelProtocolBase]::new()
                $instance.GetType().Name | Should -Be 'SChannelProtocolBase'
            }
        }
    }
}

Describe 'SChannelProtocolBase\GetCurrentState()' -Tag 'HiddenMember' {
    Context 'When $ClientSide is $false' {
        Context 'When object is present in the current state' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [SChannelProtocolBase] @{
                        IsSingleInstance   = 'Yes'
                        ProtocolsEnabled   = @(
                            'DTls12'
                            'Tls12'
                            'Tls13'
                        )
                        ProtocolsDisabled  = @(
                            'Ssl2'
                            'Ssl3'
                            'Dtls1'
                            'Tls'
                        )
                        ProtocolsDefault   = @(
                            'Tls11'
                        )
                        RebootWhenRequired = $true
                    }

                    Mock -CommandName Get-TlsProtocol -MockWith {
                        @(
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Ssl2
                                Enabled  = 0
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Ssl3
                                Enabled  = 0
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Dtls1
                                Enabled  = 0
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Dtls12
                                Enabled  = 1
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Tls
                                Enabled  = 0
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Tls11
                                Enabled  = $null
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Tls12
                                Enabled  = 1
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Tls13
                                Enabled  = 1
                            }
                        )
                    } -ParameterFilter { $Client -eq $false }
                }
            }

            It 'Should return the correct values' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $currentState = $script:mockInstance.GetCurrentState(
                        @{
                            IsSingleInstance = 'Yes'
                        }
                    )

                    $currentState.ProtocolsEnabled | Should -Be $script:mockInstance.ProtocolsEnabled
                    # $currentState.ProtocolsEnabled | Should -BeOfType System.Array

                    $currentState.ProtocolsDisabled | Should -Be $script:mockInstance.ProtocolsDisabled
                    # $currentState.ProtocolsDisabled | Should -BeOfType System.Array

                    $currentState.ProtocolsDefault | Should -Be $script:mockInstance.ProtocolsDefault
                    # $currentState.ProtocolsDefault | Should -BeOfType System.Array
                }

                Should -Invoke -CommandName Get-TlsProtocol -ParameterFilter {
                    $Client -eq $false
                } -Exactly -Times 1 -Scope It
            }
        }

        Context 'When one of the protocols is empty' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [SChannelProtocolBase] @{
                        IsSingleInstance   = 'Yes'
                        ProtocolsEnabled   = @(
                            [SChannelSslProtocols]::DTls12
                            [SChannelSslProtocols]::Tls12
                            [SChannelSslProtocols]::Tls13
                        )
                        ProtocolsDisabled  = @(
                            [SChannelSslProtocols]::Ssl2
                            [SChannelSslProtocols]::Ssl3
                            [SChannelSslProtocols]::Dtls1
                            [SChannelSslProtocols]::Tls
                            [SChannelSslProtocols]::Tls11
                        )
                        RebootWhenRequired = $true
                    }

                    Mock -CommandName Get-TlsProtocol -MockWith {
                        @(
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Ssl2
                                Enabled  = 0
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Ssl3
                                Enabled  = 0
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Dtls1
                                Enabled  = 0
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Dtls12
                                Enabled  = 1
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Tls
                                Enabled  = 0
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Tls11
                                Enabled  = 0
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Tls12
                                Enabled  = 1
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Tls13
                                Enabled  = 1
                            }
                        )
                    } -ParameterFilter { $Client -eq $false }
                }
            }

            It 'Should return the correct values' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $currentState = $script:mockInstance.GetCurrentState(
                        @{
                            IsSingleInstance = 'Yes'
                        }
                    )

                    $currentState.ProtocolsEnabled | Should -Be $script:mockInstance.ProtocolsEnabled
                    # $currentState.ProtocolsEnabled.GetType().Name | Should -Be 'SChannelSslProtocols' # BeOfType does not work for types declared in module

                    $currentState.ProtocolsDisabled | Should -Be $script:mockInstance.ProtocolsDisabled
                    # $currentState.ProtocolsDisabled.GetType().Name | Should -Be 'SChannelSslProtocols'

                    $currentState.ProtocolsDefault | Should -BeNullOrEmpty
                }

                Should -Invoke -CommandName Get-TlsProtocol -ParameterFilter {
                    $Client -eq $false
                } -Exactly -Times 1 -Scope It
            }
        }
    }

    Context 'When $ClientSide is $true' {
        Context 'When object is present in the current state' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [SChannelProtocolBase] @{
                        IsSingleInstance   = 'Yes'
                        ProtocolsEnabled   = @(
                            [SChannelSslProtocols]::DTls12
                            [SChannelSslProtocols]::Tls12
                            [SChannelSslProtocols]::Tls13
                        )
                        ProtocolsDisabled  = @(
                            [SChannelSslProtocols]::Ssl2
                            [SChannelSslProtocols]::Ssl3
                            [SChannelSslProtocols]::Dtls1
                            [SChannelSslProtocols]::Tls
                        )
                        ProtocolsDefault   = @(
                            [SChannelSslProtocols]::Tls11
                        )
                        RebootWhenRequired = $true
                    }

                    $script:mockInstance.ClientSide = $true

                    Mock -CommandName Get-TlsProtocol -MockWith {
                        @(
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Ssl2
                                Enabled  = 0
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Ssl3
                                Enabled  = 0
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Dtls1
                                Enabled  = 0
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Dtls12
                                Enabled  = 1
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Tls
                                Enabled  = 0
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Tls11
                                Enabled  = $null
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Tls12
                                Enabled  = 1
                            }
                            [PSCustomObject] @{
                                Protocol = [SChannelSslProtocols]::Tls13
                                Enabled  = 1
                            }
                        )
                    } -ParameterFilter { $Client -eq $true }
                }
            }

            It 'Should return the correct values' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $currentState = $script:mockInstance.GetCurrentState(
                        @{
                            IsSingleInstance = 'Yes'
                        }
                    )

                    $currentState.ProtocolsEnabled | Should -Be $script:mockInstance.ProtocolsEnabled
                    # $currentState.ProtocolsEnabled.GetType().Name | Should -Be 'SChannelSslProtocols' # BeOfType does not work for types declared in module

                    $currentState.ProtocolsDisabled | Should -Be $script:mockInstance.ProtocolsDisabled
                    # $currentState.ProtocolsDisabled.GetType().Name | Should -Be 'SChannelSslProtocols'

                    $currentState.ProtocolsDefault | Should -Be $script:mockInstance.ProtocolsDefault
                    # $currentState.ProtocolsDefault.GetType().Name | Should -Be 'SChannelSslProtocols'
                }

                Should -Invoke -CommandName Get-TlsProtocol -ParameterFilter {
                    $Client -eq $true
                } -Exactly -Times 1 -Scope It
            }
        }
    }
}

Describe 'SChannelProtocolBase\Modify()' -Tag 'HiddenMember' {
    Context 'When $ClientSide is $false' {
        Context 'When modifying protocols' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [SChannelProtocolBase] @{
                        IsSingleInstance   = 'Yes'
                        ProtocolsEnabled   = @(
                            [SChannelSslProtocols]::DTls12
                            [SChannelSslProtocols]::Tls12
                            [SChannelSslProtocols]::Tls13
                        )
                        ProtocolsDisabled  = @(
                            [SChannelSslProtocols]::Ssl2
                            [SChannelSslProtocols]::Ssl3
                            [SChannelSslProtocols]::Dtls1
                            [SChannelSslProtocols]::Tls
                        )
                        ProtocolsDefault   = @(
                            [SChannelSslProtocols]::Tls11
                        )
                        RebootWhenRequired = $true
                    }

                    Mock -CommandName Enable-TlsProtocol -ParameterFilter { $Client -eq $false }
                    Mock -CommandName Disable-TlsProtocol -ParameterFilter { $Client -eq $false }
                    Mock -CommandName Reset-TlsProtocol -ParameterFilter { $Client -eq $false }
                    Mock -CommandName Set-DscMachineRebootRequired
                }
            }

            It 'Should call the correct mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $propertiesToModify = @{
                        ProtocolsEnabled  = @(
                            [SChannelSslProtocols]::Tls12,
                            [SChannelSslProtocols]::Tls13
                        )
                        ProtocolsDisabled = @(
                            [SChannelSslProtocols]::Ssl2
                            [SChannelSslProtocols]::Ssl3
                            [SChannelSslProtocols]::Tls
                        )
                        ProtocolsDefault  = @()
                    }

                    $script:mockInstance.PropertiesNotInDesiredState = @(
                        @{
                            Property      = 'ProtocolsEnabled'
                            ExpectedValue = @(
                                [SChannelSslProtocols]::DTls12
                                [SChannelSslProtocols]::Tls12
                                [SChannelSslProtocols]::Tls13
                            )
                            ActualValue   = $propertiesToModify.ProtocolsEnabled
                        }
                        @{
                            Property      = 'ProtocolsDisabled'
                            ExpectedValue = @(
                                [SChannelSslProtocols]::Ssl2
                                [SChannelSslProtocols]::Ssl3
                                [SChannelSslProtocols]::Dtls1
                                [SChannelSslProtocols]::Tls
                            )
                            ActualValue   = $propertiesToModify.ProtocolsDisabled
                        }
                        @{
                            Property      = 'ProtocolsDefault'
                            ExpectedValue = @(
                                [SChannelSslProtocols]::Tls11

                            )
                            ActualValue   = $propertiesToModify.ProtocolsDefault
                        }
                    )

                    # HT with expected values
                    $null = $script:mockInstance.Modify($propertiesToModify)
                }

                Should -Invoke -CommandName Enable-TlsProtocol -ParameterFilter {
                    $Client -eq $false -and
                    $Protocol -eq 'DTls12'
                } -Exactly -Times 1 -Scope It

                Should -Invoke -CommandName Disable-TlsProtocol -ParameterFilter {
                    $Client -eq $false -and
                    $Protocol -contains @(
                        'DTls1'
                    )
                } -Exactly -Times 1 -Scope It

                Should -Invoke -CommandName Reset-TlsProtocol -ParameterFilter {
                    $Client -eq $false -and
                    $Protocol -eq 'Tls11'
                } -Exactly -Times 1 -Scope It

                Should -Invoke -CommandName Set-DscMachineRebootRequired -Exactly -Times 1 -Scope It
            }
        }
    }
}

Describe 'SChannelProtocolBase\AssertProperties()' -Tag 'HiddenMember' {
    Context 'When validating properties' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [SChannelProtocolBase] @{
                    IsSingleInstance   = 'Yes'
                    RebootWhenRequired = $true
                }
            }
        }

        It 'Should not throw when at least one protocol property is provided' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $properties = @{
                    ProtocolsEnabled = @(
                        'Tls12'
                    )
                }

                $null = $script:mockInstance.AssertProperties($properties)
            }
        }

        It 'Should throw when no protocol properties are provided' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $properties = @{
                    RebootWhenRequired = $true
                }

                { $script:mockInstance.AssertProperties($properties) } | Should -Throw -ExpectedMessage '*DRC0050*'
            }
        }
    }

    Context 'When validating protocol properties' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [SChannelProtocolBase] @{
                    IsSingleInstance   = 'Yes'
                    RebootWhenRequired = $true
                }
            }
        }

        Context 'When a protocol is specified in multiple properties' {
            It 'Should throw the correct error' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $properties = @{
                        ProtocolsEnabled  = @(
                            'Tls12'
                        )
                        ProtocolsDisabled = @(
                            'Tls12'
                        )
                        ProtocolsDefault  = @(
                            'Tls12'
                        )
                    }

                    $errorRecord = Get-InvalidArgumentRecord -Message $script:mockInstance.LocalizedData.DuplicateProtocolValues -ArgumentName ($properties.Keys -join ',')

                    { $script:mockInstance.AssertProperties($properties) } | Should -Throw -ExpectedMessage $errorRecord.Exception.Message
                }
            }
        }

        Context 'When a protocol is specified in one property' {
            It 'Should not throw an error' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $properties = @{
                        ProtocolsEnabled = @(
                            'Tls12'
                        )
                    }

                    $null = $script:mockInstance.AssertProperties($properties)
                }
            }
        }
    }
}
