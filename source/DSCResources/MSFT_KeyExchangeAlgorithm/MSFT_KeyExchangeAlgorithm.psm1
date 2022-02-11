$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'
$script:resourceHelperModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'SChannelDsc.Util'
Import-Module -Name (Join-Path -Path $script:resourceHelperModulePath -ChildPath 'SChannelDsc.Util.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_KeyExchangeAlgorithm'

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Diffie-Hellman', 'ECDH', 'PKCS')]
        [System.String]
        $KeyExchangeAlgorithm,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled', 'Default')]
        [System.String]
        $State = 'Default',

        [Parameter()]
        [System.Boolean]
        $RebootWhenRequired = $false
    )

    Write-Verbose -Message "Getting configuration for key exchange algorithm $KeyExchangeAlgorithm"

    $rootKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms'
    $key = $rootKey + '\' + $KeyExchangeAlgorithm
    $result = Get-SChannelItem -ItemKey $key

    $returnValue = @{
        KeyExchangeAlgorithm = $KeyExchangeAlgorithm
        State                = $result
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Diffie-Hellman', 'ECDH', 'PKCS')]
        [System.String]
        $KeyExchangeAlgorithm,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled', 'Default')]
        [System.String]
        $State = 'Default',

        [Parameter()]
        [System.Boolean]
        $RebootWhenRequired = $false
    )

    Write-Verbose -Message "Setting configuration for key exchange algorithm $KeyExchangeAlgorithm"

    $rootKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms'

    switch ($State)
    {
        'Default'
        {
            Write-Verbose -Message ($script:localizedData.ItemDefault -f 'KeyExchangeAlgorithm', $KeyExchangeAlgorithm)
        }
        'Disabled'
        {
            Write-Verbose -Message ($script:localizedData.ItemDisable -f 'KeyExchangeAlgorithm', $KeyExchangeAlgorithm)
        }
        'Enabled'
        {
            Write-Verbose -Message ($script:localizedData.ItemEnable -f 'KeyExchangeAlgorithm', $KeyExchangeAlgorithm)
        }
    }
    Set-SChannelItem -ItemKey $rootKey -ItemSubKey $KeyExchangeAlgorithm -State $State

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
        [ValidateSet('Diffie-Hellman', 'ECDH', 'PKCS')]
        [System.String]
        $KeyExchangeAlgorithm,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled', 'Default')]
        [System.String]
        $State = 'Default',

        [Parameter()]
        [System.Boolean]
        $RebootWhenRequired = $false
    )

    Write-Verbose -Message "Testing configuration for key exchange algorithm $KeyExchangeAlgorithm"

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
        Write-Verbose -Message ($script:localizedData.ItemCompliant -f 'KeyExchangeAlgorithm', $KeyExchangeAlgorithm)
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.ItemNotCompliant -f 'KeyExchangeAlgorithm', $KeyExchangeAlgorithm)
    }

    return $Compliant
}

Export-ModuleMember -Function *-TargetResource
