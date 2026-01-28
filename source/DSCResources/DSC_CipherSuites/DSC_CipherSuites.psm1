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
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [System.String[]]
        $CipherSuitesOrder,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Boolean]
        $RebootWhenRequired = $false
    )

    Write-Verbose -Message $script:localizedData.GettingConfiguration

    $itemKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002'
    $item = Get-ItemProperty -Path $itemKey -Name 'Functions' -ErrorAction SilentlyContinue

    $order = $null
    if ($null -ne $item)
    {
        $Ensure = 'Present'
        $order = (Get-ItemPropertyValue -Path $itemKey -Name 'Functions' -ErrorAction SilentlyContinue).Split(',')
    }
    else
    {
        $Ensure = 'Absent'
    }

    $returnValue = @{
        CipherSuitesOrder = [System.String[]]$order
        Ensure            = [System.String]$Ensure
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [System.String[]]
        $CipherSuitesOrder,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Boolean]
        $RebootWhenRequired = $false
    )

    Write-Verbose -Message $script:localizedData.SettingConfiguration

    $itemKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002'
    $shouldReboot = $false

    if ($Ensure -eq 'Present')
    {
        $cipherSuitesAsString = [string]::join(',', $cipherSuitesOrder)
        Write-Verbose -Message ($script:localizedData.ItemEnable -f $cipherSuitesAsString)
        New-Item $itemKey -Force
        $null = New-ItemProperty -Path $itemKey -Name 'Functions' -Value $cipherSuitesAsString -PropertyType 'String' -Force
        $shouldReboot = $true
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.ItemDisable -f $Ensure)
        Remove-ItemProperty -Path $itemKey -Name 'Functions' -Force
        $shouldReboot = $true
    }

    if ($RebootWhenRequired -and $shouldReboot)
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
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [System.String[]]
        $CipherSuitesOrder,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Boolean]
        $RebootWhenRequired = $false
    )

    Write-Verbose -Message $script:localizedData.TestingConfiguration

    $compareDscParameterStateParameters = @{
        CurrentValues       = Get-TargetResource @PSBoundParameters
        DesiredValues       = $PSBoundParameters
        ExcludeProperties   = @('IsSingleInstance', 'RebootWhenRequired')
        SortArrayValues     = $false
        TurnOffTypeChecking = $false
    }

    Test-DscParameterState @compareDscParameterStateParameters
}
