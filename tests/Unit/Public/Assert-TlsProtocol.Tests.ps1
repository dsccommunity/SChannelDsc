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
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks build" first.'
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

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:moduleName -All | Remove-Module -Force
}

Describe 'Assert-TlsProtocol' -Tag 'Public' {
    It 'Should have the correct parameters in parameter set <ExpectedParameterSetName>' -ForEach @(
        @{
            ExpectedParameterSetName = '__AllParameterSets'
            ExpectedParameters       = '[-Protocol] <SChannelSslProtocols[]> [-Client] [-Disabled] [<CommonParameters>]'
        }
    ) {
        $result = (Get-Command -Name 'Assert-TlsProtocol').ParameterSets |
            Where-Object -FilterScript { $_.Name -eq $ExpectedParameterSetName } |
            Select-Object -Property @(
                @{ Name = 'ParameterSetName'; Expression = { $_.Name } },
                @{ Name = 'ParameterListAsString'; Expression = { $_.ToString() } }
            )

        $result.ParameterSetName | Should -Be $ExpectedParameterSetName
        $result.ParameterListAsString | Should -Be $ExpectedParameters
    }

    Context 'When protocols are enabled' {
        BeforeAll {
            Mock -CommandName Test-TlsProtocol -MockWith { return $true }
        }

        It 'Should not throw' {
            $null = Assert-TlsProtocol -Protocol Tls12
        }
    }

    Context 'When protocols are enabled for Client' {
        BeforeAll {
            Mock -CommandName Test-TlsProtocol -MockWith { return $true }
        }

        It 'Should not throw and pass Client switch to Test-TlsProtocol' {
            $null = Assert-TlsProtocol -Protocol Tls12 -Client

            Should -Invoke -CommandName Test-TlsProtocol -ParameterFilter { $Client -eq $true } -Exactly -Times 1 -Scope It
        }
    }

    Context 'When asserting Disabled protocols' {
        Context 'When Test-TlsProtocol returns true for Disabled' {
            BeforeAll {
                Mock -CommandName Test-TlsProtocol -MockWith { return $true }
            }

            It 'Should not throw and pass Disabled switch to Test-TlsProtocol' {
                $null = Assert-TlsProtocol -Protocol Tls12 -Disabled

                Should -Invoke -CommandName Test-TlsProtocol -ParameterFilter { $Disabled -eq $true } -Exactly -Times 1 -Scope It
            }
        }

        Context 'When Test-TlsProtocol returns false for Disabled' {
            BeforeAll {
                Mock -CommandName Test-TlsProtocol -MockWith { return $false }
            }

            It 'Should throw and pass Disabled switch to Test-TlsProtocol' {
                { Assert-TlsProtocol -Protocol Tls12 -Disabled } | Should -Throw

                Should -Invoke -CommandName Test-TlsProtocol -ParameterFilter { $Disabled -eq $true } -Exactly -Times 1 -Scope It
            }
        }
    }

    Context 'When protocols are not enabled' {
        BeforeAll {
            Mock -CommandName Test-TlsProtocol -MockWith { return $false }
        }

        It 'Should throw' {
            { Assert-TlsProtocol -Protocol Tls12 } | Should -Throw
        }
    }

    Context 'When protocols are not enabled for Client' {
        BeforeAll {
            Mock -CommandName Test-TlsProtocol -MockWith { return $false }
        }

        It 'Should throw and pass Client switch to Test-TlsProtocol' {
            { Assert-TlsProtocol -Protocol Tls12 -Client } | Should -Throw

            Should -Invoke -CommandName Test-TlsProtocol -ParameterFilter { $Client -eq $true } -Exactly -Times 1 -Scope It
        }
    }

    Context 'When validating parameters' {
        BeforeAll {
            $commandInfo = Get-Command -Name 'Assert-TlsProtocol'
        }

        It 'Should have Protocol as a mandatory parameter' {
            $parameterInfo = $commandInfo.Parameters['Protocol']

            $parameterInfo.Attributes.Mandatory | Should -BeTrue
        }

        It 'Should have Protocol declared as an array type' {
            $parameterInfo = $commandInfo.Parameters['Protocol']

            $parameterInfo.ParameterType.IsArray | Should -BeTrue
        }

        It 'Should have Client as a non-mandatory parameter' {
            $parameterInfo = $commandInfo.Parameters['Client']

            $parameterInfo.Attributes.Mandatory | Should -BeFalse
        }

        It 'Should have Client defined as a switch parameter' {
            $parameterInfo = $commandInfo.Parameters['Client']

            $parameterInfo.ParameterType.Name | Should -Be 'SwitchParameter'
        }

        It 'Should have Disabled defined as a switch parameter' {
            $parameterInfo = $commandInfo.Parameters['Disabled']

            $parameterInfo.ParameterType.Name | Should -Be 'SwitchParameter'
        }
    }
}
