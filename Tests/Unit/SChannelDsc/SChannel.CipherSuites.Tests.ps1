[CmdletBinding()]
param(
)

Import-Module -Name (Join-Path -Path $PSScriptRoot `
                               -ChildPath "..\UnitTestHelper.psm1" `
                               -Resolve)

$Global:SCDscHelper = New-SCDscUnitTestHelper -DscResource "CipherSuites"

Describe -Name $Global:SCDscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:SCDscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:SCDscHelper.InitializeScript -NoNewScope

        # Initialize tests

        # Mocks for all contexts

        # Test contexts
        Context -Name "When the cipher suite order is correct" -Fixture {
            $testParams = @{
                IsSingleInstance = "Yes"
                CipherSuitesOrder = @("TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256","TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256","TLS_DHE_RSA_WITH_AES_256_GCM_SHA384")
                Ensure = "Present"
            }

            Mock -CommandName Get-ItemProperty -MockWith { return "" }
            Mock -CommandName Get-ItemPropertyValue -MockWith {
                return @("TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256","TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256","TLS_DHE_RSA_WITH_AES_256_GCM_SHA384")
            }

            It "Should return present from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should Be "Present"
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should Be $true
            }
        }

        Context -Name "When the cipher suite order is incorrect" -Fixture {
            $testParams = @{
                IsSingleInstance = "Yes"
                CipherSuitesOrder = @("TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256","TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384","TLS_DHE_RSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256")
                Ensure = "Present"
            }

            Mock -CommandName New-Item -MockWith { }
            Mock -CommandName New-ItemProperty -MockWith { }

            Mock -CommandName Get-ItemProperty -MockWith { return "" }
            Mock -CommandName Get-ItemPropertyValue -MockWith {
                return @("TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256","TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256","TLS_DHE_RSA_WITH_AES_256_GCM_SHA384")
            }

            It "Should return present from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should Be "Present"
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should configure the cipher suites in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled New-ItemProperty
            }
        }

        Context -Name "When the cipher suite order has not been set yet" -Fixture {
            $testParams = @{
                IsSingleInstance = "Yes"
                CipherSuitesOrder = @("TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256","TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384","TLS_DHE_RSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256")
                Ensure = "Present"
            }

            Mock -CommandName New-Item -MockWith { }
            Mock -CommandName New-ItemProperty -MockWith { }

            Mock -CommandName Get-ItemProperty -MockWith { return $null }

            It "Should return absent from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should Be "Absent"
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should configure the cipher suites in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled New-ItemProperty
            }
        }

        Context -Name "When the cipher suite order exists, but shouldn't" -Fixture {
            $testParams = @{
                IsSingleInstance = "Yes"
                CipherSuitesOrder = @("TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256","TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256","TLS_DHE_RSA_WITH_AES_256_GCM_SHA384")
                Ensure = "Absent"
            }

            Mock -CommandName Remove-ItemProperty -MockWith { }
            Mock -CommandName Get-ItemProperty -MockWith { return "" }
            Mock -CommandName Get-ItemPropertyValue -MockWith {
                return @("TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256","TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256","TLS_DHE_RSA_WITH_AES_256_GCM_SHA384")
            }

            It "Should return present from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should Be "Present"
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should remove the cipher suites in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Remove-ItemProperty
            }
        }

        Context -Name "When the cipher suite order doesn't exists and shouldn't" -Fixture {
            $testParams = @{
                IsSingleInstance = "Yes"
                CipherSuitesOrder = @("TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256","TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256","TLS_DHE_RSA_WITH_AES_256_GCM_SHA384")
                Ensure = "Absent"
            }

            Mock -CommandName Remove-ItemProperty -MockWith { }
            Mock -CommandName Get-ItemProperty -MockWith { return $null }

            It "Should return absent from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should Be "Absent"
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should Be $true
            }
        }

        # CSO exists and shouldn't
        # CSO doesn't exist and shouldn't
<#
        Context -Name "When the cipher is enabled and shouldn't be" -Fixture {
            $testParams = @{
                Cipher = "AES 128/128"
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

            It "Should disable the cipher in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Switch-SChannelItem
            }
        }

        Context -Name "When the cipher isn't enabled and should be" -Fixture {
            $testParams = @{
                Cipher = "AES 128/128"
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

            It "Should disable the cipher in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Switch-SChannelItem
            }
        }

        Context -Name "When the cipher isn't enabled and shouldn't be" -Fixture {
            $testParams = @{
                Cipher = "AES 128/128"
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
        }#>
    }
}

Invoke-Command -ScriptBlock $Global:SCDscHelper.CleanupScript -NoNewScope
