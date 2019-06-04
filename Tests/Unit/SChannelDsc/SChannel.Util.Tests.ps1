[CmdletBinding()]
param(
)

Import-Module -Name (Join-Path -Path $PSScriptRoot `
                               -ChildPath "..\UnitTestHelper.psm1" `
                               -Resolve)

$Global:SCDscHelper = New-SCDscUnitTestHelper -SubModule "SChannelDsc.Util"

Describe -Name $Global:SCDscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:SCDscHelper.ModuleName -ScriptBlock {
        # Initialize tests

        # Mocks for all contexts

        # Test contexts
        Context -Name "Test method Convert-SCDscHashtableToString" -Fixture {
            $testParams = @{
                Name = "Test"
                Members = @("user1","user2")
            }
            It "Should convert hashtable to string" {
                Convert-SCDscHashtableToString -Hashtable $testParams | Should Be "Members=(user1,user2); Name=Test"
            }
        }

        Context -Name "Test method Switch-SChannelProtocol" -Fixture {
            Mock -CommandName Test-Path -MockWith { return $true }

            Mock -CommandName New-ItemProperty -MockWith { }

            It "Should enable the TLS 1.0 protocol" {
                Switch-SChannelProtocol -Protocol 'TLS 1.0' -Type 'Server' -Enable $true
                Assert-MockCalled New-ItemProperty -Times 2
            }

            It "Should disable the TLS 1.0 protocol" {
                Switch-SChannelProtocol -Protocol 'TLS 1.1' -Type 'Client' -Enable $false
                Assert-MockCalled New-ItemProperty -Times 2
            }
        }

        Context -Name "Test method Test-SChannelItem" -Fixture {
            Mock -CommandName Get-ItemProperty -MockWith { return "something" }
            Mock -CommandName Get-ItemPropertyValue -MockWith { return 0 }

            It "Should return false from the method" {
                Test-SChannelItem -ItemKey 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes' -Enable $true | Should Be $false
            }

            It "Should return false from the method" {
                Test-SChannelItem -ItemKey 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes' -Enable $false | Should Be $true
            }
        }

        Context -Name "Test method Switch-SChannelItem" -Fixture {
            Mock -CommandName Test-Path -MockWith { return $true }

            Mock -CommandName New-ItemProperty -MockWith { }

            It "Should enable the ECDH algorithm" {
                Switch-SChannelItem -ItemKey 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\ECDH' -Enable $true
                Assert-MockCalled New-ItemProperty
            }

            It "Should disable the ECDH algorithm" {
                Switch-SChannelItem -ItemKey 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\ECDH' -Enable $false
                Assert-MockCalled New-ItemProperty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:SCDscHelper.CleanupScript -NoNewScope
