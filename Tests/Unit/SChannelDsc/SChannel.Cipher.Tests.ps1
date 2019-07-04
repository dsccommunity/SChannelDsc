[CmdletBinding()]
param(
)

Import-Module -Name (Join-Path -Path $PSScriptRoot `
                               -ChildPath "..\UnitTestHelper.psm1" `
                               -Resolve)

$Global:SCDscHelper = New-SCDscUnitTestHelper -DscResource "Cipher"

Describe -Name $Global:SCDscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:SCDscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:SCDscHelper.InitializeScript -NoNewScope

        # Initialize tests

        # Mocks for all contexts

        # Test contexts
        Context -Name "When the cipher is enabled and should be" -Fixture {
            $testParams = @{
                Cipher = "AES 128/128"
                State  = "Enabled"
            }

            Mock -CommandName Get-SChannelItem -MockWith {
                return 'Enabled'
            }

            It "Should return Enabled from the Get method" {
                (Get-TargetResource @testParams).State | Should Be "Enabled"
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should Be $true
            }
        }

        Context -Name "When the cipher is enabled and shouldn't be" -Fixture {
            $testParams = @{
                Cipher = "AES 128/128"
                State  = "Disabled"
            }

            Mock -CommandName Get-SChannelItem -MockWith {
                return 'Enabled'
            }

            Mock -CommandName Set-SChannelItem -MockWith { }

            It "Should return present from the Get method" {
                (Get-TargetResource @testParams).State | Should Be "Enabled"
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should disable the cipher in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Set-SChannelItem
            }
        }

        Context -Name "When the cipher is default and should be" -Fixture {
            $testParams = @{
                Cipher = "AES 128/128"
                State  = "Default"
            }

            Mock -CommandName Get-SChannelItem -MockWith {
                return 'Default'
            }

            It "Should return Enabled from the Get method" {
                (Get-TargetResource @testParams).State | Should Be "Default"
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should Be $true
            }
        }

        Context -Name "When the cipher should be default, but isn't" -Fixture {
            $testParams = @{
                Cipher = "AES 128/128"
                State  = "Default"
            }

            Mock -CommandName Get-SChannelItem -MockWith {
                return 'Disabled'
            }

            Mock -CommandName Set-SChannelItem -MockWith { }

            It "Should return present from the Get method" {
                (Get-TargetResource @testParams).State | Should Be "Disabled"
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should disable the cipher in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Set-SChannelItem
            }
        }

        Context -Name "When the cipher isn't enabled and should be" -Fixture {
            $testParams = @{
                Cipher = "AES 128/128"
                State = "Enabled"
            }

            Mock -CommandName Get-SChannelItem -MockWith {
                return 'Disabled'
            }

            Mock -CommandName Set-SChannelItem -MockWith { }

            It "Should return absent from the Get method" {
                (Get-TargetResource @testParams).State | Should Be "Disabled"
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should disable the cipher in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Set-SChannelItem
            }
        }

        Context -Name "When the cipher isn't enabled and shouldn't be" -Fixture {
            $testParams = @{
                Cipher = "AES 128/128"
                State  = "Disabled"
            }

            Mock -CommandName Get-SChannelItem -MockWith {
                return 'Disabled'
            }

            It "Should return absent from the Get method" {
                (Get-TargetResource @testParams).State | Should Be "Disabled"
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should Be $true
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:SCDscHelper.CleanupScript -NoNewScope
