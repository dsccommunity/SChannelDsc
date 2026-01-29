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
}

Describe 'Disable-TlsProtocol' -Tag 'Public' {
    It 'Should have the correct parameters in parameter set <ExpectedParameterSetName>' -ForEach @(
        @{
            ExpectedParameterSetName = '__AllParameterSets'
            ExpectedParameters = '[-Protocol] <SslProtocols[]> [-Client] [-SetDisabledByDefault] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]'
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
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
        }

        It 'Should call New-Item and New-ItemProperty' {
            Disable-TlsProtocol -Protocol ([System.Security.Authentication.SslProtocols]::Tls12) -Force

            Should -Invoke -CommandName New-Item -Times 1
            Should -Invoke -CommandName New-ItemProperty -Times 1
        }
    }

    Context 'When disabling without SetDisabledByDefault' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
        }

        It 'Should not write DisabledByDefault' {
            Disable-TlsProtocol -Protocol ([System.Security.Authentication.SslProtocols]::Tls12) -Force

            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'DisabledByDefault' } -Exactly -Times 0
            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'Enabled' -and $Value -eq 0 } -Exactly -Times 1
        }
    }

    Context 'When disabling a protocol for Client and setting DisabledByDefault' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
        }

        It 'Should write DisabledByDefault to 1 and target Client path' {
            Disable-TlsProtocol -Protocol ([System.Security.Authentication.SslProtocols]::Tls12) -Client -SetDisabledByDefault -Force

            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'DisabledByDefault' -and $Value -eq 1 } -Exactly -Times 1
            Should -Invoke -CommandName New-Item -ParameterFilter { $Path -like '*\\Client' } -Exactly -Times 1
        }
    }

    Context 'When disabling a protocol for Server and setting DisabledByDefault' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
        }

        It 'Should write DisabledByDefault to 1 and target Server path' {
            Disable-TlsProtocol -Protocol ([System.Security.Authentication.SslProtocols]::Tls12) -SetDisabledByDefault -Force

            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'DisabledByDefault' -and $Value -eq 1 } -Exactly -Times 1
            Should -Invoke -CommandName New-Item -ParameterFilter { $Path -like '*\\Server' } -Exactly -Times 1
        }
    }

    Context 'When New-Item fails to create the registry key' {
        BeforeAll {
            Mock -CommandName New-Item -MockWith { throw 'Failed to create registry key' }
            Mock -CommandName New-ItemProperty
        }

        It 'Should throw a terminating error when New-Item fails' {
            { Disable-TlsProtocol -Protocol ([System.Security.Authentication.SslProtocols]::Tls12) -Force } | Should -Throw -ErrorId 'DTP0002,Disable-TlsProtocol'
        }
    }

    Context 'When validating parameters' {
        BeforeAll {
            $script:commandInfo = Get-Command -Name 'Disable-TlsProtocol'
        }

        It 'Should have Protocol as a mandatory parameter' {
            $parameterInfo = $script:commandInfo.Parameters['Protocol']

            $parameterInfo.Attributes.Mandatory | Should -Contain $true
        }

        It 'Should have Protocol declared as an array type' {
            $parameterInfo = $script:commandInfo.Parameters['Protocol']

            $parameterInfo.ParameterType.IsArray | Should -BeTrue
        }

        It 'Should have Client as a non-mandatory parameter' {
            $parameterInfo = $script:commandInfo.Parameters['Client']

            $parameterInfo.Attributes.Mandatory | Should -Not -Contain $true
        }

        It 'Should have Client defined as a switch parameter' {
            $parameterInfo = $script:commandInfo.Parameters['Client']

            $parameterInfo.ParameterType.Name | Should -Be 'SwitchParameter'
        }

        It 'Should have SetDisabledByDefault defined as a switch parameter' {
            $parameterInfo = $script:commandInfo.Parameters['SetDisabledByDefault']

            $parameterInfo.ParameterType.Name | Should -Be 'SwitchParameter'
        }

        It 'Should have Force defined as a switch parameter' {
            $parameterInfo = $script:commandInfo.Parameters['Force']

            $parameterInfo.ParameterType.Name | Should -Be 'SwitchParameter'
        }
    }
}
