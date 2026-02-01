<#
    .SYNOPSIS
        Converts a protocol identifier to the SCHANNEL registry key name.

    .DESCRIPTION
        Maps protocol values from the `[SChannelSslProtocols]`
        enum to the actual SCHANNEL registry key names (e.g. 'TLS 1.2').

    .PARAMETER Protocol
        The protocol value from the `[SChannelSslProtocols]`
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
        [SChannelSslProtocols]
        $Protocol
    )

    $protocolRegistryKeyName = switch ($Protocol)
    {
        ([SChannelSslProtocols]::Ssl2)
        {
            'SSL 2.0'
        }

        ([SChannelSslProtocols]::Ssl3)
        {
            'SSL 3.0'
        }

        ([SChannelSslProtocols]::Tls)
        {
            'TLS 1.0'
        }

        ([SChannelSslProtocols]::Tls11)
        {
            'TLS 1.1'
        }

        ([SChannelSslProtocols]::Tls12)
        {
            'TLS 1.2'
        }

        ([SChannelSslProtocols]::Tls13)
        {
            'TLS 1.3'
        }

        ([SChannelSslProtocols]::DTls1)
        {
            'DTLS 1.0'
        }

        ([SChannelSslProtocols]::DTls12)
        {
            'DTLS 1.2'
        }
    }

    return $protocolRegistryKeyName
}
