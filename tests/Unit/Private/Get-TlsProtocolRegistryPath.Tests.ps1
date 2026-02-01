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

Describe 'Get-TlsProtocolRegistryPath' -Tag 'Private' {
    Context 'When building the registry path for Server' {
        BeforeAll {
            Mock -CommandName ConvertTo-TlsProtocolRegistryKeyName -MockWith { 'TLS 1.2' }
            Mock -CommandName Get-TlsProtocolTargetRegistryName -MockWith { 'Server' }
        }

        It 'Should return server registry path for Tls12 by default' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $result = Get-TlsProtocolRegistryPath -Protocol 'Tls12'

                $expected = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server'
                $result | Should -Be $expected
            }
        }
    }

    Context 'When building the registry path for Client' {
        BeforeAll {
            Mock -CommandName ConvertTo-TlsProtocolRegistryKeyName -MockWith { 'TLS 1.2' }
            Mock -CommandName Get-TlsProtocolTargetRegistryName -MockWith { 'Client' }
        }

        It 'Should return client registry path' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $result = Get-TlsProtocolRegistryPath -Protocol 'Tls12' -Client

                $expected = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'
                $result | Should -Be $expected
            }
        }
    }
}
