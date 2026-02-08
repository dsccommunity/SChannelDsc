<#
    .SYNOPSIS
        Sets TLS/SSL protocol registry values for enabling or disabling protocols.

    .DESCRIPTION
        Internal helper function that writes SCHANNEL protocol registry values
        under HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols.
        This function creates the registry key if it does not exist and sets
        the Enabled DWORD value. Optionally sets the DisabledByDefault value.

        The function handles ShouldProcess confirmation using the caller's
        PSCmdlet object.

    .PARAMETER Protocol
        One or more protocol names to set registry values for. Accepts values
        from the `[SChannelSslProtocols]` enum such as
        `Ssl2`, `Ssl3`, `Tls`, `Tls11`, `Tls12`, `Tls13`, `Dtls1`, `Dtls12`.

    .PARAMETER Enable
        Enables the protocol by setting Enabled to 1 and DisabledByDefault to 0.

    .PARAMETER Disable
        Disables the protocol by setting Enabled to 0 and DisabledByDefault to 1.

    .PARAMETER Client
        When specified, operate on the protocol `Client` registry key instead of
        the default `Server` key.

    .PARAMETER SetDisabledByDefault
        When specified, also set the DisabledByDefault registry value.

    .PARAMETER Force
        When specified, bypasses confirmation prompts and suppresses
        ShouldProcess confirmations.

    .PARAMETER Cmdlet
        The PSCmdlet object from the calling command, used to perform
        ShouldProcess confirmation.

    .INPUTS
        None.

    .OUTPUTS
        None.

    .EXAMPLE
        Set-TlsProtocolRegistryValue -Protocol Tls12 -Enable -SetDisabledByDefault

        Enables TLS 1.2 for server-side connections by setting the Enabled
        registry value to 1 and DisabledByDefault to 0.

    .EXAMPLE
        Set-TlsProtocolRegistryValue -Protocol Tls12, Tls13 -Enable

        Enables TLS 1.2 and TLS 1.3 for server-side connections.

    .EXAMPLE
        Set-TlsProtocolRegistryValue -Protocol Ssl3 -Disable -Client

        Disables SSL 3.0 for client-side connections by setting the Enabled
        registry value to 0.
#>
function Set-TlsProtocolRegistryValue
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Enable')]
    [OutputType()]
    param
    (
        [Parameter(Mandatory = $true)]
        [SChannelSslProtocols]
        $Protocol,

        [Parameter(Mandatory = $true, ParameterSetName = 'Enable')]
        [System.Management.Automation.SwitchParameter]
        $Enable,

        [Parameter(Mandatory = $true, ParameterSetName = 'Disable')]
        [System.Management.Automation.SwitchParameter]
        $Disable,

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

    # Need to do this check with Get-Variable instead of $Confirm due to strict mode.
    if ($Force.IsPresent -and -not (Get-Variable -Name 'Confirm' -ValueOnly -ErrorAction SilentlyContinue))
    {
        $ConfirmPreference = 'None'
    }

    foreach ($currentProtocol in $Protocol | Get-EnumFlags)
    {
        $protocolKeyName = ConvertTo-TlsProtocolRegistryKeyName -Protocol $currentProtocol
        $target = Get-TlsProtocolTargetRegistryName -Client:$Client

        if ($Enable.IsPresent)
        {
            $enabledValue = 1
            $disabledByDefaultValue = 0
            $descriptionMessage = $script:localizedData.Set_TlsProtocolRegistryValue_Enable_ShouldProcessDescription -f $protocolKeyName, $target
            $confirmationMessage = $script:localizedData.Set_TlsProtocolRegistryValue_Enable_ShouldProcessConfirmation -f $protocolKeyName
            $captionMessage = $script:localizedData.Set_TlsProtocolRegistryValue_Enable_ShouldProcessCaption
            $errorMessage = $script:localizedData.Set_TlsProtocolRegistryValue_FailedToEnable
            $errorId = 'STPRV0001'
        }
        else
        {
            $enabledValue = 0
            $disabledByDefaultValue = 1
            $descriptionMessage = $script:localizedData.Set_TlsProtocolRegistryValue_Disable_ShouldProcessDescription -f $protocolKeyName, $target
            $confirmationMessage = $script:localizedData.Set_TlsProtocolRegistryValue_Disable_ShouldProcessConfirmation -f $protocolKeyName
            $captionMessage = $script:localizedData.Set_TlsProtocolRegistryValue_Disable_ShouldProcessCaption
            $errorMessage = $script:localizedData.Set_TlsProtocolRegistryValue_FailedToDisable
            $errorId = 'STPRV0002'
        }

        if ($PSCmdlet.ShouldProcess($descriptionMessage, $confirmationMessage, $captionMessage))
        {
            $regPath = Get-TlsProtocolRegistryPath -Protocol $currentProtocol -Client:$Client

            try
            {
                $null = New-Item -Path $regPath -Force -ErrorAction 'Stop'
                $null = New-ItemProperty -Path $regPath -Name 'Enabled' -Value $enabledValue -PropertyType DWord -Force -ErrorAction 'Stop'

                if ($SetDisabledByDefault.IsPresent)
                {
                    $null = New-ItemProperty -Path $regPath -Name 'DisabledByDefault' -Value $disabledByDefaultValue -PropertyType DWord -Force -ErrorAction 'Stop'
                }
            }
            catch
            {
                $errorMessage = $errorMessage -f $currentProtocol

                $exception = New-Exception -Message $errorMessage -ErrorRecord $_
                $errorRecord = New-ErrorRecord -Exception $exception -ErrorId $errorId -ErrorCategory 'InvalidOperation' -TargetObject $currentProtocol
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
        }
    }
}
