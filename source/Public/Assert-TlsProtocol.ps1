<#
    .SYNOPSIS
        Asserts that the specified TLS/SSL protocols are enabled.

    .DESCRIPTION
        Calls Test-TlsProtocol for the specified protocol(s) and throws a
        terminating error if any of them are not enabled. Use the `-Client`
        switch to assert the `Client` key instead of the default `Server` key.

    .PARAMETER Protocol
        One or more protocol names to assert. Accepts values from the
        `[System.Security.Authentication.SslProtocols]` enum such as `Ssl2`,
        `Ssl3`, `Tls`, `Tls11`, `Tls12`, `Tls13`.

    .PARAMETER Client
        When specified, assert the protocol in the `Client` registry key.
#>
function Assert-TlsProtocol
{
    [CmdletBinding()]
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
        throw $errorRecord.Exception
    }
}
