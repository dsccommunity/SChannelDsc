<#

  .PARAMETER Reasons
        Returns the reason a property is not in desired state.
#>

class SChannelProtocolBase : ResourceBase
{
    [DscProperty(Key)]
    [ValidateSet('Yes')]
    [System.String]
    $IsSingleInstance

    [DscProperty()]
    [ValidateSet('Ssl2', 'Ssl3', 'Tls', 'Tls11', 'Tls12', 'Tls13', 'Dtls1', 'Dtls12')]
    [System.String[]]
    $ProtocolsEnabled

    [DscProperty()]
    [ValidateSet('Ssl2', 'Ssl3', 'Tls', 'Tls11', 'Tls12', 'Tls13', 'Dtls1', 'Dtls12')]
    [System.String[]]
    $ProtocolsDisabled

    [DscProperty()]
    [ValidateSet('Ssl2', 'Ssl3', 'Tls', 'Tls11', 'Tls12', 'Tls13', 'Dtls1', 'Dtls12')]
    [System.String[]]
    $ProtocolsDefault

    [DscProperty()]
    [System.Boolean]
    $RebootWhenRequired = $false

    [DscProperty(NotConfigurable)]
    [SChannelReason[]]
    $Reasons

    # Client side variable. Defaults to Server Side settings
    hidden [System.Boolean] $ClientSide = $false

    SChannelProtocolBase () : base ($PSScriptRoot)
    {
        # These properties will not be enforced.
        $this.ExcludeDscProperties = @(
            'IsSingleInstance',
            'RebootWhenRequired'
        )
    }

    # Base method Get() call this method to get the current state as a Hashtable.
    [System.Collections.Hashtable] GetCurrentState([System.Collections.Hashtable] $properties)
    {
        $currentState = @{}

        $getCurrentStateResult = Get-TlsProtocol -Client:$this.ClientSide

        $enabledProtocols = $getCurrentStateResult.Where({
                $_.Enabled -eq 1
            }).Protocol

        if ($enabledProtocols)
        {
            $currentState.ProtocolsEnabled = [System.String[]] $enabledProtocols
        }

        $disabledProtocols = $getCurrentStateResult.Where({
                $_.Enabled -eq 0
            }).Protocol

        if ($disabledProtocols)
        {
            $currentState.ProtocolsDisabled = [System.String[]] $disabledProtocols
        }

        $defaultProtocols = $getCurrentStateResult.Where({
                $null -eq $_.Enabled
            }).Protocol

        if ($defaultProtocols)
        {
            $currentState.ProtocolsDefault = [System.String[]] $defaultProtocols
        }

        return $currentState
    }

    <#
        Base method Set() call this method with the properties that should be
        enforced and that are not in desired state.
    #>
    hidden [void] Modify([System.Collections.Hashtable] $properties)
    {
        $protocolsUpdated = $false

        if ($properties.ContainsKey('ProtocolsEnabled'))
        {
            $protocolsToEnable = $this.PropertiesNotInDesiredState.Where({ $_.Property -eq 'ProtocolsEnabled' })
            $protocolsToUpdate = $protocolsToEnable.ExpectedValue.Where({ $_ -notin $protocolsToEnable.ActualValue })
            if ($protocolsToUpdate.Count -gt 0)
            {
                Enable-TlsProtocol -Protocol $protocolsToUpdate -Client:$this.ClientSide
                $protocolsUpdated = $true
            }
        }

        if ($properties.ContainsKey('ProtocolsDisabled'))
        {
            $protocolsToDisable = $this.PropertiesNotInDesiredState.Where({ $_.Property -eq 'ProtocolsDisabled' })
            $protocolsToUpdate = $protocolsToDisable.ExpectedValue.Where({ $_ -notin $protocolsToDisable.ActualValue })
            if ($protocolsToUpdate.Count -gt 0)
            {
                Disable-TlsProtocol -Protocol $protocolsToUpdate -Client:$this.ClientSide
                $protocolsUpdated = $true
            }
        }

        if ($properties.ContainsKey('ProtocolsDefault'))
        {
            $protocolsToDefault = $this.PropertiesNotInDesiredState.Where({ $_.Property -eq 'ProtocolsDefault' })
            $protocolsToUpdate = $protocolsToDefault.ExpectedValue.Where({ $_ -notin $protocolsToDefault.ActualValue })
            if ($protocolsToUpdate.Count -gt 0)
            {
                Reset-TlsProtocol -Protocol $protocolsToUpdate -Client:$this.ClientSide
                $protocolsUpdated = $true
            }
        }

        if ($protocolsUpdated -and $this.RebootWhenRequired)
        {
            Set-DscMachineRebootRequired
        }
    }

    <#
        Base method Assert() call this method with the properties that was assigned
        a value.
    #>
    hidden [void] AssertProperties([System.Collections.Hashtable] $properties)
    {
        $protocolProperties = @(
            'ProtocolsEnabled'
            'ProtocolsDisabled'
            'ProtocolsDefault'
        )

        # Check that at least one of the protocol properties has values
        $assertBoundParameterParameters = @{
            BoundParameterList = $properties
            RequiredParameter  = $protocolProperties
            RequiredBehavior   = 'Any'
        }

        Assert-BoundParameter @assertBoundParameterParameters

        # Get all assigned protocol properties.
        $assignedProtocolProperty = $properties.Keys.Where({
                $_ -in $protocolProperties
            })

        # Get all their values and group them to find duplicates.
        $assignedPropertyValues = $assignedProtocolProperty.ForEach({
                $properties[$_]
            }) | Group-Object -NoElement

        if ($assignedPropertyValues.Where({ $_.Count -gt 1 }))
        {
            $errorMessage = $this.localizedData.DuplicateProtocolValues

            New-ArgumentException -ArgumentName ($assignedProtocolProperty -join ',') -Message $errorMessage
        }
    }
}
