<#
    .SYNOPSIS
        Converts a protocol identifier to the SCHANNEL registry key name.

    .DESCRIPTION
        Maps protocol values from the `[System.Security.Authentication.SslProtocols]`
        enum to the actual SCHANNEL registry key names (e.g. 'TLS 1.2').

    .PARAMETER Protocol
        The protocol value from the `[System.Security.Authentication.SslProtocols]`
        enum, e.g. `Tls12`, `Ssl3`, `Tls`.

    .OUTPUTS
        System.String

    .EXAMPLE
        ConvertTo-TlsProtocolRegistryKeyName -Protocol Tls12

        Returns the string 'TLS 1.2'.
#>
function ConvertTo-TlsProtocolRegistryKeyName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Security.Authentication.SslProtocols]
        $Protocol
    )

    $protocolRegistryKeyName = switch ($Protocol)
    {
        ([System.Security.Authentication.SslProtocols]::Ssl2)
        {
            'SSL 2.0'
        }

        ([System.Security.Authentication.SslProtocols]::Ssl3)
        {
            'SSL 3.0'
        }

        ([System.Security.Authentication.SslProtocols]::Tls)
        {
            'TLS 1.0'
        }

        ([System.Security.Authentication.SslProtocols]::Tls11)
        {
            'TLS 1.1'
        }

        ([System.Security.Authentication.SslProtocols]::Tls12)
        {
            'TLS 1.2'
        }

        ([System.Security.Authentication.SslProtocols]::Tls13)
        {
            'TLS 1.3'
        }

        default
        {
            $errorMessage = $script:localizedData.ConvertTo_TlsProtocolRegistryKeyName_UnknownProtocol -f $Protocol
            $exception = New-Exception -Message $errorMessage
            $errorRecord = New-ErrorRecord -Exception $exception -ErrorId 'CTTPRKN0001' -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidArgument) -TargetObject $Protocol
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }

    return $protocolRegistryKeyName
}
