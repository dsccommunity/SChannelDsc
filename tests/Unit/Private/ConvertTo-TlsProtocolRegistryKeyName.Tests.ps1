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

Describe 'ConvertTo-TlsProtocolRegistryKeyName' -Tag 'Private' {
    BeforeDiscovery {
        $knownProtocolTestCases = @(
            @{
                Protocol = [System.Security.Authentication.SslProtocols]::Tls12
                Expected = 'TLS 1.2'
            }
            @{
                Protocol = [System.Security.Authentication.SslProtocols]::Tls11
                Expected = 'TLS 1.1'
            }
            @{
                Protocol = [System.Security.Authentication.SslProtocols]::Tls
                Expected = 'TLS 1.0'
            }
            @{
                Protocol = [System.Security.Authentication.SslProtocols]::Ssl3
                Expected = 'SSL 3.0'
            }
            @{
                Protocol = [System.Security.Authentication.SslProtocols]::Ssl2
                Expected = 'SSL 2.0'
            }
            @{
                Protocol = [System.Security.Authentication.SslProtocols]::Tls13
                Expected = 'TLS 1.3'
            }
        )
    }

    Context 'When converting known protocol enum values' {
        It 'Should map <Protocol> to <Expected>' -ForEach $knownProtocolTestCases {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                ConvertTo-TlsProtocolRegistryKeyName -Protocol $Protocol | Should -Be $Expected
            }
        }
    }

    Context 'When given an unsupported protocol enum value' {
        It 'Should throw a terminating error' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { ConvertTo-TlsProtocolRegistryKeyName -Protocol ([System.Security.Authentication.SslProtocols]::None) } | Should -Throw -ErrorId 'CTTPRKN0001,ConvertTo-TlsProtocolRegistryKeyName'
            }
        }
    }
}
