[CmdletBinding()]
param(
)

Import-Module -Name (Join-Path -Path $PSScriptRoot `
                               -ChildPath "..\UnitTestHelper.psm1" `
                               -Resolve)

$Global:SCDscHelper = New-SCDscUnitTestHelper -DscResource "KeyExchangeAlgorithm"

Describe -Name $Global:SCDscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:SCDscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:SCDscHelper.InitializeScript -NoNewScope

        # Initialize tests

        # Mocks for all contexts

        # Test contexts
        Context -Name "When the key exchange algorithm is enabled and should be" -Fixture {
            $testParams = @{
                KeyExchangeAlgorithm = "Diffie-Hellman"
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

        Context -Name "When the key exchange algorithm is enabled and shouldn't be" -Fixture {
            $testParams = @{
                KeyExchangeAlgorithm = "Diffie-Hellman"
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

            It "Should disable the key exchange algorithm in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Switch-SChannelItem
            }
        }

        Context -Name "When the key exchange algorithm isn't enabled and should be" -Fixture {
            $testParams = @{
                KeyExchangeAlgorithm = "Diffie-Hellman"
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

            It "Should disable the key exchange algorithm in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Switch-SChannelItem
            }
        }

        Context -Name "When the key exchange algorithm isn't enabled and shouldn't be" -Fixture {
            $testParams = @{
                KeyExchangeAlgorithm = "Diffie-Hellman"
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
