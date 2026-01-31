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

Describe 'Test-TlsNegotiation' {
    It 'Should have the correct parameters in parameter set <ExpectedParameterSetName>' -ForEach @(
        @{
            ExpectedParameterSetName = '__AllParameterSets'
            ExpectedParameters       = '[[-HostName] <string>] [[-Port] <ushort>] [-Protocol <SslProtocols[]>] [-TimeoutSeconds <uint>] [<CommonParameters>]'
        }
    ) {
        $result = (Get-Command -Name 'Test-TlsNegotiation').ParameterSets |
            Where-Object -FilterScript { $_.Name -eq $ExpectedParameterSetName } |
            Select-Object -Property @(
                @{ Name = 'ParameterSetName'; Expression = { $_.Name } },
                @{ Name = 'ParameterListAsString'; Expression = { $_.ToString() } }
            )

        $result.ParameterSetName | Should -Be $ExpectedParameterSetName
        $result.ParameterListAsString | Should -Be $ExpectedParameters
    }

    Context 'When testing against a real public host' {
        It 'Should return at least one successful TLS protocol (Tls12 expected)' {
            $results = Test-TlsNegotiation -HostName 'www.google.se' -Port 443 -Protocol ([System.Security.Authentication.SslProtocols]::Tls12) -TimeoutSeconds 10

            $results | Should -Not -BeNullOrEmpty

            $single = $results | Where-Object { $_.AttemptedProtocol -eq [System.Security.Authentication.SslProtocols]::Tls12 }
            $single | Should -Not -BeNullOrEmpty
            $single.Success | Should -BeTrue
            $single.NegotiatedProtocol | Should -Be 'Tls12'
            $single.NegotiatedCipherSuite | Should -Not -BeNullOrEmpty
        }

        It 'Should return result objects for multiple protocols' {
            $protocols = @(
                [System.Security.Authentication.SslProtocols]::Ssl2,
                [System.Security.Authentication.SslProtocols]::Ssl3,
                [System.Security.Authentication.SslProtocols]::Tls,
                [System.Security.Authentication.SslProtocols]::Tls11,
                [System.Security.Authentication.SslProtocols]::Tls12,
                [System.Security.Authentication.SslProtocols]::Tls13
            )

            $results = Test-TlsNegotiation -HostName 'www.google.se' -Port 443 -Protocol $protocols -TimeoutSeconds 10

            # At least one should be successful (Tls/Tls11/Tls12 commonly)
            ($results | Where-Object { $_.Success } | Measure-Object).Count | Should -BeGreaterThan 0
        }

        BeforeDiscovery {
            $individualProtocols = @(
                @{ Protocol = [System.Security.Authentication.SslProtocols]::Ssl2 }
                @{ Protocol = [System.Security.Authentication.SslProtocols]::Ssl3 }
                @{ Protocol = [System.Security.Authentication.SslProtocols]::Tls }
                @{ Protocol = [System.Security.Authentication.SslProtocols]::Tls11 }
                @{ Protocol = [System.Security.Authentication.SslProtocols]::Tls12 }
                @{ Protocol = [System.Security.Authentication.SslProtocols]::Tls13 }
            )

            $multiProtocols = @(
                @{ Protocol = [System.Security.Authentication.SslProtocols]::Tls12, [System.Security.Authentication.SslProtocols]::Tls13 }
            )
        }

        It 'Should return a result object for protocol <Protocol>' -ForEach $individualProtocols {
            $results = Test-TlsNegotiation -HostName 'www.google.se' -Port 443 -Protocol $Protocol -TimeoutSeconds 10

            $result = $results | Where-Object { $_.AttemptedProtocol -eq $Protocol }

            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType PSCustomObject
        }

        BeforeDiscovery {
            $multiProtocols = @(
                @{ Protocol = [System.Security.Authentication.SslProtocols]::Tls12, [System.Security.Authentication.SslProtocols]::Tls13 }
            )
        }

        It 'Should return a result object for specific protocol <Protocol>' -ForEach $multiProtocols {
            $result = Test-TlsNegotiation -HostName 'www.google.se' -Port 443 -Protocol $Protocol -TimeoutSeconds 10

            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType PSCustomObject
            $result | Should -HaveCount $Protocol.Count
        }

        It 'Should return results when Protocol parameter is not provided (uses defaults)' {
            $results = Test-TlsNegotiation -HostName 'www.google.se' -Port 443 -TimeoutSeconds 10

            $results | Should -Not -BeNullOrEmpty
            ($results | Where-Object { $_.Success } | Measure-Object).Count | Should -BeGreaterThan 0
        }
    }

    Context 'When validating parameters' {
        BeforeAll {
            $commandInfo = Get-Command -Name 'Test-TlsNegotiation'
        }

        It 'Should have HostName as a non-mandatory parameter' {
            $parameterInfo = $commandInfo.Parameters['HostName']

            $parameterInfo.Attributes.Mandatory | Should -BeFalse
        }

        It 'Should have Port as a non-mandatory parameter' {
            $parameterInfo = $commandInfo.Parameters['Port']

            $parameterInfo.Attributes.Mandatory | Should -BeFalse
        }

        It 'Should have Protocol as a non-mandatory parameter' {
            $parameterInfo = $commandInfo.Parameters['Protocol']

            $parameterInfo.Attributes.Mandatory | Should -BeFalse
        }

        It 'Should have Protocol declared as an array type' {
            $parameterInfo = $commandInfo.Parameters['Protocol']

            $parameterInfo.ParameterType.IsArray | Should -BeTrue
        }

        It 'Should have TimeoutSeconds as a non-mandatory parameter' {
            $parameterInfo = $commandInfo.Parameters['TimeoutSeconds']

            $parameterInfo.Attributes.Mandatory | Should -BeFalse
        }
    }
}
