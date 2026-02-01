<#
    .SYNOPSIS
        Returns the SCHANNEL registry path for a given protocol and target.

    .DESCRIPTION
        Builds the registry path under
        HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols
        for the provided friendly protocol name and selects the `Server` or
        `Client` subkey depending on the `-Client` switch.

    .PARAMETER Protocol
        The protocol identifier, e.g. 'Tls12'.

    .PARAMETER Client
        When specified, return the path for the `Client` subkey, otherwise
        return the `Server` subkey path.

    .INPUTS
        None.

    .OUTPUTS
        System.String

    .EXAMPLE
        Get-TlsProtocolRegistryPath -Protocol Tls12

        Returns the string:
        'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server'.

    .EXAMPLE
        Get-TlsProtocolRegistryPath -Protocol Tls13 -Client

        Returns the string:
        'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client'.
#>
function Get-TlsProtocolRegistryPath
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [SChannelSslProtocols]
        $Protocol,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Client
    )

    $protocolKeyName = ConvertTo-TlsProtocolRegistryKeyName -Protocol $Protocol

    $target = Get-TlsProtocolTargetRegistryName -Client:$Client

    return ('HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\{0}\{1}' -f $protocolKeyName, $target)
}
