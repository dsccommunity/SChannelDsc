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
        [ValidateSet('MD5', 'SHA', 'SHA256', 'SHA384', 'SHA512')]
        [System.String]
        $Hash,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled', 'Default')]
        [System.String]
        $State = 'Default',

        [Parameter()]
        [System.Boolean]
        $RebootWhenRequired = $false
    )

    Write-Verbose -Message ($script:localizedData.GettingConfiguration -f $Hash)

    $rootKey = 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes'
    $key = $rootKey + '\' + $Hash
    $result = Get-SChannelItem -ItemKey $key

    $returnValue = @{
        Hash  = $Hash
        State = $result
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('MD5', 'SHA', 'SHA256', 'SHA384', 'SHA512')]
        [System.String]
        $Hash,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled', 'Default')]
        [System.String]
        $State = 'Default',

        [Parameter()]
        [System.Boolean]
        $RebootWhenRequired = $false
    )

    Write-Verbose -Message ($script:localizedData.SettingConfiguration -f $Hash)

    $rootKey = 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes'

    switch ($State)
    {
        'Default'
        {
            Write-Verbose -Message ($script:localizedData.ItemDefault -f $Hash)
        }
        'Disabled'
        {
            Write-Verbose -Message ($script:localizedData.ItemDisable -f $Hash)
        }
        'Enabled'
        {
            Write-Verbose -Message ($script:localizedData.ItemEnable -f $Hash)
        }
    }

    Set-SChannelItem -ItemKey $rootKey -ItemSubKey $Hash -State $State

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
        [ValidateSet('MD5', 'SHA', 'SHA256', 'SHA384', 'SHA512')]
        [System.String]
        $Hash,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled', 'Default')]
        [System.String]
        $State = 'Default',

        [Parameter()]
        [System.Boolean]
        $RebootWhenRequired = $false
    )

    Write-Verbose -Message ($script:localizedData.TestingConfiguration -f $Hash)

    $compareDscParameterStateParameters = @{
        CurrentValues       = Get-TargetResource @PSBoundParameters
        DesiredValues       = $PSBoundParameters
        ExcludeProperties   = @('RebootWhenRequired')
        TurnOffTypeChecking = $false
    }

    Test-DscParameterState @compareDscParameterStateParameters
}
