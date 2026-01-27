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
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
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

    if ($Force.IsPresent -and -not $Confirm)
    {
        $ConfirmPreference = 'None'
    }

    foreach ($p in $Protocol)
    {
        $target = Get-TlsProtocolTargetRegistryName -Client:$Client

        $regPath = Get-TlsProtocolRegistryPath -Protocol $p -Client:$Client

        # For ShouldProcess description use the localized template with the key name and target
        $protocolKeyName = ConvertTo-TlsProtocolRegistryKeyName -Protocol $p

        $description = ($script:localizedData.Enable_TlsProtocol_ShouldProcessDescription -f $protocolKeyName, $target)

        if ($PSCmdlet.ShouldProcess($description))
        {
            try
            {
                New-Item -Path $regPath -Force | Out-Null
                New-ItemProperty -Path $regPath -Name 'Enabled' -Value 1 -PropertyType DWord -Force | Out-Null
                if ($SetDisabledByDefault.IsPresent)
                {
                    New-ItemProperty -Path $regPath -Name 'DisabledByDefault' -Value 0 -PropertyType DWord -Force | Out-Null
                }
            }
            catch
            {
                $errorMessage = ($script:localizedData.Enable_TlsProtocol_FailedToEnable -f $p, $_.Exception.Message)
                $exception = New-Exception -Message $errorMessage -ErrorRecord $_
                $errorRecord = New-ErrorRecord -Exception $exception -ErrorId 'ETP0001' -ErrorCategory 'InvalidOperation' -TargetObject $p
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
        }
    }
}
