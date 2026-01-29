<#
    .SYNOPSIS
        Enables specified TLS/SSL protocols by writing SCHANNEL registry values.

    .DESCRIPTION
        Enables SCHANNEL protocol keys under
        HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols
        for the server-side `Server` key by default. Use the `-Client` switch to
        operate on the `Client` key instead. The command will create the target
        key if it does not exist and set the `Enabled` DWORD to `1`.

        Optionally, when `-SetDisabledByDefault` is specified the command will
        also write `DisabledByDefault = 0` (opt-in only).

    .PARAMETER Protocol
        One or more protocol names to enable. Accepts values from the
        `[System.Security.Authentication.SslProtocols]` enum such as `Ssl2`,
        `Ssl3`, `Tls`, `Tls11`, `Tls12`, `Tls13`.

    .PARAMETER Client
        When specified, operate on the protocol `Client` registry key instead of
        the default `Server` key.

    .PARAMETER SetDisabledByDefault
        When specified, also set the `DisabledByDefault` DWORD to 0. This is an
        opt-in behavior to avoid unintentionally changing additional registry
        values.

    .PARAMETER Force
        Suppresses confirmation prompts.

    .INPUTS
        None.

    .OUTPUTS
        None.

    .EXAMPLE
        Enable-TlsProtocol -Protocol Tls12

        Enables TLS 1.2 for server-side connections by setting the `Enabled`
        registry value to 1.

    .EXAMPLE
        Enable-TlsProtocol -Protocol Tls13 -Client

        Enables TLS 1.3 for client-side connections.

    .EXAMPLE
        Enable-TlsProtocol -Protocol Tls12, Tls13 -SetDisabledByDefault

        Enables TLS 1.2 and TLS 1.3 for server-side connections and also sets
        the `DisabledByDefault` registry value to 0.

    .EXAMPLE
        Enable-TlsProtocol -Protocol Tls12 -Force

        Enables TLS 1.2 for server-side connections without prompting for
        confirmation.
#>
function Enable-TlsProtocol
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'Because ShouldProcess is used in the called function Set-TlsProtocolRegistryValue')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
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
        $SetDisabledByDefault,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    # ShouldProcess is handled in Set-TlsProtocolRegistryValue
    Set-TlsProtocolRegistryValue @PSBoundParameters -Enable
}
