<#
    .SYNOPSIS
        Returns configured SCHANNEL protocol settings for Server or Client.

    .DESCRIPTION
        Reads the `Enabled` and `DisabledByDefault` values for one or more
        SCHANNEL protocol keys and returns a PSCustomObject with the results.
        By default, all supported protocols are queried if no specific protocol
        is specified.

    .PARAMETER Protocol
        One or more protocol names. Accepts values from the
        `[System.Security.Authentication.SslProtocols]` enum such as `Ssl2`,
        `Ssl3`, `Tls`, `Tls11`, `Tls12`, `Tls13`. If not specified, all
        supported protocols are returned.

    .PARAMETER Client
        When specified, reads the `Client` key. By default the `Server` key is used.

    .INPUTS
        None.

    .OUTPUTS
        `System.Management.Automation.PSCustomObject`

        Returns one or more objects with the following properties: Protocol,
        Target, Enabled, DisabledByDefault, and RegistryPath.

    .EXAMPLE
        Get-TlsProtocol

        Returns the SCHANNEL protocol settings for all supported protocols for
        server-side connections.

    .EXAMPLE
        Get-TlsProtocol -Protocol Tls12

        Returns the SCHANNEL protocol settings for TLS 1.2 for server-side
        connections.

    .EXAMPLE
        Get-TlsProtocol -Protocol Tls12, Tls13 -Client

        Returns the SCHANNEL protocol settings for TLS 1.2 and TLS 1.3 for
        client-side connections.

    .EXAMPLE
        Get-TlsProtocol | Format-Table -AutoSize

        Returns all protocol settings and displays them in a formatted table.
#>
function Get-TlsProtocol
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter()]
        [System.Security.Authentication.SslProtocols[]]
        $Protocol,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Client
    )

    if (-not $PSBoundParameters.ContainsKey('Protocol'))
    {
        $Protocol = [System.Collections.ArrayList] @(
            [System.Security.Authentication.SslProtocols]::Ssl2,
            [System.Security.Authentication.SslProtocols]::Ssl3,
            [System.Security.Authentication.SslProtocols]::Tls,
            [System.Security.Authentication.SslProtocols]::Tls11,
            [System.Security.Authentication.SslProtocols]::Tls12,
            [System.Security.Authentication.SslProtocols]::Tls13
        )

        if ([System.Enum]::GetNames([System.Security.Authentication.SslProtocols]) -notcontains 'Tls13')
        {
            $Protocol.Remove([System.Security.Authentication.SslProtocols]::Tls13)
        }
    }

    foreach ($currentProtocol in $Protocol)
    {
        $regPath = Get-TlsProtocolRegistryPath -Protocol $currentProtocol -Client:$Client

        $protocolEnabled = Get-RegistryPropertyValue -Path $regPath -Name 'Enabled' -ErrorAction SilentlyContinue
        $protocolDisabled = Get-RegistryPropertyValue -Path $regPath -Name 'DisabledByDefault' -ErrorAction SilentlyContinue

        $protocolEnabled = if ($null -ne $protocolEnabled)
        {
            [System.UInt32] $protocolEnabled
        }
        else
        {
            $null
        }

        $protocolDisabled = if ($null -ne $protocolDisabled)
        {
            [System.UInt32] $protocolDisabled
        }
        else
        {
            $null
        }

        [PSCustomObject] @{
            Protocol          = $currentProtocol
            Target            = Get-TlsProtocolTargetRegistryName -Client:$Client
            Enabled           = $protocolEnabled
            DisabledByDefault = $protocolDisabled
            RegistryPath      = $regPath
        }
    }
}
