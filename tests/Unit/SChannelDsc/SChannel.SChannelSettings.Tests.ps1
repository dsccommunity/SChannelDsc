[CmdletBinding()]
param(
)

Import-Module -Name (Join-Path -Path $PSScriptRoot `
                               -ChildPath "..\UnitTestHelper.psm1" `
                               -Resolve)

$Global:SCDscHelper = New-SCDscUnitTestHelper -DscResource "SChannelSettings"

Describe -Name $Global:SCDscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:SCDscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:SCDscHelper.InitializeScript -NoNewScope

        # Initialize tests

        # Mocks for all contexts

        # Test contexts
        Context -Name "When the TLS 1.2 is set to default and should be enabled (.Net 4.5 or lower)" -Fixture {
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

            It "Should return TLS12State=Default from the Get method" {
                (Get-TargetResource @testParams).TLS12State | Should Be 'Default'
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should update eight registry keys in the Set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Set-SChannelRegKeyValue -Times 8
            }
        }

        Context -Name "When the TLS 1.2 is set to default and should be (.Net 4.5 or lower)" -Fixture {
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

            It "Should return TLS12State=Default from the Get method" {
                (Get-TargetResource @testParams).TLS12State | Should Be 'Default'
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should Be $true
            }
        }

        Context -Name "When the TLS 1.2 is set to Enabled and should be Default (.Net 4.5 or lower)" -Fixture {
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

            It "Should return TLS12State=Default from the Get method" {
                (Get-TargetResource @testParams).TLS12State | Should Be 'Enabled'
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should update eight registry keys in the Set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Set-SChannelRegKeyValue -Times 8
            }
        }

        Context -Name "When the TLS 1.2 is set to default, but .Net 4.6 or higher is used" -Fixture {
            $testParams = @{
                IsSingleInstance = 'Yes'
                TLS12State       = 'Enabled'
            }

            Mock -CommandName Get-ItemProperty -MockWith {
                return '58000'
            }

            Mock -CommandName Get-ItemPropertyValue -MockWith {
                return '58000'
            }

            Mock -CommandName Test-Path -MockWith {
                return $true
            }

            Mock -CommandName Get-SChannelRegKeyValue -MockWith {}
            Mock -CommandName Set-SChannelRegKeyValue -MockWith {}

            It "Should return TLS12State=Null from the Get method" {
                (Get-TargetResource @testParams).TLS12State | Should BeNullOrEmpty
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should Be $true
            }

            It "Should update no registry keys in the Set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Set-SChannelRegKeyValue -Times 0
            }
        }

        Context -Name "When the DH Key Size is absent, but should be 4096" -Fixture {
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

            It "Should return DHKeySizes=Null from the Get method" {
                $result = Get-TargetResource @testParams
                $result.DiffieHellmanMinClientKeySize | Should BeNullOrEmpty
                $result.DiffieHellmanMinServerKeySize | Should BeNullOrEmpty
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should update two registry keys in the Set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Set-SChannelRegKeyValue -Times 2
            }
        }

        Context -Name "When the DH Key Size is 1024, but should be 4096" -Fixture {
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

            It "Should return DHKeySizes=Null from the Get method" {
                $result = Get-TargetResource @testParams
                $result.DiffieHellmanMinClientKeySize | Should Be 1024
                $result.DiffieHellmanMinServerKeySize | Should Be 1024
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should update two registry keys in the Set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Set-SChannelRegKeyValue -Times 2
            }
        }

        Context -Name "When the DH Key Size is 4096 and should be 4096" -Fixture {
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

            It "Should return DHKeySizes=Null from the Get method" {
                $result = Get-TargetResource @testParams
                $result.DiffieHellmanMinClientKeySize | Should Be 4096
                $result.DiffieHellmanMinServerKeySize | Should Be 4096
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should Be $true
            }
        }

        Context -Name "When the FIPSPolicy is Disabled, but should be Enabled" -Fixture {
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

            It "Should return FipsPolicy=False from the Get method" {
                $result = Get-TargetResource @testParams
                $result.EnableFIPSAlgorithmPolicy | Should Be $false
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should update one registry key in the Set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Set-SChannelRegKeyValue -Times 1
            }
        }


        Context -Name "When the FIPSPolicy is Enabled and should be" -Fixture {
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

            It "Should return FipsPolicy=True from the Get method" {
                $result = Get-TargetResource @testParams
                $result.EnableFIPSAlgorithmPolicy | Should Be $true
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should Be $true
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:SCDscHelper.CleanupScript -NoNewScope
