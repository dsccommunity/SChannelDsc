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

Describe 'Test-TlsNegotiation' {
    Context 'When testing against a real public host (www.google.se:443)' {
        It 'Should return at least one successful TLS protocol (Tls12 expected)' {
            $results = Test-TlsNegotiation -HostName 'www.google.se' -Port 443 -Protocol ([System.Security.Authentication.SslProtocols]::Tls12) -TimeoutSeconds 10

            $results | Should -Not -BeNullOrEmpty

            $single = $results | Where-Object { $_.AttemptedProtocol -eq [System.Security.Authentication.SslProtocols]::Tls12 }
            $single | Should -Not -BeNullOrEmpty
            $single.Success | Should -BeTrue
            $single.NegotiatedProtocol | Should -Be 'Tls12'
            $single.NegotiatedCipherSuite | Should -Not -BeNullOrEmpty
        }

        It 'Should return objects for multiple protocols' {
            $protocols = @(
                [System.Security.Authentication.SslProtocols]::Ssl2,
                [System.Security.Authentication.SslProtocols]::Ssl3,
                [System.Security.Authentication.SslProtocols]::Tls,
                [System.Security.Authentication.SslProtocols]::Tls11,
                [System.Security.Authentication.SslProtocols]::Tls12,
                [System.Security.Authentication.SslProtocols]::Tls13
            )

            $results = Test-TlsNegotiation -HostName 'www.google.se' -Port 443 -Protocol $protocols -TimeoutSeconds 10

            # Ensure we have a result for each attempted protocol
            foreach ($p in $protocols) {
                $r = $results | Where-Object { $_.AttemptedProtocol -eq $p }
                $r | Should -Not -BeNullOrEmpty
                $r | Should -BeOfType PSCustomObject
            }

            # At least one should be successful (Tls/Tls11/Tls12 commonly)
            ($results | Where-Object { $_.Success } | Measure-Object).Count | Should -BeGreaterThan 0
        }

        It 'Should return objects for specific protocols' {
            $protocols = @(
                [System.Security.Authentication.SslProtocols]::Tls12,
                [System.Security.Authentication.SslProtocols]::Tls13
            )

            $results = Test-TlsNegotiation -HostName 'www.google.se' -Port 443 -Protocol $protocols -TimeoutSeconds 10

            $results | Should -Not -BeNullOrEmpty
            $results | Should -HaveCount 2

            # Ensure we have a result for each attempted protocol
            foreach ($p in $protocols) {
                $r = $results | Where-Object { $_.AttemptedProtocol -eq $p }
                $r | Should -Not -BeNullOrEmpty
                $r | Should -BeOfType PSCustomObject
            }

            # At least one should be successful
            ($results | Where-Object { $_.Success } | Measure-Object).Count | Should -BeGreaterThan 0
        }
    }

    Context 'When validating parameters' {
        BeforeAll {
            $script:commandInfo = Get-Command -Name 'Test-TlsNegotiation'
        }

        It 'Should have parameter set __AllParameterSets' {
            $result = $script:commandInfo.ParameterSets |
                Where-Object -FilterScript { $_.Name -eq '__AllParameterSets' }

            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be '__AllParameterSets'
        }

        It 'Should have HostName as a non-mandatory parameter' {
            $parameterInfo = $script:commandInfo.Parameters['HostName']

            $parameterInfo.Attributes.Mandatory | Should -Not -Contain $true
        }

        It 'Should have Port as a non-mandatory parameter' {
            $parameterInfo = $script:commandInfo.Parameters['Port']

            $parameterInfo.Attributes.Mandatory | Should -Not -Contain $true
        }

        It 'Should have Protocol as a non-mandatory parameter' {
            $parameterInfo = $script:commandInfo.Parameters['Protocol']

            $parameterInfo.Attributes.Mandatory | Should -Not -Contain $true
        }

        It 'Should have TimeoutSeconds as a non-mandatory parameter' {
            $parameterInfo = $script:commandInfo.Parameters['TimeoutSeconds']

            $parameterInfo.Attributes.Mandatory | Should -Not -Contain $true
        }
    }
}
