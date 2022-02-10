$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'
$script:resourceHelperModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'SChannelDsc.Util'
Import-Module -Name (Join-Path -Path $script:resourceHelperModulePath -ChildPath 'SChannelDsc.Util.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_Protocol'

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Multi-Protocol Unified Hello", "PCT 1.0", "SSL 2.0", "SSL 3.0", "TLS 1.0", "TLS 1.1", "TLS 1.2", "TLS 1.3")]
        [System.String]
        $Protocol,

        [Parameter()]
        [System.Boolean]
        $IncludeClientSide,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled', 'Default')]
        [System.String]
        $State = 'Default',

        [Parameter()]
        [System.Boolean]
        $RebootWhenRequired = $false
    )

    Write-Verbose -Message "Getting configuration for protocol $Protocol"

    if ($Protocol -eq 'TLS 1.3')
    {
        $osVersion = Get-SCDscOSVersion
        if ($osVersion.Major -ne 10 -or $osVersion.Build -lt 20000)
        {
            throw "You can only use TLS 1.3 with Windows Server 2022 or later"
        }
    }

    $itemRoot = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols'
    $itemKey = $itemRoot + "\" + $Protocol

    $serverItemKey = $itemKey + '\Server'
    $serverEnabledResult = Get-SChannelItem -ItemKey $serverItemKey
    $serverDisabledByDefaultResult = Get-SChannelItem -ItemKey $serverItemKey `
        -ItemValue 'DisabledByDefault'

    if (($serverEnabledResult -eq 'Enabled' -and $serverDisabledByDefaultResult -eq 'Disabled') -or
        ($serverEnabledResult -eq 'Disabled' -and $serverDisabledByDefaultResult -eq 'Enabled' ) -or
        ($serverEnabledResult -eq 'Default' -and $serverDisabledByDefaultResult -eq 'Default' ))
    {
        $serverResult = $serverEnabledResult
    }

    $clientItemKey = $itemKey + '\Client'
    $clientEnabledResult = Get-SChannelItem -ItemKey $clientItemKey
    $clientDisabledByDefaultResult = Get-SChannelItem -ItemKey $clientItemKey `
        -ItemValue 'DisabledByDefault'
    if (($clientEnabledResult -eq 'Enabled' -and $clientDisabledByDefaultResult -eq 'Disabled') -or
        ($clientEnabledResult -eq 'Disabled' -and $clientDisabledByDefaultResult -eq 'Enabled' ) -or
        ($clientEnabledResult -eq 'Default' -and $clientDisabledByDefaultResult -eq 'Default' ))
    {
        $clientResult = $clientEnabledResult
    }

    $clientside = $false
    if ($serverResult -eq $clientResult)
    {
        $clientside = $true
    }

    $returnValue = @{
        Protocol          = $Protocol
        IncludeClientSide = $clientside
        State             = $serverResult
    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Multi-Protocol Unified Hello", "PCT 1.0", "SSL 2.0", "SSL 3.0", "TLS 1.0", "TLS 1.1", "TLS 1.2", "TLS 1.3")]
        [System.String]
        $Protocol,

        [Parameter()]
        [System.Boolean]
        $IncludeClientSide,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled', 'Default')]
        [System.String]
        $State = 'Default',

        [Parameter()]
        [System.Boolean]
        $RebootWhenRequired = $false
    )

    Write-Verbose -Message "Setting configuration for protocol $Protocol"

    if ($Protocol -eq 'TLS 1.3')
    {
        $osVersion = Get-SCDscOSVersion
        if ($osVersion.Major -ne 10 -or $osVersion.Build -lt 20000)
        {
            throw "You can only use TLS 1.3 with Windows Server 2022 or later"
        }
    }

    $itemRoot = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols'

    if ($IncludeClientSide -eq $true)
    {
        Write-Verbose -Message ($script:localizedData.SetClientProtocol -f $Protocol, $State)
        $clientItemKey = $Protocol + '\Client'

        switch ($State)
        {
            'Default'
            {
                Write-Verbose -Message ($script:localizedData.ItemDefault -f 'Protocol', $Protocol)
            }
            'Disabled'
            {
                Write-Verbose -Message ($script:localizedData.ItemDisable -f 'Protocol', $Protocol)
            }
            'Enabled'
            {
                Write-Verbose -Message ($script:localizedData.ItemEnable -f 'Protocol', $Protocol)
            }
        }
        Set-SChannelItem -ItemKey $itemRoot -ItemSubKey $clientItemKey -State $State -ItemValue 'Enabled'
        Set-SChannelItem -ItemKey $itemRoot -ItemSubKey $clientItemKey -State $State -ItemValue 'DisabledByDefault'
    }

    Write-Verbose -Message ($script:localizedData.SetServerProtocol -f $Protocol, $State)
    $serverItemKey = $Protocol + '\Server'

    switch ($State)
    {
        'Default'
        {
            Write-Verbose -Message ($script:localizedData.ItemDefault -f 'Protocol', $Protocol)
        }
        'Disabled'
        {
            Write-Verbose -Message ($script:localizedData.ItemDisable -f 'Protocol', $Protocol)
        }
        'Enabled'
        {
            Write-Verbose -Message ($script:localizedData.ItemEnable -f 'Protocol', $Protocol)
        }
    }
    Set-SChannelItem -ItemKey $itemRoot -ItemSubKey $serverItemKey -State $State -ItemValue 'Enabled'
    Set-SChannelItem -ItemKey $itemRoot -ItemSubKey $serverItemKey -State $State -ItemValue 'DisabledByDefault'

    if ($RebootWhenRequired)
    {
        $global:DSCMachineStatus = 1
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Multi-Protocol Unified Hello", "PCT 1.0", "SSL 2.0", "SSL 3.0", "TLS 1.0", "TLS 1.1", "TLS 1.2", "TLS 1.3")]
        [System.String]
        $Protocol,

        [Parameter()]
        [System.Boolean]
        $IncludeClientSide,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled', 'Default')]
        [System.String]
        $State = 'Default',

        [Parameter()]
        [System.Boolean]
        $RebootWhenRequired = $false
    )

    Write-Verbose -Message "Testing configuration for protocol $Protocol"

    $CurrentValues = Get-TargetResource -Protocol $Protocol
    $Compliant = $false

    Write-Verbose -Message "Current Values: $(Convert-SCDscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-SCDscHashtableToString -Hashtable $PSBoundParameters)"

    $ErrorActionPreference = "SilentlyContinue"

    if ($CurrentValues.State -eq $State)
    {
        if ($PSBoundParameters.ContainsKey("IncludeClientSide") -eq $true)
        {
            if ($CurrentValues.IncludeClientSide -eq $IncludeClientSide)
            {
                $Compliant = $true
            }
        }
        else
        {
            $Compliant = $true
        }
    }

    if ($Compliant -eq $true)
    {
        Write-Verbose -Message ($script:localizedData.ItemCompliant -f 'Protocol', $Protocol)
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.ItemNotCompliant -f 'Protocol', $Protocol)
    }

    return $Compliant
}

Export-ModuleMember -Function *-TargetResource
