<#
    .SYNOPSIS
        Unit test for DSC_Protocol DSC resource.
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
    $script:dscResourceName = 'DSC_Protocol'

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

Describe 'DSC_Protocol\Get-TargetResource' -Tag 'Get' {
    Context 'When the protocol is TLS 1.3 on a pre-Windows Server 2022 OS' {
        BeforeAll {
            Mock -CommandName Get-SCDscOSVersion -MockWith {
                return @{
                    Major = 10
                    Build = 16000
                }
            }
        }

        It 'Should throw the correct exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    Protocol = 'TLS 1.3'
                    State    = 'Enabled'
                }

                $errorRecord = Get-InvalidOperationRecord -Message $script:localizedData.OSVersionNotSupported

                { Get-TargetResource @mockParams } | Should -Throw -ExpectedMessage $errorRecord.Exception.Message
            }
        }
    }

    Context 'When the OS supports any protocol' {
        BeforeAll {
            Mock -CommandName Get-SCDscOSVersion -MockWith {
                return @{
                    Major = 10
                    Build = 20348
                }
            }
        }

        Context 'When the client side result matches the server side result' {
            BeforeAll {
                Mock -CommandName Get-SChannelItem -ParameterFilter { $ItemKey -like '*\Server' } -MockWith {
                    return 'Enabled'
                }

                Mock -CommandName Get-SChannelItem -ParameterFilter { $ItemKey -like '*\Server' -and $ItemValue -eq 'DisabledByDefault' }  -MockWith {
                    return 'Disabled'
                }

                Mock -CommandName Get-SChannelItem -ParameterFilter { $ItemKey -like '*\Client' }  -MockWith {
                    return 'Enabled'
                }

                Mock -CommandName Get-SChannelItem -ParameterFilter { $ItemKey -like '*\Client' -and $ItemValue -eq 'DisabledByDefault' }  -MockWith {
                    return 'Disabled'
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockParams = @{
                        Protocol          = 'TLS 1.3'
                        IncludeClientSide = $true
                        State             = 'Enabled'
                    }

                    $result = Get-TargetResource @mockParams

                    $result.Protocol | Should -Be 'TLS 1.3'
                    $result.IncludeClientSide | Should -BeTrue
                    $result.State | Should -Be 'Enabled'
                }

            }
        }

        Context 'When the client side result does not match the server side result' {
            BeforeAll {
                Mock -CommandName Get-SChannelItem -ParameterFilter { $ItemKey -like '*\Server' } -MockWith {
                    return 'Enabled'
                }

                Mock -CommandName Get-SChannelItem -ParameterFilter { $ItemKey -like '*\Server' -and $ItemValue -eq 'DisabledByDefault' }  -MockWith {
                    return 'Disabled'
                }

                Mock -CommandName Get-SChannelItem -ParameterFilter { $ItemKey -like '*\Client' }  -MockWith {
                    return 'Disabled'
                }

                Mock -CommandName Get-SChannelItem -ParameterFilter { $ItemKey -like '*\Client' -and $ItemValue -eq 'DisabledByDefault' }  -MockWith {
                    return 'Enabled'
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockParams = @{
                        Protocol          = 'TLS 1.3'
                        IncludeClientSide = $true
                        State             = 'Enabled'
                    }

                    $result = Get-TargetResource @mockParams

                    $result.Protocol | Should -Be 'TLS 1.3'
                    $result.IncludeClientSide | Should -BeFalse
                    $result.State | Should -Be 'Enabled'
                }

            }
        }
    }
}

Describe 'DSC_Protocol\Test-TargetResource' -Tag 'Test' {
    Context 'When the resource is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                return @{
                    Protocol          = 'TLS 1.3'
                    IncludeClientSide = $true
                    State             = 'Enabled'
                }
            }
        }

        It 'Should return $true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    Protocol          = 'TLS 1.3'
                    IncludeClientSide = $true
                    State             = 'Enabled'
                }

                Test-TargetResource @mockParams | Should -BeTrue
            }
        }
    }

    Context 'When the resource is not in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                return @{
                    Protocol          = 'TLS 1.3'
                    IncludeClientSide = $true
                    State             = 'Disabled'
                }
            }
        }

        It 'Should return $false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    Protocol          = 'TLS 1.3'
                    IncludeClientSide = $true
                    State             = 'Enabled'
                }

                Test-TargetResource @mockParams | Should -BeFalse
            }
        }
    }
}

Describe 'DSC_Protocol\Set-TargetResource' -Tag 'Set' {
    Context 'When the protocol is TLS 1.3 on a pre-Windows Server 2022 OS' {
        BeforeAll {
            Mock -CommandName Get-SCDscOSVersion -MockWith {
                return @{
                    Major = 10
                    Build = 16000
                }
            }
        }

        It 'Should throw the correct exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    Protocol = 'TLS 1.3'
                    State    = 'Enabled'
                }

                $errorRecord = Get-InvalidOperationRecord -Message $script:localizedData.OSVersionNotSupported

                { Set-TargetResource @mockParams } | Should -Throw -ExpectedMessage $errorRecord.Exception.Message
            }
        }
    }

    Context 'When the OS supports any protocol' {
        BeforeAll {
            Mock -CommandName Get-SCDscOSVersion -MockWith {
                return @{
                    Major = 10
                    Build = 20348
                }
            }
        }

        Context 'When setting both Client and Server side settings' {
            BeforeDiscovery {
                $testCases = @(
                    @{
                        Protocol          = 'TLS 1.3'
                        IncludeClientSide = $true
                        State             = 'Enabled'
                    },
                    @{
                        Protocol          = 'TLS 1.3'
                        IncludeClientSide = $true
                        State             = 'Disabled'
                    },
                    @{
                        Protocol          = 'TLS 1.3'
                        IncludeClientSide = $true
                        State             = 'Default'
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
                        Protocol           = $Protocol
                        IncludeClientSide  = $IncludeClientSide
                        State              = $State
                        RebootWhenRequired = $true
                    }

                    $null = Set-TargetResource @mockParams
                }

                Should -Invoke -CommandName Set-SChannelItem -Exactly -Times 4 -Scope It
                Should -Invoke -CommandName Set-DscMachineRebootRequired -Exactly -Times 1 -Scope It
            }
        }
    }
}
