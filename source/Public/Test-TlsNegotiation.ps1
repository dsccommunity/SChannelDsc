<#
    .SYNOPSIS
        Tests which TLS/SSL protocols can be negotiated with a target host/port.

    .DESCRIPTION
        Get-TlsProtocol attempts to establish a TCP connection to the specified HostName and Port,
        then performs a TLS/SSL handshake using each protocols provided in -Protocols.

        It uses System.Net.Security.SslStream and ignores certificate validation errors on purpose
        (the goal is to test protocol support, not certificate trust).

        For each attempted protocol, the function returns an object indicating whether the handshake
        succeeded, and if so, which protocol and cipher suite were negotiated.

    .PARAMETER HostName
        The DNS name or IP address of the target host. Default is 'localhost'.

    .PARAMETER Port
        The TCP port to connect to. Default is 1433.

    .PARAMETER Protocols
        An array of SslProtocols values to attempt. Defaults to:
        Ssl2, Ssl3, Tls, Tls11, Tls12, Tls13.

    .PARAMETER TimeoutSeconds
        Connection timeout in seconds for the TCP connect attempt. Default is 5.

    .OUTPUTS
        System.Management.Automation.PSCustomObject

        Each output object contains:
        - HostName
        - Port
        - AttemptedProtocol
        - Success
        - NegotiatedProtocol
        - NegotiatedCipherSuite
        - Error
        - InnerError

    .EXAMPLE
        Get-TlsProtocol -HostName localhost -Port 1433 | Format-Table -AutoSize

        Attempts each protocol against localhost:1433 and displays results in a table.

    .EXAMPLE
        Get-TlsProtocol -HostName sql01.contoso.com -Port 1433 -Verbose

        Shows only successful negotiations (and prints each attempt via -Verbose).

    .NOTES
        - Certificate validation is intentionally bypassed to focus solely on protocol support.
        - TLS 1.3 availability depends on OS + .NET runtime; unsupported environments may fail for Tls13.
        - Legacy protocols (Ssl2/Ssl3) are commonly disabled and will typically fail on modern systems.
#>
function Test-TlsNegotiation
{
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param
    (
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $HostName = 'localhost',

        [Parameter(Position = 1)]
        [ValidateRange(1, 65535)]
        [System.UInt16]
        $Port = 1433,

        [Parameter()]
        [System.Security.Authentication.SslProtocols[]]
        $Protocol,

        [Parameter()]
        [ValidateRange(1, 600)]
        [System.UInt32]
        $TimeoutSeconds = 5
    )

    if (-not $PSBoundParameters.ContainsKey('Protocol'))
    {
        $Protocol = @(
            [System.Security.Authentication.SslProtocols]::Ssl2,
            [System.Security.Authentication.SslProtocols]::Ssl3,
            [System.Security.Authentication.SslProtocols]::Tls,
            [System.Security.Authentication.SslProtocols]::Tls11,
            [System.Security.Authentication.SslProtocols]::Tls12,
            [System.Security.Authentication.SslProtocols]::Tls13
        )
    }

    # Equivalent to: (sender, certificate, chain, sslPolicyErrors) => true
    $certValidationCallback = [System.Net.Security.RemoteCertificateValidationCallback] {
        param($sender, $certificate, $chain, $sslPolicyErrors)
        return $true
    }

    foreach ($p in $Protocol)
    {
        Write-Verbose "Trying $p"

        $client = $null
        $sslStream = $null

        try
        {
            $client = [System.Net.Sockets.TcpClient]::new()

            # Timeout logic (TcpClient.Connect() has no built-in timeout)
            $iar = $client.BeginConnect($HostName, $Port, $null, $null)

            if (-not $iar.AsyncWaitHandle.WaitOne([System.TimeSpan]::FromSeconds($TimeoutSeconds), $false))
            {
                throw [System.TimeoutException]::new("Connect timed out after $TimeoutSeconds seconds.")
            }

            $client.EndConnect($iar)

            $sslStream = [System.Net.Security.SslStream]::new(
                $client.GetStream(),
                $false,
                $certValidationCallback,
                $null
            )

            # Equivalent to SslClientAuthenticationOptions { TargetHost = host; EnabledSslProtocols = protocol }
            $opts = [System.Net.Security.SslClientAuthenticationOptions]::new()

            $opts.TargetHost = $HostName
            $opts.EnabledSslProtocols = $p

            $sslStream.AuthenticateAsClient($opts)

            [PSCustomObject] @{
                HostName              = $HostName
                Port                  = $Port
                AttemptedProtocol     = $p
                Success               = $true
                NegotiatedProtocol    = $sslStream.SslProtocol
                NegotiatedCipherSuite = $sslStream.NegotiatedCipherSuite
                Error                 = $null
                InnerError            = $null
            }
        }
        catch
        {
            $innerExceptionMessage = if ($_.Exception.InnerException)
            {
                $_.Exception.InnerException.Message
            }
            else
            {
                $null
            }

            [PSCustomObject] @{
                HostName              = $HostName
                Port                  = $Port
                AttemptedProtocol     = $p
                Success               = $false
                NegotiatedProtocol    = $null
                NegotiatedCipherSuite = $null
                Error                 = $_.Exception.Message
                InnerError            = $innerExceptionMessage
            }
        }
        finally
        {
            if ($sslStream)
            {
                $sslStream.Dispose()
            }

            if ($client)
            {
                $client.Close()
                $client.Dispose()
            }
        }
    }
}
