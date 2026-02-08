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

Describe 'Disable-TlsProtocol' -Tag 'Public' {
    It 'Should have the correct parameters in parameter set <ExpectedParameterSetName>' -ForEach @(
        @{
            ExpectedParameterSetName = '__AllParameterSets'
            ExpectedParameters       = '[-Protocol] <SChannelSslProtocols[]> [-Client] [-SetDisabledByDefault] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]'
        }
    ) {
        $result = (Get-Command -Name 'Disable-TlsProtocol').ParameterSets |
            Where-Object -FilterScript { $_.Name -eq $ExpectedParameterSetName } |
            Select-Object -Property @(
                @{ Name = 'ParameterSetName'; Expression = { $_.Name } },
                @{ Name = 'ParameterListAsString'; Expression = { $_.ToString() } }
            )

        $result.ParameterSetName | Should -Be $ExpectedParameterSetName
        $result.ParameterListAsString | Should -Be $ExpectedParameters
    }

    Context 'When disabling a protocol' {
        BeforeAll {
            Mock -CommandName Set-TlsProtocolRegistryValue
        }

        It 'Should call Set-TlsProtocolRegistryValue with Disable switch' {
            $null = Disable-TlsProtocol -Protocol Ssl3 -Force

            Should -Invoke -CommandName Set-TlsProtocolRegistryValue -ParameterFilter {
                $Protocol -contains 'Ssl3' -and
                $Disable -eq $true -and
                $Force -eq $true
            } -Exactly -Times 1 -Scope It
        }
    }

    Context 'When disabling a protocol for Client and setting DisabledByDefault' {
        BeforeAll {
            Mock -CommandName Set-TlsProtocolRegistryValue
        }

        It 'Should pass Client and SetDisabledByDefault to Set-TlsProtocolRegistryValue' {
            $null = Disable-TlsProtocol -Protocol Ssl3 -Client -SetDisabledByDefault -Force

            Should -Invoke -CommandName Set-TlsProtocolRegistryValue -ParameterFilter {
                $Protocol -contains 'Ssl3' -and
                $Disable -eq $true -and
                $Client -eq $true -and
                $SetDisabledByDefault -eq $true -and
                $Force -eq $true
            } -Exactly -Times 1 -Scope It
        }
    }

    Context 'When disabling multiple protocols' {
        BeforeAll {
            Mock -CommandName Set-TlsProtocolRegistryValue
        }

        It 'Should pass all protocols to Set-TlsProtocolRegistryValue' {
            $null = Disable-TlsProtocol -Protocol @(
                'Ssl2'
                'Ssl3'
            ) -Force

            Should -Invoke -CommandName Set-TlsProtocolRegistryValue -ParameterFilter {
                $Protocol.Count -eq 2 -and
                $Disable -eq $true
            } -Exactly -Times 1 -Scope It
        }
    }

    Context 'When validating parameters' {
        BeforeAll {
            $commandInfo = Get-Command -Name 'Disable-TlsProtocol'
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

        It 'Should have SetDisabledByDefault defined as a switch parameter' {
            $parameterInfo = $commandInfo.Parameters['SetDisabledByDefault']

            $parameterInfo.ParameterType.Name | Should -Be 'SwitchParameter'
        }

        It 'Should have Force defined as a switch parameter' {
            $parameterInfo = $commandInfo.Parameters['Force']

            $parameterInfo.ParameterType.Name | Should -Be 'SwitchParameter'
        }
    }
}
