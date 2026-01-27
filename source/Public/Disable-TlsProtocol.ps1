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
        `[System.Security.Authentication.SslProtocols]` enum such as `Ssl2`,
        `Ssl3`, `Tls`, `Tls11`, `Tls12`, `Tls13`.

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

        $descriptionMessage = $script:localizedData.Disable_TlsProtocol_ShouldProcessDescription -f $protocolKeyName, $target
        $confirmationMessage = $script:localizedData.Disable_TlsProtocol_ShouldProcessConfirmation -f $protocolKeyName
        $captionMessage = $script:localizedData.Disable_TlsProtocol_ShouldProcessCaption

        if ($PSCmdlet.ShouldProcess($descriptionMessage, $confirmationMessage, $captionMessage))
        {
            try
            {
                $null = New-Item -Path $regPath -Force -ErrorAction 'Stop'
                $null = New-ItemProperty -Path $regPath -Name 'Enabled' -Value 0 -PropertyType DWord -Force -ErrorAction 'Stop'
                if ($SetDisabledByDefault.IsPresent)
                {
                    $null = New-ItemProperty -Path $regPath -Name 'DisabledByDefault' -Value 1 -PropertyType DWord -Force -ErrorAction 'Stop'
                }
            }
            catch
            {
                $errorMessage = ($script:localizedData.Disable_TlsProtocol_FailedToDisable -f $p, $_.Exception.Message)

                $exception = New-Exception -Message $errorMessage -ErrorRecord $_
                $errorRecord = New-ErrorRecord -Exception $exception -ErrorId 'DTP0002' -ErrorCategory 'InvalidOperation' -TargetObject $p
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
        }
    }
}
