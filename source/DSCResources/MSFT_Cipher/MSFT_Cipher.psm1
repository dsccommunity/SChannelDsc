$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'
$script:resourceHelperModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'SChannelDsc.Util'
Import-Module -Name (Join-Path -Path $script:resourceHelperModulePath -ChildPath 'SChannelDsc.Util.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_Cipher'

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('AES 128/128','AES 256/256','DES 56/56','NULL','RC2 128/128','RC2 40/128','RC2 56/128','RC4 128/128','RC4 40/128','RC4 56/128','RC4 64/128','Triple DES 168')]
        [System.String]
        $Cipher,

        [Parameter()]
        [ValidateSet('Enabled','Disabled','Default')]
        [System.String]
        $State = 'Default'
    )

    Write-Verbose -Message "Getting configuration for cipher $Cipher"

    $rootKey = 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
    $key = $rootKey + '\' + $Cipher
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
        [ValidateSet('AES 128/128','AES 256/256','DES 56/56','NULL','RC2 128/128','RC2 40/128','RC2 56/128','RC4 128/128','RC4 40/128','RC4 56/128','RC4 64/128','Triple DES 168')]
        [System.String]
        $Cipher,

        [Parameter()]
        [ValidateSet('Enabled','Disabled','Default')]
        [System.String]
        $State = 'Default'
    )

    Write-Verbose -Message "Setting configuration for cipher $Cipher"

    $rootKey = 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'

    switch ($State)
    {
        'Default'  {
            Write-Verbose -Message ($script:localizedData.ItemDefault -f 'Cipher', $Cipher)
        }
        'Disabled' {
            Write-Verbose -Message ($script:localizedData.ItemDisable -f 'Cipher', $Cipher)
        }
        'Enabled'  {
            Write-Verbose -Message ($script:localizedData.ItemEnable -f 'Cipher', $Cipher)
        }
    }
    Set-SChannelItem -ItemKey $rootKey -ItemSubKey $Cipher -State $State
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('AES 128/128','AES 256/256','DES 56/56','NULL','RC2 128/128','RC2 40/128','RC2 56/128','RC4 128/128','RC4 40/128','RC4 56/128','RC4 64/128','Triple DES 168')]
        [System.String]
        $Cipher,

        [Parameter()]
        [ValidateSet('Enabled','Disabled','Default')]
        [System.String]
        $State = 'Default'
    )

    Write-Verbose -Message "Testing configuration for cipher $Cipher"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $compliant = $false

    Write-Verbose -Message "Current Values: $(Convert-SCDscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-SCDscHashtableToString -Hashtable $PSBoundParameters)"

    $ErrorActionPreference = 'SilentlyContinue'
    if ($CurrentValues.State -eq $State)
    {
        $compliant = $true
    }

    if ($compliant -eq $true)
    {
        Write-Verbose -Message ($script:localizedData.ItemCompliant -f 'Cipher', $Cipher)
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.ItemNotCompliant -f 'Cipher', $Cipher)
    }
    return $compliant
}

Export-ModuleMember -Function *-TargetResource
