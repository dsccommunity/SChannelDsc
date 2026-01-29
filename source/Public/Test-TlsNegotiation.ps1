<#
    .SYNOPSIS
        Tests which TLS/SSL protocols can be negotiated with a target host/port.

    .DESCRIPTION
        Test-TlsNegotiation attempts to establish a TCP connection to the
        specified HostName and Port, then performs a TLS/SSL handshake using
        each protocol provided in `-Protocol`.

        It uses System.Net.Security.SslStream and ignores certificate validation
        errors on purpose (the goal is to test protocol support, not certificate
        trust).

        For each attempted protocol, the function returns an object indicating
        whether the handshake succeeded, and if so, which protocol and cipher
        suite were negotiated.

    .PARAMETER HostName
        The DNS name or IP address of the target host. Default is 'localhost'.

    .PARAMETER Port
        The TCP port to connect to. Default is 443.

    .PARAMETER Protocol
        One or more protocol names to attempt. Accepts values from the
        `[System.Security.Authentication.SslProtocols]` enum such as `Ssl2`,
        `Ssl3`, `Tls`, `Tls11`, `Tls12`, `Tls13`. If not specified, all
        supported protocols are attempted.

    .PARAMETER TimeoutSeconds
        Connection timeout in seconds for the TCP connect attempt. Default is 5.

    .INPUTS
        None.

    .OUTPUTS
        `System.Management.Automation.PSCustomObject`

        Each output object contains: HostName, Port, AttemptedProtocol, Success,
        NegotiatedProtocol, NegotiatedCipherSuite, Error, and InnerError.


        .EXAMPLE
        Test-TlsNegotiation -HostName localhost

        Attempts each protocol against localhost using default port 443 and returns
        the results.

    .EXAMPLE
        Test-TlsNegotiation -HostName localhost -Port 1433

        Attempts each protocol against localhost:1433 and returns the results.

    .EXAMPLE
        Test-TlsNegotiation -HostName localhost -Port 1433 | Format-Table -AutoSize

        Attempts each protocol against localhost:1433 and displays results in a
        formatted table.

    .EXAMPLE
        Test-TlsNegotiation -HostName sql01.contoso.com -Port 1433 -Verbose

        Tests protocol negotiation against sql01.contoso.com:1433 and prints
        each attempt via -Verbose.

    .EXAMPLE
        Test-TlsNegotiation -HostName webserver.contoso.com -Port 443 -Protocol Tls12, Tls13

        Tests only TLS 1.2 and TLS 1.3 negotiation against a web server on
        port 443.

    .NOTES
        Certificate validation is intentionally bypassed to focus solely on
        protocol support. TLS 1.3 availability depends on OS and .NET runtime.
#>
function Test-TlsNegotiation
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $HostName = 'localhost',

        [Parameter(Position = 1)]
        [ValidateRange(1, 65535)]
        [System.UInt16]
        $Port = 443,

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
        param
        (
            [Parameter()]
            $sender,

            [Parameter()]
            $certificate,

            [Parameter()]
            $chain,

            [Parameter()]
            $sslPolicyErrors
        )

        return $true
    }

    foreach ($currentProtocol in $Protocol)
    {
        Write-Verbose -Message ($script:localizedData.Test_TlsNegotiation_TryingProtocol -f $currentProtocol)

        $client = $null
        $sslStream = $null

        try
        {
            $client = [System.Net.Sockets.TcpClient]::new()

            # Timeout logic (TcpClient.Connect() has no built-in timeout)
            $iar = $client.BeginConnect($HostName, $Port, $null, $null)

            try
            {
                if (-not $iar.AsyncWaitHandle.WaitOne([System.TimeSpan]::FromSeconds($TimeoutSeconds), $false))
                {
                    $message = $script:localizedData.Test_TlsNegotiation_ConnectTimeout -f $TimeoutSeconds

                    $exception = New-Exception -Message $message
                    $errorRecord = New-ErrorRecord -Exception $exception -ErrorId 'TTN0002' -ErrorCategory 'OperationTimeout' -TargetObject $HostName
                    $PSCmdlet.ThrowTerminatingError($errorRecord)
                }
            }
            finally
            {
                $iar.AsyncWaitHandle.Dispose()
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
            $opts.EnabledSslProtocols = $currentProtocol

            $sslStream.AuthenticateAsClient($opts)

            [PSCustomObject] @{
                HostName              = $HostName
                Port                  = $Port
                AttemptedProtocol     = $currentProtocol
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
                AttemptedProtocol     = $currentProtocol
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
