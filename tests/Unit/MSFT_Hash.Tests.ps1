[CmdletBinding()]
param ()

$script:DSCModuleName = 'SChannelDsc'
$script:DSCResourceName = 'MSFT_Hash'

function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

try
{
    InModuleScope $script:dscResourceName {
        # Initialize tests

        # Mocks for all contexts

        # Test contexts
        Context -Name "When the hash is enabled and should be" -Fixture {
            BeforeAll {
                $testParams = @{
                    Hash  = "MD5"
                    State = "Enabled"
                }

                Mock -CommandName Get-SChannelItem -MockWith {
                    return 'Enabled'
                }
            }

            It "Should return State=Enabled from the Get method" {
                (Get-TargetResource @testParams).State | Should -Be "Enabled"
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should -Be $true
            }
        }

        Context -Name "When the hash is enabled and shouldn't be" -Fixture {
            BeforeAll {
                $testParams = @{
                    Hash               = "MD5"
                    State              = "Disabled"
                    RebootWhenRequired = $true
                }

                Mock -CommandName Get-SChannelItem -MockWith {
                    return 'Enabled'
                }

                Mock -CommandName Set-SChannelItem -MockWith { }
            }

            It "Should return State=Enabled from the Get method" {
                (Get-TargetResource @testParams).State | Should -Be "Enabled"
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should disable the hash in the set method" {
                $global:DSCMachineStatus = 0
                Set-TargetResource @testParams
                Assert-MockCalled Set-SChannelItem
                $global:DSCMachineStatus | Should -Be 1
            }
        }

        Context -Name "When the hash is default and should be" -Fixture {
            BeforeAll {
                $testParams = @{
                    Hash  = "MD5"
                    State = "Default"
                }

                Mock -CommandName Get-SChannelItem -MockWith {
                    return 'Default'
                }
            }

            It "Should return Enabled from the Get method" {
                (Get-TargetResource @testParams).State | Should -Be "Default"
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should -Be $true
            }
        }

        Context -Name "When the hash should be default, but isn't" -Fixture {
            BeforeAll {
                $testParams = @{
                    Hash  = "MD5"
                    State = "Default"
                }

                Mock -CommandName Get-SChannelItem -MockWith {
                    return 'Disabled'
                }

                Mock -CommandName Set-SChannelItem -MockWith { }
            }

            It "Should return present from the Get method" {
                (Get-TargetResource @testParams).State | Should -Be "Disabled"
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should disable the cipher in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Set-SChannelItem
            }
        }

        Context -Name "When the hash isn't enabled and should be" -Fixture {
            BeforeAll {
                $testParams = @{
                    Hash  = "MD5"
                    State = "Enabled"
                }

                Mock -CommandName Get-SChannelItem -MockWith {
                    return 'Disabled'
                }

                Mock -CommandName Set-SChannelItem -MockWith { }
            }

            It "Should return State=Disabled from the Get method" {
                (Get-TargetResource @testParams).State | Should -Be "Disabled"
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should disable the hash in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Set-SChannelItem
            }
        }

        Context -Name "When the hash isn't enabled and shouldn't be" -Fixture {
            BeforeAll {
                $testParams = @{
                    Hash  = "MD5"
                    State = "Disabled"
                }

                Mock -CommandName Get-SChannelItem -MockWith {
                    return 'Disabled'
                }
            }

            It "Should return State=Disabled from the Get method" {
                (Get-TargetResource @testParams).State | Should -Be "Disabled"
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should -Be $true
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
