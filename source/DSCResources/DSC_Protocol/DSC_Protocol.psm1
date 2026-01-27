$script:sChannelDscHelperModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\SChannelDsc.Common'
$script:resourceHelperModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DscResource.Common'

Import-Module -Name $script:sChannelDscHelperModulePath
Import-Module -Name $script:resourceHelperModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Multi-Protocol Unified Hello', 'PCT 1.0', 'SSL 2.0', 'SSL 3.0', 'TLS 1.0', 'TLS 1.1', 'TLS 1.2', 'TLS 1.3')]
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

    Write-Verbose -Message ($script:localizedData.GettingConfiguration -f $Protocol)

    if ($Protocol -eq 'TLS 1.3')
    {
        $osVersion = Get-SCDscOSVersion
        if ($osVersion.Major -ne 10 -or $osVersion.Build -lt 20000)
        {
            New-InvalidOperationException -Message $script:localizedData.OSVersionNotSupported
        }
    }

    $itemRoot = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols'
    $itemKey = $itemRoot + '\' + $Protocol

    $serverItemKey = $itemKey + '\Server'
    $serverEnabledResult = Get-SChannelItem -ItemKey $serverItemKey
    $serverDisabledByDefaultResult = Get-SChannelItem -ItemKey $serverItemKey -ItemValue 'DisabledByDefault'

    if (($serverEnabledResult -eq 'Enabled' -and $serverDisabledByDefaultResult -eq 'Disabled') -or
        ($serverEnabledResult -eq 'Disabled' -and $serverDisabledByDefaultResult -eq 'Enabled' ) -or
        ($serverEnabledResult -eq 'Default' -and $serverDisabledByDefaultResult -eq 'Default' ))
    {
        $serverResult = $serverEnabledResult
    }

    $clientItemKey = $itemKey + '\Client'
    $clientEnabledResult = Get-SChannelItem -ItemKey $clientItemKey
    $clientDisabledByDefaultResult = Get-SChannelItem -ItemKey $clientItemKey -ItemValue 'DisabledByDefault'
    if (($clientEnabledResult -eq 'Enabled' -and $clientDisabledByDefaultResult -eq 'Disabled') -or
        ($clientEnabledResult -eq 'Disabled' -and $clientDisabledByDefaultResult -eq 'Enabled' ) -or
        ($clientEnabledResult -eq 'Default' -and $clientDisabledByDefaultResult -eq 'Default' ))
    {
        $clientResult = $clientEnabledResult
    }

    $clientSide = $false
    if ($serverResult -eq $clientResult)
    {
        $clientSide = $true
    }

    $returnValue = @{
        Protocol          = $Protocol
        IncludeClientSide = $clientSide
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
        [ValidateSet('Multi-Protocol Unified Hello', 'PCT 1.0', 'SSL 2.0', 'SSL 3.0', 'TLS 1.0', 'TLS 1.1', 'TLS 1.2', 'TLS 1.3')]
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

    Write-Verbose -Message ($script:localizedData.SettingConfiguration -f $Protocol)

    if ($Protocol -eq 'TLS 1.3')
    {
        $osVersion = Get-SCDscOSVersion
        if ($osVersion.Major -ne 10 -or $osVersion.Build -lt 20000)
        {
            New-InvalidOperationException -Message $script:localizedData.OSVersionNotSupported
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
                Write-Verbose -Message ($script:localizedData.ItemDefault -f $Protocol)
            }
            'Disabled'
            {
                Write-Verbose -Message ($script:localizedData.ItemDisable -f $Protocol)
            }
            'Enabled'
            {
                Write-Verbose -Message ($script:localizedData.ItemEnable -f $Protocol)
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
            Write-Verbose -Message ($script:localizedData.ItemDefault -f $Protocol)
        }
        'Disabled'
        {
            Write-Verbose -Message ($script:localizedData.ItemDisable -f $Protocol)
        }
        'Enabled'
        {
            Write-Verbose -Message ($script:localizedData.ItemEnable -f $Protocol)
        }
    }

    Set-SChannelItem -ItemKey $itemRoot -ItemSubKey $serverItemKey -State $State -ItemValue 'Enabled'
    Set-SChannelItem -ItemKey $itemRoot -ItemSubKey $serverItemKey -State $State -ItemValue 'DisabledByDefault'

    if ($RebootWhenRequired)
    {
        Set-DscMachineRebootRequired
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Multi-Protocol Unified Hello', 'PCT 1.0', 'SSL 2.0', 'SSL 3.0', 'TLS 1.0', 'TLS 1.1', 'TLS 1.2', 'TLS 1.3')]
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

    Write-Verbose -Message ($script:localizedData.TestingConfiguration -f $Protocol)

    $compareDscParameterStateParameters = @{
        CurrentValues       = Get-TargetResource @PSBoundParameters
        DesiredValues       = $PSBoundParameters
        ExcludeProperties   = @('RebootWhenRequired')
        TurnOffTypeChecking = $false
    }

    Test-DscParameterState @compareDscParameterStateParameters
}
