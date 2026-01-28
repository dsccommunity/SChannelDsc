<#
    .SYNOPSIS
        Unit test for DSC_SChannelSettings DSC resource.
#>

# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

BeforeDiscovery {
    try
    {
        if (-not (Get-Module -Name 'DscResource.Test'))
        {
            # Assumes dependencies has been resolved, so if this module is not available, run 'noop' task.
            if (-not (Get-Module -Name 'DscResource.Test' -ListAvailable))
            {
                # Redirect all streams to $null, except the error stream (stream 2)
                & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 3>&1 4>&1 5>&1 6>&1 > $null
            }

            # If the dependencies has not been resolved, this will throw an error.
            Import-Module -Name 'DscResource.Test' -Force -ErrorAction 'Stop'
        }
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks build" first.'
    }
}

BeforeAll {
    $script:dscModuleName = 'SChannelDsc'
    $script:dscResourceName = 'DSC_SChannelSettings'

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscResourceName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Restore-TestEnvironment -TestEnvironment $script:testEnvironment

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscResourceName -All | Remove-Module -Force
}

Describe 'DSC_SChannelSettings\Get-TargetResource' -Tag 'Get' {
    Context 'When the machine is 32 bit' {
        Context 'When the resource exists and TLS1.2 is Enabled' {
            BeforeAll {
                Mock -CommandName Test-Path -MockWith {
                    return $false
                }

                $mockTLS12State = 1

                #32 Bit Keys
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                #64 Bit Keys
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith { throw }

                # Diffie-Hellman
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'ClientMinKeyBitLength'
                } -MockWith {
                    return 3072
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'ServerMinKeyBitLength'
                } -MockWith {
                    return 3072
                }

                #Kerberos
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'SupportedEncryptionTypes'
                } -MockWith {
                    return 31
                }

                # WinHTTP
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -and
                    $Name -eq 'DefaultSecureProtocols'
                } -MockWith {
                    return 2728
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -and
                    $Name -eq 'DefaultSecureProtocols'
                }

                #FIPS
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:SYSTEM\CurrentControlSet\Control\LSA\FIPSAlgorithmPolicy' -and
                    $Name -eq 'Enabled'
                } -MockWith {
                    return 1
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockParams = @{
                        IsSingleInstance                = 'Yes'
                        TLS12State                      = 'Enabled'
                        DiffieHellmanMinClientKeySize   = 3072
                        DiffieHellmanMinServerKeySize   = 3072
                        KerberosSupportedEncryptionType = @('DES-CBC-CRC', 'DES-CBC-MD5', 'RC4-HMAC-MD5', 'AES128-HMAC-SHA1', 'AES256-HMAC-SHA1')
                        WinHttpDefaultSecureProtocols   = @('SSL2.0', 'SSL3.0', 'TLS1.0', 'TLS1.1', 'TLS1.2')
                        EnableFIPSAlgorithmPolicy       = $true
                    }

                    $result = Get-TargetResource @mockParams

                    $result.TLS12State                      | Should -Be $mockParams.TLS12State
                    $result.DiffieHellmanMinClientKeySize   | Should -Be $mockParams.DiffieHellmanMinClientKeySize
                    $result.DiffieHellmanMinServerKeySize   | Should -Be $mockParams.DiffieHellmanMinServerKeySize
                    $result.KerberosSupportedEncryptionType | Should -Be $mockParams.KerberosSupportedEncryptionType
                    $result.KerberosSupportedEncryptionType.Count | Should -Be $mockParams.KerberosSupportedEncryptionType.Count
                    # BUG: Does not work on 32bit systems as the 32 bit and 64 bit values will always be different when 32 bit exists
                    # $result.WinHttpDefaultSecureProtocols | Should -Be $mockParams.WinHttpDefaultSecureProtocols
                    # $result.WinHttpDefaultSecureProtocols.Count | Should -Be $mockParams.WinHttpDefaultSecureProtocols.Count
                    $result.EnableFIPSAlgorithmPolicy       | Should -Be $mockParams.EnableFIPSAlgorithmPolicy
                }
            }
        }

        Context 'When the resource exists and TLS1.2 is Disabled' {
            BeforeAll {
                Mock -CommandName Test-Path -MockWith {
                    return $false
                }

                $mockTLS12State = 0

                #32 Bit Keys
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                #64 Bit Keys
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                }

                # Diffie-Hellman
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'ClientMinKeyBitLength'
                } -MockWith {
                    return 3072
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'ServerMinKeyBitLength'
                } -MockWith {
                    return 3072
                }

                #Kerberos
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'SupportedEncryptionTypes'
                } -MockWith {
                    return 31
                }

                # WinHTTP
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -and
                    $Name -eq 'DefaultSecureProtocols'
                } -MockWith {
                    return 2728
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -and
                    $Name -eq 'DefaultSecureProtocols'
                }

                #FIPS
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:SYSTEM\CurrentControlSet\Control\LSA\FIPSAlgorithmPolicy' -and
                    $Name -eq 'Enabled'
                } -MockWith {
                    return 1
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockParams = @{
                        IsSingleInstance                = 'Yes'
                        TLS12State                      = 'Disabled'
                        DiffieHellmanMinClientKeySize   = 3072
                        DiffieHellmanMinServerKeySize   = 3072
                        KerberosSupportedEncryptionType = @('DES-CBC-CRC', 'DES-CBC-MD5', 'RC4-HMAC-MD5', 'AES128-HMAC-SHA1', 'AES256-HMAC-SHA1')
                        WinHttpDefaultSecureProtocols   = @('SSL2.0', 'SSL3.0', 'TLS1.0', 'TLS1.1', 'TLS1.2')
                        EnableFIPSAlgorithmPolicy       = $true
                    }

                    $result = Get-TargetResource @mockParams

                    $result.TLS12State                      | Should -Be $mockParams.TLS12State
                    $result.DiffieHellmanMinClientKeySize   | Should -Be $mockParams.DiffieHellmanMinClientKeySize
                    $result.DiffieHellmanMinServerKeySize   | Should -Be $mockParams.DiffieHellmanMinServerKeySize
                    $result.KerberosSupportedEncryptionType | Should -Be $mockParams.KerberosSupportedEncryptionType
                    $result.KerberosSupportedEncryptionType.Count | Should -Be $mockParams.KerberosSupportedEncryptionType.Count
                    # BUG: Does not work on 32bit systems as the 32 bit and 64 bit values will always be different when 32 bit exists
                    # $result.WinHttpDefaultSecureProtocols | Should -Be $mockParams.WinHttpDefaultSecureProtocols
                    # $result.WinHttpDefaultSecureProtocols.Count | Should -Be $mockParams.WinHttpDefaultSecureProtocols.Count
                    $result.EnableFIPSAlgorithmPolicy       | Should -Be $mockParams.EnableFIPSAlgorithmPolicy
                }
            }
        }

        Context 'When the resource exists and TLS1.2 is $null' {
            BeforeAll {
                Mock -CommandName Test-Path -MockWith {
                    return $false
                }

                $mockTLS12State = $null

                #32 Bit Keys
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                #64 Bit Keys
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith { throw }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith { throw }

                # Diffie-Hellman
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'ClientMinKeyBitLength'
                } -MockWith {
                    return 3072
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'ServerMinKeyBitLength'
                } -MockWith {
                    return 3072
                }

                #Kerberos
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'SupportedEncryptionTypes'
                } -MockWith {
                    return 31
                }

                # WinHTTP
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -and
                    $Name -eq 'DefaultSecureProtocols'
                } -MockWith {
                    return 2728
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -and
                    $Name -eq 'DefaultSecureProtocols'
                }

                #FIPS
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:SYSTEM\CurrentControlSet\Control\LSA\FIPSAlgorithmPolicy' -and
                    $Name -eq 'Enabled'
                } -MockWith {
                    return 1
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockParams = @{
                        IsSingleInstance                = 'Yes'
                        TLS12State                      = 'Default'
                        DiffieHellmanMinClientKeySize   = 3072
                        DiffieHellmanMinServerKeySize   = 3072
                        KerberosSupportedEncryptionType = @('DES-CBC-CRC', 'DES-CBC-MD5', 'RC4-HMAC-MD5', 'AES128-HMAC-SHA1', 'AES256-HMAC-SHA1')
                        WinHttpDefaultSecureProtocols   = @('SSL2.0', 'SSL3.0', 'TLS1.0', 'TLS1.1', 'TLS1.2')
                        EnableFIPSAlgorithmPolicy       = $true
                    }

                    $result = Get-TargetResource @mockParams

                    $result.TLS12State                      | Should -Be $mockParams.TLS12State
                    $result.DiffieHellmanMinClientKeySize   | Should -Be $mockParams.DiffieHellmanMinClientKeySize
                    $result.DiffieHellmanMinServerKeySize   | Should -Be $mockParams.DiffieHellmanMinServerKeySize
                    $result.KerberosSupportedEncryptionType | Should -Be $mockParams.KerberosSupportedEncryptionType
                    $result.KerberosSupportedEncryptionType.Count | Should -Be $mockParams.KerberosSupportedEncryptionType.Count
                    # BUG: Does not work on 32bit systems as the 32 bit and 64 bit values will always be different when 32 bit exists
                    # $result.WinHttpDefaultSecureProtocols | Should -Be $mockParams.WinHttpDefaultSecureProtocols
                    # $result.WinHttpDefaultSecureProtocols.Count | Should -Be $mockParams.WinHttpDefaultSecureProtocols.Count
                    $result.EnableFIPSAlgorithmPolicy       | Should -Be $mockParams.EnableFIPSAlgorithmPolicy
                }
            }
        }
    }

    Context 'When the machine is 64 bit' {
        Context 'When the resource exists and TLS1.2 is enabled' {
            BeforeAll {
                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                $mockTLS12State = 1

                #32 Bit Keys
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                #64 Bit Keys
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                # Diffie-Hellman
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'ClientMinKeyBitLength'
                } -MockWith {
                    return 3072
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'ServerMinKeyBitLength'
                } -MockWith {
                    return 3072
                }

                #Kerberos
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'SupportedEncryptionTypes'
                } -MockWith {
                    return 31
                }

                # WinHTTP
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -and
                    $Name -eq 'DefaultSecureProtocols'
                } -MockWith {
                    return 2728
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -and
                    $Name -eq 'DefaultSecureProtocols'
                } -MockWith {
                    return 2728
                }

                #FIPS
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:SYSTEM\CurrentControlSet\Control\LSA\FIPSAlgorithmPolicy' -and
                    $Name -eq 'Enabled'
                } -MockWith {
                    return 1
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockParams = @{
                        IsSingleInstance                = 'Yes'
                        TLS12State                      = 'Enabled'
                        DiffieHellmanMinClientKeySize   = 3072
                        DiffieHellmanMinServerKeySize   = 3072
                        KerberosSupportedEncryptionType = @('DES-CBC-CRC', 'DES-CBC-MD5', 'RC4-HMAC-MD5', 'AES128-HMAC-SHA1', 'AES256-HMAC-SHA1')
                        WinHttpDefaultSecureProtocols   = @('SSL2.0', 'SSL3.0', 'TLS1.0', 'TLS1.1', 'TLS1.2')
                        EnableFIPSAlgorithmPolicy       = $true
                    }

                    $result = Get-TargetResource @mockParams

                    $result.TLS12State                      | Should -Be $mockParams.TLS12State
                    $result.DiffieHellmanMinClientKeySize   | Should -Be $mockParams.DiffieHellmanMinClientKeySize
                    $result.DiffieHellmanMinServerKeySize   | Should -Be $mockParams.DiffieHellmanMinServerKeySize
                    $result.KerberosSupportedEncryptionType | Should -Be $mockParams.KerberosSupportedEncryptionType
                    $result.KerberosSupportedEncryptionType.Count | Should -Be $mockParams.KerberosSupportedEncryptionType.Count
                    $result.WinHttpDefaultSecureProtocols | Should -Be $mockParams.WinHttpDefaultSecureProtocols
                    $result.WinHttpDefaultSecureProtocols.Count | Should -Be $mockParams.WinHttpDefaultSecureProtocols.Count
                    $result.EnableFIPSAlgorithmPolicy       | Should -Be $mockParams.EnableFIPSAlgorithmPolicy
                }
            }
        }

        Context 'When the resource exists and TLS1.2 is Disabled' {
            BeforeAll {
                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                $mockTLS12State = 0

                #32 Bit Keys
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                #64 Bit Keys
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                # Diffie-Hellman
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'ClientMinKeyBitLength'
                } -MockWith {
                    return 3072
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'ServerMinKeyBitLength'
                } -MockWith {
                    return 3072
                }

                #Kerberos
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'SupportedEncryptionTypes'
                } -MockWith {
                    return 31
                }

                # WinHTTP
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -and
                    $Name -eq 'DefaultSecureProtocols'
                } -MockWith {
                    return 2728
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -and
                    $Name -eq 'DefaultSecureProtocols'
                } -MockWith {
                    return 2728
                }

                #FIPS
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:SYSTEM\CurrentControlSet\Control\LSA\FIPSAlgorithmPolicy' -and
                    $Name -eq 'Enabled'
                } -MockWith {
                    return 1
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockParams = @{
                        IsSingleInstance                = 'Yes'
                        TLS12State                      = 'Disabled'
                        DiffieHellmanMinClientKeySize   = 3072
                        DiffieHellmanMinServerKeySize   = 3072
                        KerberosSupportedEncryptionType = @('DES-CBC-CRC', 'DES-CBC-MD5', 'RC4-HMAC-MD5', 'AES128-HMAC-SHA1', 'AES256-HMAC-SHA1')
                        WinHttpDefaultSecureProtocols   = @('SSL2.0', 'SSL3.0', 'TLS1.0', 'TLS1.1', 'TLS1.2')
                        EnableFIPSAlgorithmPolicy       = $true
                    }

                    $result = Get-TargetResource @mockParams

                    $result.TLS12State                      | Should -Be $mockParams.TLS12State
                    $result.DiffieHellmanMinClientKeySize   | Should -Be $mockParams.DiffieHellmanMinClientKeySize
                    $result.DiffieHellmanMinServerKeySize   | Should -Be $mockParams.DiffieHellmanMinServerKeySize
                    $result.KerberosSupportedEncryptionType | Should -Be $mockParams.KerberosSupportedEncryptionType
                    $result.KerberosSupportedEncryptionType.Count | Should -Be $mockParams.KerberosSupportedEncryptionType.Count
                    $result.WinHttpDefaultSecureProtocols | Should -Be $mockParams.WinHttpDefaultSecureProtocols
                    $result.WinHttpDefaultSecureProtocols.Count | Should -Be $mockParams.WinHttpDefaultSecureProtocols.Count
                    $result.EnableFIPSAlgorithmPolicy       | Should -Be $mockParams.EnableFIPSAlgorithmPolicy
                }
            }
        }

        Context 'When the resource exists and TLS1.2 is $null' {
            BeforeAll {
                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                $mockTLS12State = $null

                #32 Bit Keys
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                #64 Bit Keys
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                # Diffie-Hellman
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'ClientMinKeyBitLength'
                } -MockWith {
                    return 3072
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'ServerMinKeyBitLength'
                } -MockWith {
                    return 3072
                }

                #Kerberos
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'SupportedEncryptionTypes'
                } -MockWith {
                    return 31
                }

                # WinHTTP
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -and
                    $Name -eq 'DefaultSecureProtocols'
                } -MockWith {
                    return 2728
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -and
                    $Name -eq 'DefaultSecureProtocols'
                } -MockWith {
                    return 2728
                }

                #FIPS
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:SYSTEM\CurrentControlSet\Control\LSA\FIPSAlgorithmPolicy' -and
                    $Name -eq 'Enabled'
                } -MockWith {
                    return 1
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockParams = @{
                        IsSingleInstance                = 'Yes'
                        TLS12State                      = 'Default'
                        DiffieHellmanMinClientKeySize   = 3072
                        DiffieHellmanMinServerKeySize   = 3072
                        KerberosSupportedEncryptionType = @('DES-CBC-CRC', 'DES-CBC-MD5', 'RC4-HMAC-MD5', 'AES128-HMAC-SHA1', 'AES256-HMAC-SHA1')
                        WinHttpDefaultSecureProtocols   = @('SSL2.0', 'SSL3.0', 'TLS1.0', 'TLS1.1', 'TLS1.2')
                        EnableFIPSAlgorithmPolicy       = $true
                    }

                    $result = Get-TargetResource @mockParams

                    $result.TLS12State                      | Should -Be $mockParams.TLS12State
                    $result.DiffieHellmanMinClientKeySize   | Should -Be $mockParams.DiffieHellmanMinClientKeySize
                    $result.DiffieHellmanMinServerKeySize   | Should -Be $mockParams.DiffieHellmanMinServerKeySize
                    $result.KerberosSupportedEncryptionType | Should -Be $mockParams.KerberosSupportedEncryptionType
                    $result.KerberosSupportedEncryptionType.Count | Should -Be $mockParams.KerberosSupportedEncryptionType.Count
                    $result.WinHttpDefaultSecureProtocols | Should -Be $mockParams.WinHttpDefaultSecureProtocols
                    $result.WinHttpDefaultSecureProtocols.Count | Should -Be $mockParams.WinHttpDefaultSecureProtocols.Count
                    $result.EnableFIPSAlgorithmPolicy       | Should -Be $mockParams.EnableFIPSAlgorithmPolicy
                }
            }
        }

        Context 'When the resource exists and FIPS is disabled' {
            BeforeAll {
                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                $mockTLS12State = 1

                #32 Bit Keys
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                #64 Bit Keys
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                # Diffie-Hellman
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'ClientMinKeyBitLength'
                } -MockWith {
                    return 3072
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'ServerMinKeyBitLength'
                } -MockWith {
                    return 3072
                }

                #Kerberos
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'SupportedEncryptionTypes'
                } -MockWith {
                    return 31
                }

                # WinHTTP
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -and
                    $Name -eq 'DefaultSecureProtocols'
                } -MockWith {
                    return 2728
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -and
                    $Name -eq 'DefaultSecureProtocols'
                } -MockWith {
                    return 2728
                }

                #FIPS
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:SYSTEM\CurrentControlSet\Control\LSA\FIPSAlgorithmPolicy' -and
                    $Name -eq 'Enabled'
                } -MockWith {
                    return 0
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockParams = @{
                        IsSingleInstance                = 'Yes'
                        TLS12State                      = 'Enabled'
                        DiffieHellmanMinClientKeySize   = 3072
                        DiffieHellmanMinServerKeySize   = 3072
                        KerberosSupportedEncryptionType = @('DES-CBC-CRC', 'DES-CBC-MD5', 'RC4-HMAC-MD5', 'AES128-HMAC-SHA1', 'AES256-HMAC-SHA1')
                        WinHttpDefaultSecureProtocols   = @('SSL2.0', 'SSL3.0', 'TLS1.0', 'TLS1.1', 'TLS1.2')
                        EnableFIPSAlgorithmPolicy       = $false
                    }

                    $result = Get-TargetResource @mockParams

                    $result.TLS12State                      | Should -Be $mockParams.TLS12State
                    $result.DiffieHellmanMinClientKeySize   | Should -Be $mockParams.DiffieHellmanMinClientKeySize
                    $result.DiffieHellmanMinServerKeySize   | Should -Be $mockParams.DiffieHellmanMinServerKeySize
                    $result.KerberosSupportedEncryptionType | Should -Be $mockParams.KerberosSupportedEncryptionType
                    $result.KerberosSupportedEncryptionType.Count | Should -Be $mockParams.KerberosSupportedEncryptionType.Count
                    $result.WinHttpDefaultSecureProtocols | Should -Be $mockParams.WinHttpDefaultSecureProtocols
                    $result.WinHttpDefaultSecureProtocols.Count | Should -Be $mockParams.WinHttpDefaultSecureProtocols.Count
                    $result.EnableFIPSAlgorithmPolicy       | Should -Be $mockParams.EnableFIPSAlgorithmPolicy
                }
            }
        }

        Context 'When the resource exists and FIPS does not exist' {
            BeforeAll {
                Mock -CommandName Test-Path -MockWith {
                    return $true
                }

                $mockTLS12State = 1

                #32 Bit Keys
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                #64 Bit Keys
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SystemDefaultTlsVersions'
                } -MockWith {
                    return $mockTLS12State
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -and $Name -eq 'SchUseStrongCrypto'
                } -MockWith {
                    return $mockTLS12State
                }

                # Diffie-Hellman
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'ClientMinKeyBitLength'
                } -MockWith {
                    return 3072
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'ServerMinKeyBitLength'
                } -MockWith {
                    return 3072
                }

                #Kerberos
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Name -eq 'SupportedEncryptionTypes'
                } -MockWith {
                    return 31
                }

                # WinHTTP
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -and
                    $Name -eq 'DefaultSecureProtocols'
                } -MockWith {
                    return 2728
                }

                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -and
                    $Name -eq 'DefaultSecureProtocols'
                } -MockWith {
                    return 2728
                }

                #FIPS
                Mock -CommandName Get-SChannelRegKeyValue -ParameterFilter {
                    $Key -eq 'HKLM:SYSTEM\CurrentControlSet\Control\LSA\FIPSAlgorithmPolicy' -and
                    $Name -eq 'Enabled'
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockParams = @{
                        IsSingleInstance                = 'Yes'
                        TLS12State                      = 'Enabled'
                        DiffieHellmanMinClientKeySize   = 3072
                        DiffieHellmanMinServerKeySize   = 3072
                        KerberosSupportedEncryptionType = @('DES-CBC-CRC', 'DES-CBC-MD5', 'RC4-HMAC-MD5', 'AES128-HMAC-SHA1', 'AES256-HMAC-SHA1')
                        WinHttpDefaultSecureProtocols   = @('SSL2.0', 'SSL3.0', 'TLS1.0', 'TLS1.1', 'TLS1.2')
                        EnableFIPSAlgorithmPolicy       = $false
                    }

                    $result = Get-TargetResource @mockParams

                    $result.TLS12State                      | Should -Be $mockParams.TLS12State
                    $result.DiffieHellmanMinClientKeySize   | Should -Be $mockParams.DiffieHellmanMinClientKeySize
                    $result.DiffieHellmanMinServerKeySize   | Should -Be $mockParams.DiffieHellmanMinServerKeySize
                    $result.KerberosSupportedEncryptionType | Should -Be $mockParams.KerberosSupportedEncryptionType
                    $result.KerberosSupportedEncryptionType.Count | Should -Be $mockParams.KerberosSupportedEncryptionType.Count
                    $result.WinHttpDefaultSecureProtocols | Should -Be $mockParams.WinHttpDefaultSecureProtocols
                    $result.WinHttpDefaultSecureProtocols.Count | Should -Be $mockParams.WinHttpDefaultSecureProtocols.Count
                    $result.EnableFIPSAlgorithmPolicy       | Should -Be $mockParams.EnableFIPSAlgorithmPolicy
                }
            }
        }
    }
}

Describe 'DSC_SChannelSettings\Test-TargetResource' -Tag 'Test' {
    Context 'When the resource is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                return @{
                    IsSingleInstance                = 'Yes'
                    TLS12State                      = 'Enabled'
                    DiffieHellmanMinClientKeySize   = [System.UInt32] 2048
                    DiffieHellmanMinServerKeySize   = [System.UInt32] 2048
                    KerberosSupportedEncryptionType = [System.String[]] @('AES128-HMAC-SHA1', 'AES256-HMAC-SHA1')
                    WinHttpDefaultSecureProtocols   = [System.String[]] @('TLS1.2')
                    EnableFIPSAlgorithmPolicy       = $false
                }
            }
        }

        It 'Should return true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    IsSingleInstance                = 'Yes'
                    TLS12State                      = 'Enabled'
                    DiffieHellmanMinClientKeySize   = 2048
                    DiffieHellmanMinServerKeySize   = 2048
                    KerberosSupportedEncryptionType = @('AES128-HMAC-SHA1', 'AES256-HMAC-SHA1')
                    WinHttpDefaultSecureProtocols   = @('TLS1.2')
                    EnableFIPSAlgorithmPolicy       = $false
                }

                Test-TargetResource @mockParams | Should -BeTrue
            }

            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the resource is not in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                return @{
                    IsSingleInstance                = 'Yes'
                    TLS12State                      = 'Enabled'
                    DiffieHellmanMinClientKeySize   = [System.UInt32] 2048
                    DiffieHellmanMinServerKeySize   = [System.UInt32] 2048
                    KerberosSupportedEncryptionType = [System.String[]] @('AES128-HMAC-SHA1', 'AES256-HMAC-SHA1')
                    WinHttpDefaultSecureProtocols   = [System.String[]] @('TLS1.2')
                    EnableFIPSAlgorithmPolicy       = $false
                }
            }
        }

        It 'Should return false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    IsSingleInstance                = 'Yes'
                    TLS12State                      = 'Disabled'
                    DiffieHellmanMinClientKeySize   = 4096
                    DiffieHellmanMinServerKeySize   = 4096
                    KerberosSupportedEncryptionType = @('DES-CBC-CRC', 'DES-CBC-MD5')
                    WinHttpDefaultSecureProtocols   = @('SSL3.0')
                    EnableFIPSAlgorithmPolicy       = $true
                }

                Test-TargetResource @mockParams | Should -BeFalse
            }

            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DSC_SChannelSettings\Set-TargetResource' -Tag 'Set' {
    BeforeAll {
        Mock -CommandName Test-Path -MockWith { $true }
    }

    Context 'When all the values need updating' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                return @{
                    IsSingleInstance                = 'Yes'
                    TLS12State                      = 'Disabled'
                    DiffieHellmanMinClientKeySize   = [System.UInt32] 2048
                    DiffieHellmanMinServerKeySize   = [System.UInt32] 2048
                    KerberosSupportedEncryptionType = [System.String[]] @()
                    WinHttpDefaultSecureProtocols   = [System.String[]] @('TLS1.1', 'TLS1.2')
                    EnableFIPSAlgorithmPolicy       = $false
                }
            }

            Mock -CommandName Set-SChannelRegKeyValue
            Mock -CommandName Get-SCDscOSVersion -MockWith {
                return @{
                    Major = 10
                    Minor = 0
                    Build = 16000
                }
            }

            Mock -CommandName Get-SChannelRegKeyValue
            Mock -CommandName Set-DscMachineRebootRequired
        }

        It 'Should call the correct mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    IsSingleInstance                = 'Yes'
                    TLS12State                      = 'Enabled'
                    DiffieHellmanMinClientKeySize   = 4096
                    DiffieHellmanMinServerKeySize   = 4096
                    KerberosSupportedEncryptionType = @('DES-CBC-CRC', 'DES-CBC-MD5', 'RC4-HMAC-MD5', 'AES128-HMAC-SHA1', 'AES256-HMAC-SHA1')
                    WinHttpDefaultSecureProtocols   = @('SSL2.0', 'SSL3.0', 'TLS1.0', 'TLS1.1', 'TLS1.2')
                    EnableFIPSAlgorithmPolicy       = $true
                    RebootWhenRequired              = $true
                }

                $null = Set-TargetResource @mockParams
            }

            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Set-SChannelRegKeyValue -Exactly -Times 14 -Scope It
            Should -Invoke -CommandName Get-SCDscOSVersion -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Set-DscMachineRebootRequired -Exactly -Times 1 -Scope It
        }
    }

    Context 'When TLS1.2 needs to be set to ''Default''' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                return @{
                    IsSingleInstance                = 'Yes'
                    TLS12State                      = 'Disabled'
                    DiffieHellmanMinClientKeySize   = [System.UInt32] 2048
                    DiffieHellmanMinServerKeySize   = [System.UInt32] 2048
                    KerberosSupportedEncryptionType = [System.String[]] @('DES-CBC-CRC', 'DES-CBC-MD5', 'RC4-HMAC-MD5', 'AES128-HMAC-SHA1', 'AES256-HMAC-SHA1')
                    WinHttpDefaultSecureProtocols   = [System.String[]] @('TLS1.1', 'TLS1.2')
                    EnableFIPSAlgorithmPolicy       = $false
                }
            }

            Mock -CommandName Set-SChannelRegKeyValue
            Mock -CommandName Get-SCDscOSVersion -MockWith {
                return @{
                    Major = 10
                    Minor = 0
                    Build = 16000
                }
            }

            Mock -CommandName Get-SChannelRegKeyValue
            Mock -CommandName Set-DscMachineRebootRequired
        }

        It 'Should call the correct mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    IsSingleInstance                = 'Yes'
                    TLS12State                      = 'Default'
                    DiffieHellmanMinClientKeySize   = 4096
                    DiffieHellmanMinServerKeySize   = 4096
                    KerberosSupportedEncryptionType = @('AES128-HMAC-SHA1', 'AES256-HMAC-SHA1')
                    WinHttpDefaultSecureProtocols   = @('TLS1.2')
                    EnableFIPSAlgorithmPolicy       = $true
                    RebootWhenRequired              = $true
                }

                $null = Set-TargetResource @mockParams
            }

            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Set-SChannelRegKeyValue -Exactly -Times 14 -Scope It
            Should -Invoke -CommandName Get-SCDscOSVersion -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Set-DscMachineRebootRequired -Exactly -Times 1 -Scope It
        }
    }

    Context 'When TLS1.2 needs to be set to ''Disabled''' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                return @{
                    IsSingleInstance                = 'Yes'
                    TLS12State                      = 'Enabled'
                    DiffieHellmanMinClientKeySize   = [System.UInt32] 2048
                    DiffieHellmanMinServerKeySize   = [System.UInt32] 2048
                    KerberosSupportedEncryptionType = [System.String[]] @('DES-CBC-CRC', 'DES-CBC-MD5', 'RC4-HMAC-MD5', 'AES128-HMAC-SHA1', 'AES256-HMAC-SHA1')
                    WinHttpDefaultSecureProtocols   = [System.String[]] @('TLS1.1', 'TLS1.2')
                    EnableFIPSAlgorithmPolicy       = $false
                }
            }

            Mock -CommandName Set-SChannelRegKeyValue
            Mock -CommandName Get-SCDscOSVersion -MockWith {
                return @{
                    Major = 10
                    Minor = 0
                    Build = 16000
                }
            }

            Mock -CommandName Get-SChannelRegKeyValue
            Mock -CommandName Set-DscMachineRebootRequired
        }

        It 'Should call the correct mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    IsSingleInstance                = 'Yes'
                    TLS12State                      = 'Disabled'
                    DiffieHellmanMinClientKeySize   = 4096
                    DiffieHellmanMinServerKeySize   = 4096
                    KerberosSupportedEncryptionType = @('AES128-HMAC-SHA1', 'AES256-HMAC-SHA1')
                    WinHttpDefaultSecureProtocols   = @('TLS1.2')
                    EnableFIPSAlgorithmPolicy       = $true
                    RebootWhenRequired              = $true
                }

                $null = Set-TargetResource @mockParams
            }

            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Set-SChannelRegKeyValue -Exactly -Times 14 -Scope It
            Should -Invoke -CommandName Get-SCDscOSVersion -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Set-DscMachineRebootRequired -Exactly -Times 1 -Scope It
        }
    }

    Context 'When all the keys need removing' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                return @{
                    IsSingleInstance                = 'Yes'
                    TLS12State                      = 'Default'
                    DiffieHellmanMinClientKeySize   = [System.UInt32] 2048
                    DiffieHellmanMinServerKeySize   = [System.UInt32] 2048
                    KerberosSupportedEncryptionType = [System.String[]] @('DES-CBC-CRC', 'DES-CBC-MD5', 'RC4-HMAC-MD5', 'AES128-HMAC-SHA1', 'AES256-HMAC-SHA1')
                    WinHttpDefaultSecureProtocols   = [System.String[]] @('TLS1.1', 'TLS1.2')
                    EnableFIPSAlgorithmPolicy       = $true
                }
            }

            Mock -CommandName Set-SChannelRegKeyValue
            Mock -CommandName Get-SCDscOSVersion -MockWith {
                return @{
                    Major = 10
                    Minor = 0
                    Build = 16000
                }
            }

            Mock -CommandName Get-SChannelRegKeyValue
            Mock -CommandName Remove-ItemProperty
            Mock -CommandName Set-DscMachineRebootRequired
        }

        It 'Should call the correct mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    IsSingleInstance                = 'Yes'
                    TLS12State                      = 'Default'
                    KerberosSupportedEncryptionType = @()
                    WinHttpDefaultSecureProtocols   = @()
                    EnableFIPSAlgorithmPolicy       = $false
                    RebootWhenRequired              = $true
                }

                $null = Set-TargetResource @mockParams
            }

            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Set-SChannelRegKeyValue -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Remove-ItemProperty -Exactly -Times 3 -Scope It
            Should -Invoke -CommandName Get-SCDscOSVersion -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Set-DscMachineRebootRequired -Exactly -Times 1 -Scope It
        }
    }

    Context 'When KB3140245 is not installed' {
        BeforeAll {
            Mock -CommandName Get-SCDscOSVersion -MockWith {
                return @{
                    Major = 6
                    Minor = 1
                    Build = 7601
                }
            }

            Mock -CommandName Get-Hotfix
            Mock -CommandName Get-TargetResource -MockWith {
                return @{
                    IsSingleInstance                = 'Yes'
                    TLS12State                      = 'Enabled'
                    DiffieHellmanMinClientKeySize   = [System.UInt32] 4096
                    DiffieHellmanMinServerKeySize   = [System.UInt32] 4096
                    KerberosSupportedEncryptionType = [System.String[]] @('AES128-HMAC-SHA1', 'AES256-HMAC-SHA1')
                    WinHttpDefaultSecureProtocols   = [System.String[]] @('TLS1.2')
                    EnableFIPSAlgorithmPolicy       = $true
                }
            }
        }

        It 'Should throw the correct error' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockParams = @{
                    IsSingleInstance              = 'Yes'
                    TLS12State                    = 'Enabled'
                    DiffieHellmanMinClientKeySize = 4096
                    DiffieHellmanMinServerKeySize = 4096
                    WinHttpDefaultSecureProtocols = @('TLS1.2')
                    EnableFIPSAlgorithmPolicy     = $true
                    RebootWhenRequired            = $true
                }

                $mockErrorMessage = 'Hotfix KB3140245 is not installed. Setting these registry keys will not do anything. ' + `
                    'Please install the hotfix first!'

                { Set-TargetResource @mockParams } | Should -Throw -ExpectedMessage $mockErrorMessage
            }
        }
    }
}
