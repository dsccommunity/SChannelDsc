<#
    .SYNOPSIS
        Unit test for DSC_KeyExchangeAlgorithm DSC resource.
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
                & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 3>&1 4>&1 5>&1 6>&1 > $null
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
    $script:dscResourceName = 'DSC_KeyExchangeAlgorithm'

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscResourceName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Restore-TestEnvironment -TestEnvironment $script:testEnvironment

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscResourceName -All | Remove-Module -Force
}

Describe 'DSC_KeyExchangeAlgorithm\Get-TargetResource' -Tag 'Get' {
    Context 'When the resource exists' {
        BeforeAll {
            Mock -CommandName Get-SChannelItem -MockWith {
                return 'Enabled'
            }
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    KeyExchangeAlgorithm = 'Diffie-Hellman'
                    State                = 'Enabled'
                }

                $result = Get-TargetResource @mockParams

                $result.KeyExchangeAlgorithm | Should -Be 'Diffie-Hellman'
                $result.State                | Should -Be 'Enabled'
            }

            Should -Invoke -CommandName Get-SChannelItem -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DSC_KeyExchangeAlgorithm\Test-TargetResource' -Tag 'Test' {
    Context 'When the resource is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                return @{
                    KeyExchangeAlgorithm = 'Diffie-Hellman'
                    State                = 'Enabled'
                }
            }
        }

        It 'Should return true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    KeyExchangeAlgorithm = 'Diffie-Hellman'
                    State                = 'Enabled'
                }

                Test-TargetResource @mockParams | Should -BeTrue
            }

            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the resource is not in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                return @{
                    KeyExchangeAlgorithm = 'Diffie-Hellman'
                    State                = 'Disabled'
                }
            }
        }

        It 'Should return false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    KeyExchangeAlgorithm = 'Diffie-Hellman'
                    State                = 'Enabled'
                }

                Test-TargetResource @mockParams | Should -BeFalse
            }

            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DSC_KeyExchangeAlgorithm\Set-TargetResource' -Tag 'Set' {
    Context 'When setting the resource' {
        BeforeDiscovery {
            $testCases = @(
                @{
                    KeyExchangeAlgorithm = 'Diffie-Hellman'
                    State                = 'Enabled'
                },
                @{
                    KeyExchangeAlgorithm = 'ECDH'
                    State                = 'Disabled'
                },
                @{
                    KeyExchangeAlgorithm = 'PKCS'
                    State                = 'Default'
                }
            )
        }

        BeforeAll {
            Mock -CommandName Set-SChannelItem
            Mock -CommandName Set-DscMachineRebootRequired
        }

        It 'Should call the correct mocks for state ''<State>''' -ForEach $testCases {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    KeyExchangeAlgorithm = $KeyExchangeAlgorithm
                    State                = $State
                    RebootWhenRequired   = $true
                }

                $null = Set-TargetResource @mockParams
            }

            Should -Invoke -CommandName Set-SChannelItem -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Set-DscMachineRebootRequired -Exactly -Times 1 -Scope It
        }
    }
}
