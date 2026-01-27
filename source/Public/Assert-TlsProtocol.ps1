<#
    .SYNOPSIS
        Asserts that the specified TLS/SSL protocols are enabled or disabled.

    .DESCRIPTION
        Calls Test-TlsProtocol for the specified protocol(s) and throws a
        terminating error if the assertion fails. By default, the command
        asserts that the protocol(s) are enabled for server-side connections.
        Use the `-Client` switch to assert the `Client` key instead of the
        default `Server` key. Use the `-Disabled` switch to assert that the
        protocol(s) are disabled instead of enabled.

    .PARAMETER Protocol
        One or more protocol names to assert. Accepts values from the
        `[System.Security.Authentication.SslProtocols]` enum such as `Ssl2`,
        `Ssl3`, `Tls`, `Tls11`, `Tls12`, `Tls13`.

    .PARAMETER Client
        When specified, assert the protocol in the `Client` registry key
        instead of the default `Server` key.

    .PARAMETER Disabled
        When specified, asserts that the protocol(s) are disabled. By default
        the command asserts that the protocol(s) are enabled.

    .INPUTS
        None.

    .OUTPUTS
        None.

    .EXAMPLE
        Assert-TlsProtocol -Protocol Tls12

        Asserts that TLS 1.2 is enabled for server-side connections. Throws a
        terminating error if TLS 1.2 is not enabled.

    .EXAMPLE
        Assert-TlsProtocol -Protocol Tls12 -Client

        Asserts that TLS 1.2 is enabled for client-side connections.

    .EXAMPLE
        Assert-TlsProtocol -Protocol Tls12 -Disabled

        Asserts that TLS 1.2 is disabled for server-side connections. Throws a
        terminating error if TLS 1.2 is still enabled.

    .EXAMPLE
        Assert-TlsProtocol -Protocol Ssl3, Tls -Disabled

        Asserts that both SSL 3.0 and TLS 1.0 are disabled for server-side
        connections.
#>
function Assert-TlsProtocol
{
    [CmdletBinding()]
    [OutputType()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Security.Authentication.SslProtocols[]]
        $Protocol,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Client,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Disabled
    )

    $result = Test-TlsProtocol -Protocol $Protocol -Client:$Client -Disabled:$Disabled

    if (-not $result)
    {
        if ($Disabled)
        {
            $message = ($script:localizedData.Assert_TlsProtocol_NotDisabled -f ($Protocol -join ', '))
        }
        else
        {
            $message = ($script:localizedData.Assert_TlsProtocol_NotEnabled -f ($Protocol -join ', '))
        }

        $exception = New-Exception -Message $message
        $errorRecord = New-ErrorRecord -Exception $exception -ErrorId 'ATP0001' -ErrorCategory 'InvalidOperation' -TargetObject $Protocol
        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
}
