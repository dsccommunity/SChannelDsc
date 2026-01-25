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
}
