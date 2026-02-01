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

Describe 'ConvertTo-TlsProtocolRegistryKeyName' -Tag 'Private' {
    BeforeDiscovery {
        . "$PSScriptRoot/../../../source/Enum/005.SChannelSslProtocols.ps1"

        $knownProtocolTestCases = @(
            @{
                Protocol = [SChannelSslProtocols]::Ssl2
                Expected = 'SSL 2.0'
            }
            @{
                Protocol = [SChannelSslProtocols]::Ssl3
                Expected = 'SSL 3.0'
            }
            @{
                Protocol = [SChannelSslProtocols]::Tls
                Expected = 'TLS 1.0'
            }
            @{
                Protocol = [SChannelSslProtocols]::Tls11
                Expected = 'TLS 1.1'
            }
            @{
                Protocol = [SChannelSslProtocols]::Tls12
                Expected = 'TLS 1.2'
            }
            @{
                Protocol = [SChannelSslProtocols]::Tls13
                Expected = 'TLS 1.3'
            }
            @{
                Protocol = [SChannelSslProtocols]::DTls1
                Expected = 'DTLS 1.0'
            }
            @{
                Protocol = [SChannelSslProtocols]::DTls12
                Expected = 'DTLS 1.2'
            }
        )
    }

    Context 'When converting known protocol enum values' {
        It 'Should map <Protocol> to <Expected>' -ForEach $knownProtocolTestCases {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $result = ConvertTo-TlsProtocolRegistryKeyName -Protocol $Protocol

                $result | Should -Be $Expected
            }
        }
    }
}
