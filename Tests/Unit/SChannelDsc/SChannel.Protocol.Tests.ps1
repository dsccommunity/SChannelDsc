[CmdletBinding()]
param(
)

Import-Module -Name (Join-Path -Path $PSScriptRoot `
                               -ChildPath "..\UnitTestHelper.psm1" `
                               -Resolve)

$Global:SCDscHelper = New-SCDscUnitTestHelper -DscResource "Protocol"

Describe -Name $Global:SCDscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:SCDscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:SCDscHelper.InitializeScript -NoNewScope

        # Initialize tests

        # Mocks for all contexts

        # Test contexts
        Context -Name "When the protocol is enabled and should be" -Fixture {
            $testParams = @{
                Protocol = "TLS 1.0"
                #IncludeClientSide = $true
                Ensure = "Present"
            }

            Mock -CommandName Test-Path -MockWith { return $true }
            Mock -CommandName Get-Item -MockWith {
                return "item"
            }

            Mock -CommandName Get-ItemProperty -MockWith {
                return @{
                    Enabled = 4294967295
                    DisabledByDefault = 0
                }
            }

            It "Should return present from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should Be "Present"
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should Be $true
            }
        }

        Context -Name "When the protocol is enabled and shouldn't be" -Fixture {
            $testParams = @{
                Protocol = "TLS 1.0"
                Ensure = "Absent"
            }

            Mock -CommandName Test-Path -MockWith { return $true }
            Mock -CommandName Get-Item -MockWith {
                return "item"
            }

            Mock -CommandName Get-ItemProperty -MockWith {
                return @{
                    Enabled = 4294967295
                    DisabledByDefault = 0
                }
            }

            Mock -CommandName Switch-SChannelProtocol -MockWith { }

            It "Should return present from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should Be "Present"
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should disable the protocol in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Switch-SChannelProtocol
            }
        }

        Context -Name "When the protocol isn't enabled and should be" -Fixture {
            $testParams = @{
                Protocol = "TLS 1.0"
                Ensure = "Present"
            }

            Mock -CommandName Test-Path -MockWith { return $true }
            Mock -CommandName Get-Item -MockWith {
                return "item"
            }

            Mock -CommandName Get-ItemProperty -MockWith {
                return @{
                    Enabled = 0
                    DisabledByDefault = 1
                }
            }

            Mock -CommandName Switch-SChannelProtocol -MockWith { }

            It "Should return absent from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should Be "Absent"
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should disable the protocol in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Switch-SChannelProtocol
            }
        }

        Context -Name "When the protocol isn't enabled and shouldn't be" -Fixture {
            $testParams = @{
                Protocol = "TLS 1.0"
                Ensure = "Absent"
            }

            Mock -CommandName Test-Path -MockWith { return $true }
            Mock -CommandName Get-Item -MockWith {
                return "item"
            }

            Mock -CommandName Get-ItemProperty -MockWith {
                return @{
                    Enabled = 0
                    DisabledByDefault = 1
                }
            }

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
