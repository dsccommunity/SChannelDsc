<#
    .SYNOPSIS
        Resets specified TLS/SSL protocols by removing SCHANNEL registry keys.

    .DESCRIPTION
        Removes SCHANNEL protocol registry keys under
        HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols
        for the server-side `Server` key by default. Use the `-Client` switch to
        operate on the `Client` key instead. This resets the protocol configuration
        to the Windows default behavior.

        If no protocol is specified, all supported protocols are reset.

    .PARAMETER Protocol
        One or more protocol names to reset. Accepts values from the
        `[SChannelSslProtocols]` enum such as `Ssl2`,
        `Ssl3`, `Tls`, `Tls11`, `Tls12`, `Tls13`, `Dtls1`, `Dtls12`. If not specified, all
        supported protocols are reset.

    .PARAMETER Client
        When specified, operate on the protocol `Client` registry key instead of
        the default `Server` key.

    .PARAMETER Force
        Suppresses confirmation prompts.

    .INPUTS
        None.

    .OUTPUTS
        None.

    .EXAMPLE
        Reset-TlsProtocol

        Resets all supported TLS/SSL protocols for server-side connections by
        removing the corresponding registry keys, restoring Windows default
        behavior.

    .EXAMPLE
        Reset-TlsProtocol -Protocol Tls12

        Resets TLS 1.2 for server-side connections by removing the corresponding
        registry key, restoring Windows default behavior.

    .EXAMPLE
        Reset-TlsProtocol -Protocol Tls12 -Client

        Resets TLS 1.2 for client-side connections.

    .EXAMPLE
        Reset-TlsProtocol -Protocol Ssl2, Ssl3

        Resets SSL 2.0 and SSL 3.0 for server-side connections.

    .EXAMPLE
        Reset-TlsProtocol -Client -Force

        Resets all supported TLS/SSL protocols for client-side connections
        without prompting for confirmation.

    .EXAMPLE
        Reset-TlsProtocol -Protocol Tls -Force

        Resets TLS 1.0 for server-side connections without prompting for
        confirmation.
#>
function Reset-TlsProtocol
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType()]
    param
    (
        [Parameter()]
        [SChannelSslProtocols[]]
        $Protocol,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Client,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    # Need to do this check with Get-Variable instead of $Confirm due to strict mode.
    if ($Force.IsPresent -and -not $Confirm)
    {
        $ConfirmPreference = 'None'
    }

    if (-not $PSBoundParameters.ContainsKey('Protocol'))
    {
        $Protocol = (Get-TlsProtocol -Client:$Client).Protocol
    }

    foreach ($currentProtocol in $Protocol)
    {
        $protocolKeyName = ConvertTo-TlsProtocolRegistryKeyName -Protocol $currentProtocol
        $target = Get-TlsProtocolTargetRegistryName -Client:$Client
        $regPath = Get-TlsProtocolRegistryPath -Protocol $currentProtocol -Client:$Client

        $descriptionMessage = $script:localizedData.Reset_TlsProtocol_ShouldProcessDescription -f $protocolKeyName, $target
        $confirmationMessage = $script:localizedData.Reset_TlsProtocol_ShouldProcessConfirmation -f $protocolKeyName
        $captionMessage = $script:localizedData.Reset_TlsProtocol_ShouldProcessCaption

        if ($PSCmdlet.ShouldProcess($descriptionMessage, $confirmationMessage, $captionMessage))
        {
            if (Test-Path -Path $regPath)
            {
                try
                {
                    Remove-Item -Path $regPath -Force -ErrorAction 'Stop'

                    # Remove the parent protocol key if it has no remaining child items
                    $parentPath = Split-Path -Path $regPath -Parent

                    if ((Test-Path -Path $parentPath) -and -not (Get-ChildItem -Path $parentPath))
                    {
                        Remove-Item -Path $parentPath -Force -ErrorAction 'Stop'
                    }
                }
                catch
                {
                    $errorMessage = $script:localizedData.Reset_TlsProtocol_FailedToReset -f $currentProtocol

                    $exception = New-Exception -Message $errorMessage -ErrorRecord $_
                    $errorRecord = New-ErrorRecord -Exception $exception -ErrorId 'RTP0001' -ErrorCategory 'InvalidOperation' -TargetObject $currentProtocol
                    $PSCmdlet.ThrowTerminatingError($errorRecord)
                }
            }
        }
    }
}
