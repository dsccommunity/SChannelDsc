<#
    .SYNOPSIS
        Unit test for DSC_Cipher DSC resource.
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
    $script:dscResourceName = 'DSC_Cipher'

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

Describe 'DSC_Cipher\Get-TargetResource' -Tag 'Get' {
    Context 'When the resource is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-SChannelItem -MockWith {
                return 'Enabled'
            }
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    Cipher = 'AES 128/128'
                    State  = 'Enabled'
                }

                $result = Get-TargetResource @testParams

                $result | Should -BeOfType 'System.Collections.Hashtable'
                $result.Cipher | Should -Be $testParams.Cipher
                $result.State | Should -Be 'Enabled'
            }
        }
    }
}

Describe 'DSC_Cipher\Test-TargetResource' -Tag 'Test' {
    Context 'When the resource is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                @{
                    Cipher = 'AES 128/128'
                    State  = 'Enabled'
                }
            }
        }

        It 'Should return true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    Cipher = 'AES 128/128'
                    State  = 'Enabled'
                }

                Test-TargetResource @testParams | Should -BeTrue
            }

            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the resource is not in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                @{
                    Cipher = 'AES 128/128'
                    State  = 'Disabled'
                }
            }
        }

        It 'Should return false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    Cipher = 'AES 128/128'
                    State  = 'Enabled'
                }

                Test-TargetResource @testParams | Should -BeFalse
            }

            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DSC_Cipher\Set-TargetResource' -Tag 'Set' {
    Context 'When the resource is not in the desired state' {
        BeforeDiscovery {
            $testCases = @(
                @{
                    State = 'Enabled'
                }
                @{
                    State = 'Disabled'
                }
                @{
                    State = 'Default'
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

                $testParams = @{
                    Cipher             = 'AES 128/128'
                    State              = $State
                    RebootWhenRequired = $true
                }

                $null = Set-TargetResource @testParams
            }

            Should -Invoke -CommandName Set-SChannelItem -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Set-DscMachineRebootRequired -Exactly -Times 1 -Scope It
        }
    }
}
