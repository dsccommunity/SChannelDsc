[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Suppressing this rule because Script Analyzer does not understand Pester syntax.')]
param ()

BeforeDiscovery {
    try
    {
        if (-not (Get-Module -Name 'DscResource.Test'))
        {
            if (-not (Get-Module -Name 'DscResource.Test' -ListAvailable))
            {
                & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 3>&1 4>&1 5>&1 6>&1 > $null
            }

            Import-Module -Name 'DscResource.Test' -Force -ErrorAction 'Stop'
        }
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks noop" first.'
    }
}

BeforeAll {
    $script:moduleName = 'SChannelDsc'

    Import-Module -Name $script:moduleName -ErrorAction 'Stop'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')
}

Describe 'Assert-TlsProtocol' -Tag 'Public' {
    Context 'When protocols are enabled' {
        BeforeAll {
            Mock -CommandName Test-TlsProtocol -MockWith { return $true }
        }

        It 'Should not throw an error' {
            $null = Assert-TlsProtocol -Protocol ([System.Security.Authentication.SslProtocols]::Tls12)
        }
    }

    Context 'When protocols are enabled for Client' {
        BeforeAll {
            Mock -CommandName Test-TlsProtocol -MockWith { return $true }
        }

        It 'Should not throw an error and pass Client switch' {
            $null = Assert-TlsProtocol -Protocol ([System.Security.Authentication.SslProtocols]::Tls12) -Client

            Should -Invoke -CommandName Test-TlsProtocol -ParameterFilter { $Client -eq $true } -Times 1
        }
    }

    Context 'When asserting Disabled protocols' {
        Context 'When Test-TlsProtocol returns true for Disabled' {
            BeforeAll {
                Mock -CommandName Test-TlsProtocol -MockWith { return $true }
            }

            It 'Should not throw an error and pass Disabled switch' {
                $null = Assert-TlsProtocol -Protocol ([System.Security.Authentication.SslProtocols]::Tls12) -Disabled

                Should -Invoke -CommandName Test-TlsProtocol -ParameterFilter { $Disabled -eq $true } -Times 1
            }
        }

        Context 'When Test-TlsProtocol returns false for Disabled' {
            BeforeAll {
                Mock -CommandName Test-TlsProtocol -MockWith { return $false }
            }

            It 'Should throw an error and pass Disabled switch' {
                { Assert-TlsProtocol -Protocol ([System.Security.Authentication.SslProtocols]::Tls12) -Disabled } | Should -Throw

                Should -Invoke -CommandName Test-TlsProtocol -ParameterFilter { $Disabled -eq $true } -Times 1
            }
        }
    }

    Context 'When protocols are not enabled' {
        BeforeAll {
            Mock -CommandName Test-TlsProtocol -MockWith { return $false }
        }

        It 'Should throw an error' {
            { Assert-TlsProtocol -Protocol ([System.Security.Authentication.SslProtocols]::Tls12) } | Should -Throw
        }
    }

    Context 'When protocols are not enabled for Client' {
        BeforeAll {
            Mock -CommandName Test-TlsProtocol -MockWith { return $false }
        }

        It 'Should throw an error and pass Client switch' {
            { Assert-TlsProtocol -Protocol ([System.Security.Authentication.SslProtocols]::Tls12) -Client } | Should -Throw

            Should -Invoke -CommandName Test-TlsProtocol -ParameterFilter { $Client -eq $true } -Times 1
        }
    }

    Context 'When validating parameters' {
        BeforeAll {
            $script:commandInfo = Get-Command -Name 'Assert-TlsProtocol'
        }

        It 'Should have parameter set __AllParameterSets' {
            $result = $script:commandInfo.ParameterSets |
                Where-Object -FilterScript { $_.Name -eq '__AllParameterSets' }

            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be '__AllParameterSets'
        }

        It 'Should have Protocol as a mandatory parameter' {
            $parameterInfo = $script:commandInfo.Parameters['Protocol']

            $parameterInfo.Attributes.Mandatory | Should -Contain $true
        }

        It 'Should have Client defined as a switch parameter' {
            $parameterInfo = $script:commandInfo.Parameters['Client']

            $parameterInfo.ParameterType.Name | Should -Be 'SwitchParameter'
        }

        It 'Should have Disabled defined as a switch parameter' {
            $parameterInfo = $script:commandInfo.Parameters['Disabled']

            $parameterInfo.ParameterType.Name | Should -Be 'SwitchParameter'
        }
    }
}
