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
                Mock -CommandName Get-ItemPropertyValue -MockWith { return 1 }
                Get-SChannelItem -ItemKey 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols' | Should Be 'Enabled'
            }

            It "Setting is disabled. Should return disabled from this method" {
                Mock -CommandName Get-ItemProperty -MockWith { return 0 }
                Mock -CommandName Get-ItemPropertyValue -MockWith { return 0 }
                Get-SChannelItem -ItemKey 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols' | Should Be 'Disabled'
            }
        }

        Context -Name "Test method Get-SChannelRegKeyValue" -Fixture {
            $null = New-Item -Path 'TestRegistry:\SChannel\Protocols' -Force

            It "Settings are default. Should return null from this method" {
                Get-SChannelRegKeyValue -Key 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled' | Should BeNullOrEmpty
            }

            It "Setting is enabled. Should return 1 from this method" {
                $null = New-Item 'TestRegistry:\SChannel\Protocols\SSL 3.0'
                $null = New-ItemProperty 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled' -Value 1
                Get-SChannelRegKeyValue -Key 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled' | Should Be 1
            }
        }

        Context -Name "Test method Set-SChannelItem" -Fixture {
            $null = New-Item -Path 'TestRegistry:\SChannel'
            $null = New-Item -Path 'TestRegistry:\SChannel\Protocols'

            It "Settings are default. Should remove any configured value in this method" {
                $null = New-Item -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0'
                $null = New-ItemProperty -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled' -Value 1
                Set-SChannelItem -ItemKey 'TestRegistry:\SCHANNEL\Protocols' -ItemSubKey 'SSL 3.0' -State 'Default'
                (Get-Item -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -ErrorAction SilentlyContinue) | Should BeNullOrEmpty
            }

            It "Setting is enabled. Should enable the specified item in this method" {
                Set-SChannelItem -ItemKey 'TestRegistry:\SCHANNEL\Protocols' -ItemSubKey 'SSL 3.0' -State 'Enabled'
                (Get-ItemPropertyValue -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled') | Should Be 4294967295
            }

            It "Setting is disabled. Should disable the specified item in this method" {
                Set-SChannelItem -ItemKey 'TestRegistry:\SCHANNEL\Protocols' -ItemSubKey 'SSL 3.0' -State 'Disabled'
                (Get-ItemPropertyValue -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled') | Should Be 0
            }
        }

        Context -Name "Test method Set-SChannelRegKeyValue" -Fixture {
            $null = New-Item -Path 'TestRegistry:\SChannel'
            $null = New-Item -Path 'TestRegistry:\SChannel\Protocols'

            It "Protocol is enabled, but should be default. Should remove any configured value in this method" {
                $null = New-Item -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0'
                $null = New-ItemProperty -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled' -Value 1
                Set-SChannelRegKeyValue -Key 'TestRegistry:\SCHANNEL\Protocols' -SubKey 'SSL 3.0' -Name 'Enabled' -Remove
                (Get-Item -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -ErrorAction SilentlyContinue) | Should BeNullOrEmpty
            }

            It "Protocol is disabled, but should be enabled. Should enable the protocol in this method" {
                $null = New-Item -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0'
                $null = New-ItemProperty -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled' -Value 0
                Set-SChannelRegKeyValue -Key 'TestRegistry:\SCHANNEL\Protocols' -SubKey 'SSL 3.0' -Name 'Enabled' -Value 1
                (Get-ItemPropertyValue -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled') | Should Be 1
            }

            It "Protocol settings are default, but should be enabled. Should enable the protocol in this method" {
                Set-SChannelRegKeyValue -Key 'TestRegistry:\SCHANNEL\Protocols' -SubKey 'SSL 3.0' -Name 'Enabled' -Value 1
                (Get-ItemPropertyValue -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled') | Should Be 1
            }
        }

        Context -Name "Test method Test-SCDscObjectHasProperty" -Fixture {
            $testParams = [PsCustomObject]@{
                Name = "Test"
                Members = @("user1","user2")
            }

            It "Object contains specified member. Should return true from the method" {
                Test-SCDscObjectHasProperty -Object $testParams -PropertyName "Name" | Should Be $true
            }

            It "Object does not contain specified member. Should return false from the method" {
                Test-SCDscObjectHasProperty -Object $testParams -PropertyName "WrongName" | Should Be $false
            }
        }

        Context -Name "Test method Test-SCDscParameterState" -Fixture {
            $currentValues = @{
                String  = "Test"
                Array   = @("user1","user2")
                Int     = 1
                Boolean = $true
            }

            $desiredValues = @{
                String  = "Test"
                Array   = @("user1","user2")
                Int     = 1
                Boolean = $true
            }
            It "Objects are equal. Should return true from the method" {
                Test-SCDscParameterState -CurrentValues $currentValues -DesiredValues $desiredValues | Should Be $true
            }

            $currentValues = @{
                String  = "Test2"
                Array   = @("user1","user2")
                Int     = 1
                Boolean = $true
            }
            It "Objects are not equal on string. Should return false from the method" {
                Test-SCDscParameterState -CurrentValues $currentValues -DesiredValues $desiredValues | Should Be $false
            }

            $currentValues = @{
                String  = "Test"
                Array   = @("user1","user3")
                Int     = 1
                Boolean = $true
            }
            It "Objects are not equal on array. Should return false from the method" {
                Test-SCDscParameterState -CurrentValues $currentValues -DesiredValues $desiredValues | Should Be $false
            }

            $currentValues = @{
                String  = "Test"
                Array   = @("user1","user2")
                Int     = 2
                Boolean = $true
            }
            It "Objects are not equal on int. Should return false from the method" {
                Test-SCDscParameterState -CurrentValues $currentValues -DesiredValues $desiredValues | Should Be $false
            }

            $currentValues = @{
                String  = "Test"
                Array   = @("user1","user2")
                Int     = 1
                Boolean = $false
            }
            It "Objects are not equal on boolean. Should return false from the method" {
                Test-SCDscParameterState -CurrentValues $currentValues -DesiredValues $desiredValues | Should Be $false
            }

            $currentValues = @{
                String  = "Test2"
                Array   = @("user1","user2")
                Int     = 1
            }
            It "CurrentValues missing parameter. Should return false from the method" {
                Test-SCDscParameterState -CurrentValues $currentValues -DesiredValues $desiredValues | Should Be $false
            }
 
             $currentValues = @{
                String  = "Test"
                Array   = @("user1","user2")
                Int     = 1
                Boolean = $true
            }

            $desiredValues = @{
                String  = "Test"
                Array   = @("user1","user2")
                Int     = 1
            }
            It "DesiredValues missing parameter. Should return true from the method" {
                Test-SCDscParameterState -CurrentValues $currentValues -DesiredValues $desiredValues | Should Be $true
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:SCDscHelper.CleanupScript -NoNewScope
