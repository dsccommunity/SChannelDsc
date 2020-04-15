[CmdletBinding()]
param ()

$script:DSCModuleName = 'SChannelDsc'
$script:DSCResourceName = 'MSFT_CipherSuites'

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
    }
}
finally
{
    Invoke-TestCleanup
}
