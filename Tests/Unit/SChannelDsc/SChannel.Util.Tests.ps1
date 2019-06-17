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

        Context -Name "Test method Get-SChannelItem" -Fixture {
            It "Settings are default. Should return 'Default' from this method" {
                Mock -CommandName Get-ItemProperty -MockWith { return $null }
                Get-SChannelItem -ItemKey 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols' | Should Be 'Default'
            }

            It "Setting is enabled. Should return enabled from this method" {
                Mock -CommandName Get-ItemProperty -MockWith { return 1 }
                Get-SChannelItem -ItemKey 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols' | Should Be 'Enabled'
            }

            It "Setting is disabled. Should return disabled from this method" {
                Mock -CommandName Get-ItemProperty -MockWith { return 0 }
                Get-SChannelItem -ItemKey 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols' | Should Be 'Disabled'
            }
        }

        Context -Name "Test method Set-SChannelItem" -Fixture {
            Mock -CommandName Test-Path -MockWith { return $false }
            Mock -CommandName Remove-Item -MockWith { $global:SCMockRemoveValue = $true }
            Mock -CommandName New-Item -MockWith {}
            Mock -CommandName New-ItemProperty -MockWith { $global:SCMockValue = $State }

            It "Settings are default. Should remove any configured value in this method" {
                $global:SCMockRemoveValue = $false
                Mock -CommandName Test-Path -MockWith { return $true }
                Set-SChannelItem -ItemKey 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols' -State 'Default'
                Assert-MockCalled Remove-Item
            }

            It "Setting is enabled. Should enable the specified item in this method" {
                $global:SCMockValue = ''
                Set-SChannelItem -ItemKey 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols' -State 'Enabled'
                Assert-MockCalled New-ItemProperty
                $global:SCMockValue | Should be 'Enabled'
            }

            It "Setting is disabled. Should disable the specified item in this method" {
                $global:SCMockValue = ''
                Set-SChannelItem -ItemKey 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols' -State 'Disabled'
                Assert-MockCalled New-ItemProperty
                $global:SCMockValue | Should be 'Disabled'
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:SCDscHelper.CleanupScript -NoNewScope
