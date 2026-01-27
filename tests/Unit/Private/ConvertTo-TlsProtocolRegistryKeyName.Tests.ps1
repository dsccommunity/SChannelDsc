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

Describe 'ConvertTo-TlsProtocolRegistryKeyName' -Tag 'Private' {
    Context 'When converting known protocol enum values' {
        It 'Maps Tls12 to TLS 1.2' {
            InModuleScope -ScriptBlock {
                ConvertTo-TlsProtocolRegistryKeyName -Protocol ([System.Security.Authentication.SslProtocols]::Tls12) | Should -Be 'TLS 1.2'
            }
        }

        It 'Maps Tls11 to TLS 1.1' {
            InModuleScope -ScriptBlock {
                ConvertTo-TlsProtocolRegistryKeyName -Protocol ([System.Security.Authentication.SslProtocols]::Tls11) | Should -Be 'TLS 1.1'
            }
        }

        It 'Maps Tls to TLS 1.0' {
            InModuleScope -ScriptBlock {
                ConvertTo-TlsProtocolRegistryKeyName -Protocol ([System.Security.Authentication.SslProtocols]::Tls) | Should -Be 'TLS 1.0'
            }
        }

        It 'Maps Ssl3 to SSL 3.0' {
            InModuleScope -ScriptBlock {
                ConvertTo-TlsProtocolRegistryKeyName -Protocol ([System.Security.Authentication.SslProtocols]::Ssl3) | Should -Be 'SSL 3.0'
            }
        }

        It 'Maps Ssl2 to SSL 2.0' {
            InModuleScope -ScriptBlock {
                ConvertTo-TlsProtocolRegistryKeyName -Protocol ([System.Security.Authentication.SslProtocols]::Ssl2) | Should -Be 'SSL 2.0'
            }
        }

        It 'Maps Tls13 to TLS 1.3' {
            InModuleScope -ScriptBlock {
                ConvertTo-TlsProtocolRegistryKeyName -Protocol ([System.Security.Authentication.SslProtocols]::Tls13) | Should -Be 'TLS 1.3'
            }
        }
    }

    Context 'When given an unsupported protocol enum value' {
        It 'Should throw a terminating error' {
            InModuleScope -ScriptBlock {
                { ConvertTo-TlsProtocolRegistryKeyName -Protocol ([System.Security.Authentication.SslProtocols]::None) } | Should -Throw -ErrorId 'CTTPRKN0001,ConvertTo-TlsProtocolRegistryKeyName'
            }
        }
    }
}
