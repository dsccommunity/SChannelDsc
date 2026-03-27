<#
    .SYNOPSIS
        Disables specified TLS/SSL protocols by writing SCHANNEL registry values.

    .DESCRIPTION
        Disables SCHANNEL protocol keys under
        HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols
        for the server-side `Server` key by default. Use the `-Client` switch to
        operate on the `Client` key instead. The command will create the target
        key if it does not exist and set the `Enabled` DWORD to `0`.

        Optionally, when `-SetDisabledByDefault` is specified the command will
        also write `DisabledByDefault = 1` (opt-in only).

    .PARAMETER Protocol
        One or more protocol names to disable. Accepts values from the
        `[SChannelSslProtocols]` enum such as `Ssl2`,
        `Ssl3`, `Tls`, `Tls11`, `Tls12`, `Tls13`, `Dtls1`, `Dtls12`.

    .PARAMETER Client
        When specified, operate on the protocol `Client` registry key instead of
        the default `Server` key.

    .PARAMETER SetDisabledByDefault
        When specified, also set the `DisabledByDefault` DWORD to 1. This is an
        opt-in behavior to avoid unintentionally changing additional registry
        values.

    .PARAMETER Force
        Suppresses confirmation prompts.

    .INPUTS
        None.

    .OUTPUTS
        None.

    .EXAMPLE
        Disable-TlsProtocol -Protocol Ssl3

        Disables SSL 3.0 for server-side connections by setting the `Enabled`
        registry value to 0.

    .EXAMPLE
        Disable-TlsProtocol -Protocol Tls -Client

        Disables TLS 1.0 for client-side connections.

    .EXAMPLE
        Disable-TlsProtocol -Protocol Ssl2, Ssl3 -SetDisabledByDefault

        Disables SSL 2.0 and SSL 3.0 for server-side connections and also sets
        the `DisabledByDefault` registry value to 1.

    .EXAMPLE
        Disable-TlsProtocol -Protocol Tls -Force

        Disables TLS 1.0 for server-side connections without prompting for
        confirmation.
#>
function Disable-TlsProtocol
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'Because ShouldProcess is used in the called function Set-TlsProtocolRegistryValue')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType()]
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
        $SetDisabledByDefault,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    # ShouldProcess is handled in Set-TlsProtocolRegistryValue
    Set-TlsProtocolRegistryValue @PSBoundParameters -Disable
}
