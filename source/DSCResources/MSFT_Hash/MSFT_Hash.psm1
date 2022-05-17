$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'
$script:resourceHelperModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'SChannelDsc.Util'
Import-Module -Name (Join-Path -Path $script:resourceHelperModulePath -ChildPath 'SChannelDsc.Util.psm1')

$script:localizedData = SChannelDsc.Util\Get-LocalizedData -ResourceName 'MSFT_Hash'

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

    Write-Verbose -Message "Getting configuration for hash $Hash"

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

    Write-Verbose -Message "Setting configuration for hash $Hash"

    $rootKey = 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes'

    switch ($State)
    {
        'Default'
        {
            Write-Verbose -Message ($script:localizedData.ItemDefault -f 'Hash', $Hash)
        }
        'Disabled'
        {
            Write-Verbose -Message ($script:localizedData.ItemDisable -f 'Hash', $Hash)
        }
        'Enabled'
        {
            Write-Verbose -Message ($script:localizedData.ItemEnable -f 'Hash', $Hash)
        }
    }
    Set-SChannelItem -ItemKey $rootKey -ItemSubKey $Hash -State $State

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

    Write-Verbose -Message "Testing configuration for hash $Hash"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $Compliant = $false

    Write-Verbose -Message "Current Values: $(Convert-SCDscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-SCDscHashtableToString -Hashtable $PSBoundParameters)"

    $ErrorActionPreference = 'SilentlyContinue'
    if ($CurrentValues.State -eq $State)
    {
        $Compliant = $true
    }

    if ($Compliant -eq $true)
    {
        Write-Verbose -Message ($script:localizedData.ItemCompliant -f 'Hash', $Hash)
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.ItemNotCompliant -f 'Hash', $Hash)
    }

    return $Compliant
}

Export-ModuleMember -Function *-TargetResource
