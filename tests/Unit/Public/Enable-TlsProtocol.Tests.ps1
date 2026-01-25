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

Describe 'Enable-TlsProtocol' -Tag 'Public' {
    Context 'When enabling a protocol' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
        }

        It 'Should call New-Item and New-ItemProperty' {
            Enable-TlsProtocol -Protocol 'Tls12' -Force

            Should -Invoke -CommandName New-Item -Times 1
            Should -Invoke -CommandName New-ItemProperty -Times 1
        }
    }

    Context 'When enabling a protocol for Client and setting DisabledByDefault' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
        }

        It 'Should write DisabledByDefault and target Client path' {
            Enable-TlsProtocol -Protocol 'Tls12' -Client -SetDisabledByDefault -Force

            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'DisabledByDefault' -and $Value -eq 0 } -Exactly -Times 1
            Should -Invoke -CommandName New-Item -ParameterFilter { $Path -like '*\\Client' } -Exactly -Times 1
        }
    }

    Context 'When enabling without SetDisabledByDefault' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
        }

        It 'Should NOT write DisabledByDefault' {
            Enable-TlsProtocol -Protocol 'Tls12' -Force

            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'DisabledByDefault' } -Exactly -Times 0
            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'Enabled' -and $Value -eq 1 } -Exactly -Times 1
        }
    }

    Context 'When enabling a protocol for Server and setting DisabledByDefault' {
        BeforeAll {
            Mock -CommandName New-Item
            Mock -CommandName New-ItemProperty
        }

        It 'Should write DisabledByDefault and target Server path' {
            Enable-TlsProtocol -Protocol 'Tls12' -SetDisabledByDefault -Force

            Should -Invoke -CommandName New-ItemProperty -ParameterFilter { $Name -eq 'DisabledByDefault' -and $Value -eq 0 } -Exactly -Times 1
            Should -Invoke -CommandName New-Item -ParameterFilter { $Path -like '*\\Server' } -Exactly -Times 1
        }
    }
}
