[CmdletBinding()]
param ()

$script:DSCModuleName = 'SChannelDsc'
$script:DSCResourceName = 'MSFT_SChannelSettings'

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
        Context -Name "When the TLS 1.2 is set to default and should be enabled" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    TLS12State       = 'Enabled'
                }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return '38000'
                }

                Mock -CommandName Get-ItemPropertyValue -MockWith {
                    return '38000'
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                Mock -CommandName Get-SChannelRegKeyValue -MockWith {}
                Mock -CommandName Set-SChannelRegKeyValue -MockWith {}
            }

            It "Should return TLS12State=Default from the Get method" {
                (Get-TargetResource @testParams).TLS12State | Should -Be 'Default'
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should update eight registry keys in the Set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Set-SChannelRegKeyValue -Times 8
            }
        }

        Context -Name "When the TLS 1.2 is set to default and should be" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    TLS12State       = 'Default'
                }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return '38000'
                }

                Mock -CommandName Get-ItemPropertyValue -MockWith {
                    return '38000'
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                Mock -CommandName Get-SChannelRegKeyValue -MockWith {}
            }

            It "Should return TLS12State=Default from the Get method" {
                (Get-TargetResource @testParams).TLS12State | Should -Be 'Default'
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should -Be $true
            }
        }

        Context -Name "When the TLS 1.2 is set to Enabled and should be Default" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    TLS12State       = 'Default'
                }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return '38000'
                }

                Mock -CommandName Get-ItemPropertyValue -MockWith {
                    return '38000'
                }

                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                Mock -CommandName Get-SChannelRegKeyValue -MockWith {
                    return 1
                }

                Mock -CommandName Set-SChannelRegKeyValue -MockWith {}
            }

            It "Should return TLS12State=Default from the Get method" {
                (Get-TargetResource @testParams).TLS12State | Should -Be 'Enabled'
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should update eight registry keys in the Set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Set-SChannelRegKeyValue -Times 8
            }
        }

        Context -Name "When the DH Key Size is absent, but should be 4096" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance              = 'Yes'
                    DiffieHellmanMinClientKeySize = 4096
                    DiffieHellmanMinServerKeySize = 4096
                }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return '58000'
                }

                Mock -CommandName Get-ItemPropertyValue -MockWith {
                    return '58000'
                }

                Mock -CommandName Get-SChannelRegKeyValue -MockWith {}

                Mock -CommandName Set-SChannelRegKeyValue -MockWith {}
            }

            It "Should return DHKeySizes=Null from the Get method" {
                $result = Get-TargetResource @testParams
                $result.DiffieHellmanMinClientKeySize | Should -BeNullOrEmpty
                $result.DiffieHellmanMinServerKeySize | Should -BeNullOrEmpty
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should update two registry keys in the Set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Set-SChannelRegKeyValue -Times 2
            }
        }

        Context -Name "When the DH Key Size is 1024, but should be 4096" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance              = 'Yes'
                    DiffieHellmanMinClientKeySize = 4096
                    DiffieHellmanMinServerKeySize = 4096
                }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return '58000'
                }

                Mock -CommandName Get-ItemPropertyValue -MockWith {
                    return '58000'
                }

                Mock -CommandName Get-SChannelRegKeyValue -MockWith {
                    return 1024
                }

                Mock -CommandName Get-SChannelRegKeyValue -MockWith {
                    return 0
                } -ParameterFilter { $Key -eq 'HKLM:SYSTEM\CurrentControlSet\Control\LSA\FIPSAlgorithmPolicy' }

                Mock -CommandName Set-SChannelRegKeyValue -MockWith {}
            }

            It "Should return DHKeySizes=Null from the Get method" {
                $result = Get-TargetResource @testParams
                $result.DiffieHellmanMinClientKeySize | Should -Be 1024
                $result.DiffieHellmanMinServerKeySize | Should -Be 1024
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should update two registry keys in the Set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Set-SChannelRegKeyValue -Times 2
            }
        }

        Context -Name "When the DH Key Size is 4096 and should be 4096" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance              = 'Yes'
                    DiffieHellmanMinClientKeySize = 4096
                    DiffieHellmanMinServerKeySize = 4096
                }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return '58000'
                }

                Mock -CommandName Get-ItemPropertyValue -MockWith {
                    return '58000'
                }

                Mock -CommandName Get-SChannelRegKeyValue -MockWith {
                    return 4096
                }

                Mock -CommandName Get-SChannelRegKeyValue -MockWith {
                    return 0
                } -ParameterFilter { $Key -eq 'HKLM:SYSTEM\CurrentControlSet\Control\LSA\FIPSAlgorithmPolicy' }

                Mock -CommandName Set-SChannelRegKeyValue -MockWith {}
            }

            It "Should return DHKeySizes=Null from the Get method" {
                $result = Get-TargetResource @testParams
                $result.DiffieHellmanMinClientKeySize | Should -Be 4096
                $result.DiffieHellmanMinServerKeySize | Should -Be 4096
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should -Be $true
            }
        }

        Context -Name "When the Kerberos Encryption Types not configured, but should be" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                = 'Yes'
                    KerberosSupportedEncryptionType = "AES128-HMAC-SHA1"
                }

                Mock -CommandName Get-SChannelRegKeyValue -MockWith {
                    return $null
                }

                Mock -CommandName Set-SChannelRegKeyValue -MockWith {}
            }

            It "Should return an empty array from the Get method" {
                $result = Get-TargetResource @testParams
                $result.KerberosSupportedEncryptionType.GetType().Name | Should -Be "Object[]"
                $result.KerberosSupportedEncryptionType.Count | Should -Be 0
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should update one registry key in the Set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Set-SChannelRegKeyValue -Times 1
            }
        }

        Context -Name "When the Kerberos Encryption Types are configured and should be" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                = 'Yes'
                    KerberosSupportedEncryptionType = @("DES-CBC-CRC","DES-CBC-MD5","RC4-HMAC-MD5","AES128-HMAC-SHA1","AES256-HMAC-SHA1")
                }

                Mock -CommandName Get-SChannelRegKeyValue -MockWith {
                    return 31
                }

                Mock -CommandName Set-SChannelRegKeyValue -MockWith {}
            }

            It "Should return all types from the Get method" {
                $result = Get-TargetResource @testParams
                $result.KerberosSupportedEncryptionType.GetType().Name | Should -Be "Object[]"
                $result.KerberosSupportedEncryptionType.Count | Should -Be 5
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should -Be $true
            }
        }

        Context -Name "When the WinHTTP Protocols are not configured, but should be" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance              = 'Yes'
                    WinHttpDefaultSecureProtocols = @("TLS1.2")
                }

                Mock -CommandName Get-SChannelRegKeyValue -MockWith {
                    return $null
                }

                Mock -CommandName Set-SChannelRegKeyValue -MockWith {}

                Mock -CommandName Get-Hotfix -MockWith { return "" }

                Mock -CommandName Get-SCDscOSVersion -MockWith { return [System.Version]"6.2" }
            }

            It "Should return an empty array from the Get method" {
                $result = Get-TargetResource @testParams
                $result.WinHttpDefaultSecureProtocols.GetType().Name | Should -Be "Object[]"
                $result.WinHttpDefaultSecureProtocols.Count | Should -Be 0
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should update one registry key in the Set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Set-SChannelRegKeyValue -Times 1
            }
        }

        Context -Name "When the WinHTTP Protocols are configured and should be" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance              = 'Yes'
                    WinHttpDefaultSecureProtocols = @("SSL2.0","SSL3.0","TLS1.0","TLS1.1","TLS1.2")
                }

                Mock -CommandName Get-SChannelRegKeyValue -MockWith {
                    return 2728
                }

                Mock -CommandName Set-SChannelRegKeyValue -MockWith {}
            }

            It "Should return all types from the Get method" {
                $result = Get-TargetResource @testParams
                $result.WinHttpDefaultSecureProtocols.GetType().Name | Should -Be "Object[]"
                $result.WinHttpDefaultSecureProtocols.Count | Should -Be 5
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should -Be $true
            }
        }

        Context -Name "When the WinHTTP Protocols are not configured, but OS isn't Windows 2008 R2 or 2012" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance              = 'Yes'
                    WinHttpDefaultSecureProtocols = @("TLS1.2")
                }

                Mock -CommandName Get-SChannelRegKeyValue -MockWith {
                    return $null
                }

                Mock -CommandName Set-SChannelRegKeyValue -MockWith {}

                Mock -CommandName Get-Hotfix -MockWith { return $null }

                Mock -CommandName Get-SCDscOSVersion -MockWith { return [System.Version]"6.2" }
            }

            It "Should throw exception in the Set method" {
                { Set-TargetResource @testParams } | Should -Throw "Hotfix KB3140245 is not installed.*"
            }
        }

        Context -Name "When the FIPSPolicy is Disabled, but should be Enabled" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance          = 'Yes'
                    EnableFIPSAlgorithmPolicy = $true
                }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return '58000'
                }

                Mock -CommandName Get-ItemPropertyValue -MockWith {
                    return '58000'
                }

                Mock -CommandName Get-SChannelRegKeyValue -MockWith {
                    return 1024
                }

                Mock -CommandName Get-SChannelRegKeyValue -MockWith {
                    return 0
                } -ParameterFilter { $Key -eq 'HKLM:SYSTEM\CurrentControlSet\Control\LSA\FIPSAlgorithmPolicy' }

                Mock -CommandName Set-SChannelRegKeyValue -MockWith {}
            }

            It "Should return FipsPolicy=False from the Get method" {
                $result = Get-TargetResource @testParams
                $result.EnableFIPSAlgorithmPolicy | Should -Be $false
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should update one registry key in the Set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Set-SChannelRegKeyValue -Times 1
            }
        }

        Context -Name "When the FIPSPolicy is Enabled and should be" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance          = 'Yes'
                    EnableFIPSAlgorithmPolicy = $true
                }

                Mock -CommandName Get-ItemProperty -MockWith {
                    return '58000'
                }

                Mock -CommandName Get-ItemPropertyValue -MockWith {
                    return '58000'
                }

                Mock -CommandName Get-SChannelRegKeyValue -MockWith {
                    return 1024
                }

                Mock -CommandName Get-SChannelRegKeyValue -MockWith {
                    return 1
                } -ParameterFilter { $Key -eq 'HKLM:SYSTEM\CurrentControlSet\Control\LSA\FIPSAlgorithmPolicy' }

                Mock -CommandName Set-SChannelRegKeyValue -MockWith {}
            }

            It "Should return FipsPolicy=True from the Get method" {
                $result = Get-TargetResource @testParams
                $result.EnableFIPSAlgorithmPolicy | Should -Be $true
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
