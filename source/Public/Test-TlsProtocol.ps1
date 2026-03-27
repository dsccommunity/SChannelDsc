<#
    .SYNOPSIS
        Tests if specified TLS/SSL protocols are enabled on the local machine.

    .DESCRIPTION
        Tests one or more SCHANNEL protocol keys under
        HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols
        to determine whether the protocol is enabled or disabled for server-side
        or client-side connections. Returns `$true` if all specified protocols
        match the expected state, or `$false` if any do not.

    .PARAMETER Protocol
        One or more protocol names to check. Accepts values from the
        `[SChannelSslProtocols]` enum such as `Ssl2`,
        `Ssl3`, `Tls`, `Tls11`, `Tls12`, `Tls13`, `Dtls1`, `Dtls12`.

    .PARAMETER Client
        When specified, checks the protocol `Client` registry key instead of the
        default `Server` key.

    .PARAMETER Disabled
        When specified, tests that the protocol(s) are disabled. By default the
        command tests that the protocol(s) are enabled.

    .INPUTS
        None.

    .OUTPUTS
        `System.Boolean`

        Returns `$true` if all specified protocols match the expected state,
        `$false` otherwise.

    .EXAMPLE
        Test-TlsProtocol -Protocol Tls12

        Tests if TLS 1.2 is enabled for server-side connections.

    .EXAMPLE
        Test-TlsProtocol -Protocol Tls13 -Client

        Tests if TLS 1.3 is enabled for client-side connections.

    .EXAMPLE
        Test-TlsProtocol -Protocol Tls12 -Disabled

        Tests if TLS 1.2 is disabled for server-side connections.

    .EXAMPLE
        Test-TlsProtocol -Protocol Ssl2, Ssl3 -Disabled

        Tests if both SSL 2.0 and SSL 3.0 are disabled for server-side
        connections. Returns `$true` only if both protocols are disabled.

    .EXAMPLE
        Test-TlsProtocol -Protocol Tls12 -Client -Disabled

        Tests if TLS 1.2 is disabled for client-side connections.
#>
function Test-TlsProtocol
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [SChannelSslProtocols]
        $Protocol,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Client,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Disabled
    )

    foreach ($currentProtocol in $Protocol | Get-EnumFlags)
    {
        $regPath = Get-TlsProtocolRegistryPath -Protocol $currentProtocol -Client:$Client
        $protocolEnabled = Get-RegistryPropertyValue -Path $regPath -Name 'Enabled' -ErrorAction SilentlyContinue
        $protocolDisabled = Get-RegistryPropertyValue -Path $regPath -Name 'DisabledByDefault' -ErrorAction SilentlyContinue
        $protocolEnabled = if ($null -ne $protocolEnabled)
        {
            [System.Int32] $protocolEnabled
        }
        else
        {
            $null
        }

        $protocolDisabled = if ($null -ne $protocolDisabled)
        {
            [System.Int32] $protocolDisabled
        }
        else
        {
            $null
        }
        if ($Disabled.IsPresent)
        {
            # Missing keys imply the protocol is enabled by default, so -Disabled should fail
            if ($null -eq $protocolEnabled -and $null -eq $protocolDisabled)
            {
                return $false
            }

            # Consider protocol disabled when Enabled != 1 or DisabledByDefault == 1
            if (($null -ne $protocolEnabled -and $protocolEnabled -ne 1) -or ($null -ne $protocolDisabled -and $protocolDisabled -eq 1))
            {
                continue
            }
            else
            {
                return $false
            }
        }
        else
        {
            if ($null -eq $protocolEnabled -and $null -eq $protocolDisabled)
            {
                continue
            }

            if ((($protocolEnabled -eq 1 -and ($protocolDisabled -eq 0 -or $null -eq $protocolDisabled)) -or ($null -eq $protocolEnabled -and $protocolDisabled -eq 0)))
            {
                continue
            }
            else
            {
                return $false
            }
        }
    }

    return $true
}
