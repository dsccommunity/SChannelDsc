[CmdletBinding()]
param(
)

Import-Module -Name (Join-Path -Path $PSScriptRoot `
                               -ChildPath "..\UnitTestHelper.psm1" `
                               -Resolve)

$Global:SCDscHelper = New-SCDscUnitTestHelper -DscResource "Hash"

Describe -Name $Global:SCDscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:SCDscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:SCDscHelper.InitializeScript -NoNewScope

        # Initialize tests

        # Mocks for all contexts

        # Test contexts
        Context -Name "When the hash is enabled and should be" -Fixture {
            $testParams = @{
                Hash = "MD5"
                Ensure = "Present"
            }

            Mock -CommandName Test-SChannelItem -MockWith {
                return $true
            }

            It "Should return present from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should Be "Present"
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should Be $true
            }
        }

        Context -Name "When the hash is enabled and shouldn't be" -Fixture {
            $testParams = @{
                Hash = "MD5"
                Ensure = "Absent"
            }

            Mock -CommandName Test-SChannelItem -MockWith {
                return $true
            }

            Mock -CommandName Switch-SChannelItem -MockWith { }

            It "Should return present from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should Be "Present"
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should disable the hash in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Switch-SChannelItem
            }
        }

        Context -Name "When the hash isn't enabled and should be" -Fixture {
            $testParams = @{
                Hash = "MD5"
                Ensure = "Present"
            }

            Mock -CommandName Test-SChannelItem -MockWith {
                return $false
            }

            Mock -CommandName Switch-SChannelItem -MockWith { }

            It "Should return absent from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should Be "Absent"
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should disable the hash in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Switch-SChannelItem
            }
        }

        Context -Name "When the hash isn't enabled and shouldn't be" -Fixture {
            $testParams = @{
                Hash = "MD5"
                Ensure = "Absent"
            }

            Mock -CommandName Test-SChannelItem -MockWith {
                return $false
            }

            Mock -CommandName Switch-SChannelItem -MockWith { }

            It "Should return absent from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should Be "Absent"
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should Be $true
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:SCDscHelper.CleanupScript -NoNewScope
