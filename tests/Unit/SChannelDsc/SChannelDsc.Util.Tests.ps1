[CmdletBinding()]
param ()

#region HEADER
$script:projectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$script:projectName = (Get-ChildItem -Path "$script:projectPath\*\*.psd1" | Where-Object -FilterScript {
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try
            {
                Test-ModuleManifest -Path $_.FullName -ErrorAction Stop
            }
            catch
            {
                $false
            })
    }).BaseName

$script:parentModule = Get-Module -Name $script:projectName -ListAvailable | Select-Object -First 1
$script:subModulesFolder = Join-Path -Path $script:parentModule.ModuleBase -ChildPath 'Modules'
Remove-Module -Name $script:parentModule -Force -ErrorAction 'SilentlyContinue'

$script:subModuleName = (Split-Path -Path $PSCommandPath -Leaf) -replace '\.Tests.ps1'
$script:subModuleFile = Join-Path -Path $script:subModulesFolder -ChildPath "$($script:subModuleName)"

Import-Module $script:subModuleFile -Force -ErrorAction 'Stop'
#endregion HEADER


InModuleScope $script:subModuleName {
    # Initialize tests

    # Mocks for all contexts

    # Test contexts
    Context -Name "Test method Convert-SCDscHashtableToString" -Fixture {
        BeforeAll {
            $testParams = @{
                Name      = "Test"
                Members   = @("user1", "user2")
                Parameter = @{ Name = "Test" }
            }
        }

        It "Should convert hashtable to string" {
            Convert-SCDscHashtableToString -Hashtable $testParams | Should -Be "Members=(user1,user2); Name=Test; Parameter={Name=Test}"
        }
    }

    Context -Name "Test method Convert-SCDscArrayToString" -Fixture {
        BeforeAll {
            $testParams = @(
                @{ Name = "Test" }
            )
        }

        It "Should convert array to string" {
            Convert-SCDscArrayToString -Array $testParams | Should -Be "({Name=Test})"
        }
    }

    Context -Name "Test method Convert-SCDscCIMInstanceToString" -Fixture {
        BeforeAll {
            $testParams = (Get-CimInstance -ClassName Win32_Environment)[0]
        }

        It "Should convert ciminstance to string" {
            Convert-SCDscCIMInstanceToString -CimInstance $testParams | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name "Test method Get-SCDscOSVersion" -Fixture {
        BeforeAll {
            $currentOS = [System.Environment]::OSVersion.Version
        }

        It "Should convert ciminstance to string" {
            Get-SCDscOSVersion | Should -Be $currentOS
        }
    }

    Context -Name "Test method Get-SChannelItem" -Fixture {
        It "Settings are default. Should return 'Default' from this method" {
            Mock -CommandName Get-ItemProperty -MockWith { return $null }
            Get-SChannelItem -ItemKey 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols' | Should -Be 'Default'
        }

        It "Setting is enabled. Should return enabled from this method" {
            Mock -CommandName Get-ItemProperty -MockWith { return 1 }
            Mock -CommandName Get-ItemPropertyValue -MockWith { return 1 }
            Get-SChannelItem -ItemKey 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols' | Should -Be 'Enabled'
        }

        It "Setting is disabled. Should return disabled from this method" {
            Mock -CommandName Get-ItemProperty -MockWith { return 0 }
            Mock -CommandName Get-ItemPropertyValue -MockWith { return 0 }
            Get-SChannelItem -ItemKey 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols' | Should -Be 'Disabled'
        }
    }

    Context -Name "Test method Get-SChannelRegKeyValue" -Fixture {
        BeforeAll {
            $null = New-Item -Path 'TestRegistry:\SChannel\Protocols' -Force
        }

        It "Settings are default. Should return null from this method" {
            Get-SChannelRegKeyValue -Key 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled' | Should -BeNullOrEmpty
        }

        It "Setting is enabled. Should return 1 from this method" {
            $null = New-Item 'TestRegistry:\SChannel\Protocols\SSL 3.0'
            $null = New-ItemProperty 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled' -Value 1
            Get-SChannelRegKeyValue -Key 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled' | Should -Be 1
        }
    }

    Context -Name "Test method Set-SChannelItem" -Fixture {
        BeforeAll {
            $null = New-Item -Path 'TestRegistry:\SChannel'
            $null = New-Item -Path 'TestRegistry:\SChannel\Protocols'
        }

        It "Settings are default. Should remove any configured value in this method" {
            $null = New-Item -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0'
            $null = New-ItemProperty -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled' -Value 1
            Set-SChannelItem -ItemKey 'TestRegistry:\SCHANNEL\Protocols' -ItemSubKey 'SSL 3.0' -State 'Default'
            (Get-Item -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -ErrorAction SilentlyContinue) | Should -BeNullOrEmpty
        }

        It "Setting is enabled. Should enable the specified item in this method" {
            Set-SChannelItem -ItemKey 'TestRegistry:\SCHANNEL\Protocols' -ItemSubKey 'SSL 3.0' -State 'Enabled'
            (Get-ItemPropertyValue -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled') | Should -Be 1
        }

        It "Setting is disabled. Should disable the specified item in this method" {
            Set-SChannelItem -ItemKey 'TestRegistry:\SCHANNEL\Protocols' -ItemSubKey 'SSL 3.0' -State 'Disabled'
            (Get-ItemPropertyValue -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled') | Should -Be 0
        }
    }

    Context -Name "Test method Set-SChannelRegKeyValue" -Fixture {
        BeforeAll {
            $null = New-Item -Path 'TestRegistry:\SChannel'
            $null = New-Item -Path 'TestRegistry:\SChannel\Protocols'
        }

        It "Protocol is enabled, but should be default. Should remove any configured value in this method" {
            $null = New-Item -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0'
            $null = New-ItemProperty -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled' -Value 1
            Set-SChannelRegKeyValue -Key 'TestRegistry:\SCHANNEL\Protocols' -SubKey 'SSL 3.0' -Name 'Enabled' -Remove
            (Get-Item -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -ErrorAction SilentlyContinue) | Should -BeNullOrEmpty
        }

        It "Protocol is disabled, but should be enabled. Should enable the protocol in this method" {
            $null = New-Item -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0'
            $null = New-ItemProperty -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled' -Value 0
            Set-SChannelRegKeyValue -Key 'TestRegistry:\SCHANNEL\Protocols' -SubKey 'SSL 3.0' -Name 'Enabled' -Value 1
            (Get-ItemPropertyValue -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled') | Should -Be 1
        }

        It "Protocol settings are default, but should be enabled. Should enable the protocol in this method" {
            Set-SChannelRegKeyValue -Key 'TestRegistry:\SCHANNEL\Protocols' -SubKey 'SSL 3.0' -Name 'Enabled' -Value 1
            (Get-ItemPropertyValue -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled') | Should -Be 1
        }
    }

    Context -Name "Test method Test-SCDscObjectHasProperty" -Fixture {
        BeforeAll {
            $testParams = [PsCustomObject]@{
                Name    = "Test"
                Members = @("user1", "user2")
            }
        }

        It "Object contains specified member. Should return true from the method" {
            Test-SCDscObjectHasProperty -Object $testParams -PropertyName "Name" | Should -Be $true
        }

        It "Object does not contain specified member. Should return false from the method" {
            Test-SCDscObjectHasProperty -Object $testParams -PropertyName "WrongName" | Should -Be $false
        }
    }
}
