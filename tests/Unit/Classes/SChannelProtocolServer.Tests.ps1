<#
    .SYNOPSIS
        Unit test for SChannelProtocolServer DSC resource.
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

    Import-Module -Name $script:dscModuleName -ErrorAction 'Stop'

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

Describe 'SChannelProtocolServer' {
    Context 'When class is instantiated' {
        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { [SChannelProtocolServer]::new() } | Should -Not -Throw
            }
        }

        It 'Should have a default or empty constructor' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [SChannelProtocolServer]::new()
                $instance | Should -Not -BeNullOrEmpty
            }
        }

        It 'Should be the correct type' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [SChannelProtocolServer]::new()
                $instance.GetType().Name | Should -Be 'SChannelProtocolServer'
            }
        }
    }
}

Describe 'SChannelProtocolServer\Get()' -Tag 'Get' {
    Context 'When the system is in the desired state' {
        Context 'When all of the properties have values' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [SChannelProtocolServer] @{
                        IsSingleInstance   = 'Yes'
                        ProtocolsEnabled   = @(
                            'Tls12',
                            'Tls13'
                        )
                        ProtocolsDisabled  = @(
                            'Ssl2',
                            'Ssl3'
                        )
                        ProtocolsDefault   = @(
                            'Tls',
                            'Tls11'
                        )
                        RebootWhenRequired = $true
                    }

                    <#
                        This mocks the method GetCurrentState().

                        Method Get() will call the base method Get() which will
                        call back to the derived class method GetCurrentState()
                        to get the result to return from the derived method Get().
                    #>
                    $script:mockInstance |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'GetCurrentState' -Value {
                            return @{
                                ProtocolsEnabled  = [System.String[]] @(
                                    'Tls12',
                                    'Tls13'
                                )
                                ProtocolsDisabled = [System.String[]] @(
                                    'Ssl2',
                                    'Ssl3'
                                )
                                ProtocolsDefault  = [System.String[]] @(
                                    'Tls',
                                    'Tls11'
                                )
                            }
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Assert' -Value {
                            return
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Normalize' -Value {
                            return
                        } -PassThru
                }
            }

            It 'Should return the correct values' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $currentState = $script:mockInstance.Get()

                    $currentState.IsSingleInstance | Should -Be 'Yes'

                    $currentState.ProtocolsEnabled | Should -HaveCount 2
                    $currentState.ProtocolsDisabled | Should -HaveCount 2
                    $currentState.ProtocolsDefault | Should -HaveCount 2

                    $currentState.Reasons | Should -BeNullOrEmpty
                }
            }
        }

        Context 'When a property is empty' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [SChannelProtocolServer] @{
                        IsSingleInstance   = 'Yes'
                        ProtocolsEnabled   = @(
                            'Tls12',
                            'Tls13'
                        )
                        ProtocolsDisabled  = @(
                            'Ssl2',
                            'Ssl3'
                        )
                        ProtocolsDefault   = @()
                        RebootWhenRequired = $true
                    }

                    <#
                        This mocks the method GetCurrentState().

                        Method Get() will call the base method Get() which will
                        call back to the derived class method GetCurrentState()
                        to get the result to return from the derived method Get().
                    #>
                    $script:mockInstance |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'GetCurrentState' -Value {
                            return @{
                                ProtocolsEnabled  = [System.String[]] @(
                                    'Tls12',
                                    'Tls13'
                                )
                                ProtocolsDisabled = [System.String[]] @(
                                    'Ssl2',
                                    'Ssl3'
                                )
                                ProtocolsDefault = $null
                            }
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Assert' -Value {
                            return
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Normalize' -Value {
                            return
                        } -PassThru
                }
            }

            It 'Should return the correct values' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $currentState = $script:mockInstance.Get()

                    $currentState.IsSingleInstance | Should -Be 'Yes'

                    $currentState.ProtocolsEnabled | Should -HaveCount 2
                    $currentState.ProtocolsDisabled | Should -HaveCount 2
                    $currentState.ProtocolsDefault | Should -BeNullOrEmpty

                    $currentState.Reasons | Should -BeNullOrEmpty
                }
            }
        }
    }

    Context 'When the system is not in the desired state' {
        Context 'When property ''ProtocolsEnabled'' has the wrong value' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [SChannelProtocolServer] @{
                        IsSingleInstance   = 'Yes'
                        ProtocolsEnabled   = @(
                            'Tls13'
                        )
                        ProtocolsDisabled  = @(
                            'Ssl2',
                            'Ssl3'
                        )
                        ProtocolsDefault   = @(
                            'Tls',
                            'Tls11',
                            'Tls12'
                        )
                        RebootWhenRequired = $true
                    }

                    <#
                        This mocks the method GetCurrentState().

                        Method Get() will call the base method Get() which will
                        call back to the derived class method GetCurrentState()
                        to get the result to return from the derived method Get().
                    #>
                    $script:mockInstance |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'GetCurrentState' -Value {
                            return @{
                                ProtocolsEnabled  = [System.String[]] @(
                                    'Tls12',
                                    'Tls13'
                                )
                                ProtocolsDisabled = [System.String[]] @(
                                    'Ssl2',
                                    'Ssl3'
                                )
                                ProtocolsDefault  = [System.String[]] @(
                                    'Tls',
                                    'Tls11'
                                )
                            }
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Assert' -Value {
                            return
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Normalize' -Value {
                            return
                        } -PassThru
                }
            }

            It 'Should return the correct values' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $currentState = $script:mockInstance.Get()

                    $currentState.IsSingleInstance | Should -Be 'Yes'

                    $currentState.ProtocolsEnabled | Should -HaveCount 2
                    $currentState.ProtocolsDisabled | Should -HaveCount 2
                    $currentState.ProtocolsDefault | Should -HaveCount 2

                    $currentState.Reasons | Should -HaveCount 2
                    $currentState.Reasons.Code | Should -Contain 'SChannelProtocolServer:SChannelProtocolServer:ProtocolsDefault'
                    $currentState.Reasons.Phrase | Should -Contain 'The property ProtocolsDefault should be ["Tls","Tls11","Tls12"], but was ["Tls","Tls11"]'
                    $currentState.Reasons.Code | Should -Contain 'SChannelProtocolServer:SChannelProtocolServer:ProtocolsEnabled'
                    $currentState.Reasons.Phrase | Should -Contain 'The property ProtocolsEnabled should be "Tls13", but was ["Tls12","Tls13"]'
                }
            }
        }

        Context 'When an empty property has the wrong value' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [SChannelProtocolServer] @{
                        IsSingleInstance   = 'Yes'
                        ProtocolsEnabled   = @(
                            'Tls12',
                            'Tls13'
                        )
                        ProtocolsDisabled  = @()
                        ProtocolsDefault   = @(
                            'Tls',
                            'Tls11'
                        )
                        RebootWhenRequired = $true
                    }

                    <#
                        This mocks the method GetCurrentState().

                        Method Get() will call the base method Get() which will
                        call back to the derived class method GetCurrentState()
                        to get the result to return from the derived method Get().
                    #>
                    $script:mockInstance |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'GetCurrentState' -Value {
                            return @{
                                ProtocolsEnabled  = [System.String[]] @(
                                    'Tls12',
                                    'Tls13'
                                )
                                ProtocolsDisabled = [System.String[]] @(
                                    'Ssl3'
                                )
                                ProtocolsDefault  = [System.String[]] @(
                                    'Tls',
                                    'Tls11'
                                )
                            }
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Assert' -Value {
                            return
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Normalize' -Value {
                            return
                        } -PassThru
                }
            }

            It 'Should return the correct values' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $currentState = $script:mockInstance.Get()

                    $currentState.IsSingleInstance | Should -Be 'Yes'

                    $currentState.ProtocolsEnabled | Should -HaveCount 2
                    $currentState.ProtocolsDisabled | Should -HaveCount 1
                    $currentState.ProtocolsDefault | Should -HaveCount 2

                    $currentState.Reasons | Should -HaveCount 1
                    $currentState.Reasons.Code | Should -Contain 'SChannelProtocolServer:SChannelProtocolServer:ProtocolsDisabled'
                    $currentState.Reasons.Phrase | Should -Contain 'The property ProtocolsDisabled should be , but was "Ssl3"'
                }
            }
        }
    }
}

Describe 'SChannelProtocolServer\Set()' -Tag 'Set' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockInstance = [SChannelProtocolServer] @{
                IsSingleInstance   = 'Yes'
                ProtocolsEnabled   = @(
                    'Tls12',
                    'Tls13'
                )
                ProtocolsDisabled  = @(
                    'Ssl2',
                    'Ssl3'
                )
                ProtocolsDefault   = @(
                    'Tls',
                    'Tls11'
                )
                RebootWhenRequired = $true
            } |
                # Mock method Modify which is called by the case method Set().
                Add-Member -Force -MemberType 'ScriptMethod' -Name 'Modify' -Value {
                    $script:mockMethodModifyCallCount += 1
                } -PassThru
        }
    }

    BeforeEach {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockMethodTestCallCount = 0
            $script:mockMethodModifyCallCount = 0
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance |
                    # Mock method Test() which is called by the base method Set()
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Test' -Value {
                        $script:mockMethodTestCallCount += 1
                        return $true
                    }
            }
        }

        It 'Should not call method Modify()' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $null = $script:mockInstance.Set()

                $script:mockMethodTestCallCount | Should -Be 1
                $script:mockMethodModifyCallCount | Should -Be 0
            }
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance |
                    # Mock method Test() which is called by the base method Set()
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Test' -Value {
                        $script:mockMethodTestCallCount += 1
                        return $false
                    }

                $script:mockInstance.PropertiesNotInDesiredState = @(
                    @{
                        Property      = 'ProtocolsDisabled'
                        ExpectedValue = @(
                            'Ssl2',
                            'Ssl3'
                        )
                        ActualValue   = @(
                            'Ssl3'
                        )
                    }
                )
            }
        }

        It 'Should call method Modify()' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $null = $script:mockInstance.Set()

                $script:mockMethodTestCallCount | Should -Be 1
                $script:mockMethodModifyCallCount | Should -Be 1
            }
        }
    }
}

Describe 'SChannelProtocolServer\Test()' -Tag 'Test' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockInstance = [SChannelProtocolServer] @{
                IsSingleInstance   = 'Yes'
                ProtocolsEnabled   = @(
                    'Tls12',
                    'Tls13'
                )
                ProtocolsDisabled  = @(
                    'Ssl2',
                    'Ssl3'
                )
                ProtocolsDefault   = @(
                    'Tls',
                    'Tls11'
                )
                RebootWhenRequired = $true
            }
        }
    }

    BeforeEach {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockGetMethodCallCount = 0
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance |
                    # Mock method Get() which is called by the base method Test()
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Get' -Value {
                        $script:mockGetMethodCallCount += 1
                    }
            }
        }

        It 'Should return $true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance.Test() | Should -BeTrue

                $script:mockGetMethodCallCount | Should -Be 1
            }
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance |
                    # Mock method Get() which is called by the base method Test()
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Get' -Value {
                        $script:mockGetMethodCallCount += 1
                    }

                $script:mockInstance.PropertiesNotInDesiredState = @(
                    @{
                        Property      = 'ProtocolsEnabled'
                        ExpectedValue = @(
                            'Tls12',
                            'Tls13'
                        )
                        ActualValue   = @(
                            'Tls12'
                        )
                    }
                )
            }
        }

        It 'Should return $false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance.Test() | Should -BeFalse

                $script:mockGetMethodCallCount | Should -Be 1
            }
        }
    }
}
