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
        [ValidateSet('AES 128/128', 'AES 256/256', 'DES 56/56', 'NULL', 'RC2 128/128', 'RC2 40/128', 'RC2 56/128', 'RC4 128/128', 'RC4 40/128', 'RC4 56/128', 'RC4 64/128', 'Triple DES 168')]
        [System.String]
        $Cipher,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled', 'Default')]
        [System.String]
        $State = 'Default',

        [Parameter()]
        [System.Boolean]
        $RebootWhenRequired = $false
    )

    Write-Verbose -Message ($script:localizedData.GettingConfiguration -f $Cipher)

    $key = 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\' + $Cipher
    $result = Get-SChannelItem -ItemKey $key

    $returnValue = @{
        Cipher = $Cipher
        State  = $result
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('AES 128/128', 'AES 256/256', 'DES 56/56', 'NULL', 'RC2 128/128', 'RC2 40/128', 'RC2 56/128', 'RC4 128/128', 'RC4 40/128', 'RC4 56/128', 'RC4 64/128', 'Triple DES 168')]
        [System.String]
        $Cipher,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled', 'Default')]
        [System.String]
        $State = 'Default',

        [Parameter()]
        [System.Boolean]
        $RebootWhenRequired = $false
    )

    Write-Verbose -Message ($script:localizedData.SettingConfiguration -f $Cipher)

    $setItemParams = @{
        ItemKey    = 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
        ItemSubKey = $Cipher
        State      = $State
    }

    switch ($State)
    {
        'Default'
        {
            Write-Verbose -Message ($script:localizedData.ItemDefault -f $Cipher)
        }
        'Disabled'
        {
            Write-Verbose -Message ($script:localizedData.ItemDisable -f $Cipher)
        }
        'Enabled'
        {
            Write-Verbose -Message ($script:localizedData.ItemEnable -f $Cipher)
        }
    }

    Set-SChannelItem @setItemParams

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
        [ValidateSet('AES 128/128', 'AES 256/256', 'DES 56/56', 'NULL', 'RC2 128/128', 'RC2 40/128', 'RC2 56/128', 'RC4 128/128', 'RC4 40/128', 'RC4 56/128', 'RC4 64/128', 'Triple DES 168')]
        [System.String]
        $Cipher,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled', 'Default')]
        [System.String]
        $State = 'Default',

        [Parameter()]
        [System.Boolean]
        $RebootWhenRequired = $false
    )

    Write-Verbose -Message ($script:localizedData.TestingConfiguration -f $Cipher)

    $compareDscParameterStateParameters = @{
        CurrentValues       = Get-TargetResource @PSBoundParameters
        DesiredValues       = $PSBoundParameters
        ExcludeProperties   = @('RebootWhenRequired')
        TurnOffTypeChecking = $false
    }

    Test-DscParameterState @compareDscParameterStateParameters
}
