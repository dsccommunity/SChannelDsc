<#
    .SYNOPSIS
        Unit test for DSC_CipherSuites DSC resource.
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
    $script:dscResourceName = 'DSC_CipherSuites'

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

Describe 'DSC_CipherSuites\Get-TargetResource' -Tag 'Get' {
    Context 'When cipher suite order exists' {
        BeforeAll {
            Mock -CommandName Get-ItemProperty -MockWith { return 'MockData' }
            Mock -CommandName Get-ItemPropertyValue -MockWith {
                return 'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384'
            }
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    IsSingleInstance  = 'Yes'
                    CipherSuitesOrder = @(
                        'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
                        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
                        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
                        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
                        'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384'
                    )
                    Ensure            = 'Present'
                }

                $result = Get-TargetResource @mockParams

                $result.Ensure | Should -Be 'Present'
                $result.CipherSuitesOrder | Should -Be @(
                    'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
                    'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
                    'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
                    'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
                    'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384'
                )
            }

            Should -Invoke -CommandName Get-ItemProperty -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-ItemPropertyValue -Exactly -Times 1 -Scope It
        }
    }

    Context 'When cipher suite order does not exist' {
        BeforeAll {
            Mock -CommandName Get-ItemProperty
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    IsSingleInstance  = 'Yes'
                    CipherSuitesOrder = @(
                        'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
                        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
                        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
                        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
                        'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384'
                    )
                    Ensure            = 'Present'
                }

                $result = Get-TargetResource @mockParams

                $result.Ensure | Should -Be 'Absent'
                $result.CipherSuitesOrder | Should -BeNullOrEmpty
            }

            Should -Invoke -CommandName Get-ItemProperty -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DSC_CipherSuites\Test-TargetResource' -Tag 'Test' {
    Context 'When the resource is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                return @{
                    CipherSuitesOrder = [System.String[]] @(
                        'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
                        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
                        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
                        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
                        'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384'
                    )
                    Ensure            = 'Present'
                }
            }
        }

        It 'Should return true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    IsSingleInstance   = 'Yes'
                    CipherSuitesOrder  = @(
                        'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
                        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
                        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
                        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
                        'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384'
                    )
                    Ensure             = 'Present'
                    RebootWhenRequired = $false
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
                    CipherSuitesOrder = [System.String[]] @(
                        'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
                        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
                        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
                        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
                        'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384'
                    )
                    Ensure            = 'Present'
                }
            }
        }

        It 'Should return false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    IsSingleInstance   = 'Yes'
                    CipherSuitesOrder  = @(
                        'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
                        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
                        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
                        'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384',
                        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
                    )
                    Ensure             = 'Present'
                    RebootWhenRequired = $false
                }

                Test-TargetResource @mockParams | Should -BeFalse
            }

            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DSC_CipherSuites\Set-TargetResource' -Tag 'Set' {
    Context 'When the resource needs to be created' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
            Mock -CommandName Set-DscMachineRebootRequired
        }

        It 'Should call the correct mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    IsSingleInstance   = 'Yes'
                    CipherSuitesOrder  = @(
                        'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
                        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
                        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
                        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
                        'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384'
                    )
                    Ensure             = 'Present'
                    RebootWhenRequired = $true
                }

                $null = Set-TargetResource @mockParams
            }

            Should -Invoke -CommandName New-Item -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName New-ItemProperty -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Set-DscMachineRebootRequired -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the resource needs to be removed' {
        BeforeAll {
            Mock -CommandName Remove-ItemProperty
            Mock -CommandName Set-DscMachineRebootRequired
        }

        It 'Should call the correct mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    IsSingleInstance   = 'Yes'
                    Ensure             = 'Absent'
                    RebootWhenRequired = $true
                }

                $null = Set-TargetResource @mockParams
            }

            Should -Invoke -CommandName Remove-ItemProperty -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Set-DscMachineRebootRequired -Exactly -Times 1 -Scope It
        }
    }
}
