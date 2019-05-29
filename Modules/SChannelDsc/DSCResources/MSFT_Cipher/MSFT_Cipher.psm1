# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        ProtocolNotCompliant           = Protocol {0} not compliant.
        ProtocolCompliant              = Protocol {0} compliant.
        ItemTest                       = Testing {0} {1}
        ItemEnable                     = Enabling {0} {1}
        ItemDisable                    = Disabling {0} {1}
        ItemNotCompliant               = {0} {1} not compliant.
        ItemCompliant                  = {0} {1} compliant.

'@
}

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
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Write-Verbose -Message "Getting configuration for cipher $Cipher"

    $RootKey = 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
    $Key = $RootKey + '\' + $cipher
    if ((Test-SChannelItem -itemKey $Key -enable $true) -eq $true)
    {
        $Result = 'Present'
    }
    else
    {
        $Result = 'Absent'
    }

    $returnValue = @{
        Cipher = [System.String]$Cipher
        Ensure = [System.String]$Result
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
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Write-Verbose -Message "Setting configuration for cipher $Cipher"

    $RootKey = 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
    $Key = $RootKey + '\' + $cipher

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ($LocalizedData.ItemEnable -f 'Cipher', $Cipher)
        Switch-SChannelItem -itemKey $Key -enable $true
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.ItemDisable -f 'Cipher', $Cipher)
        Switch-SChannelItem -itemKey $Key -enable $false
    }
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
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Write-Verbose -Message "Testing configuration for cipher $Cipher"

    $currentCipher = Get-TargetResource @PSBoundParameters
    $Compliant = $false

    $ErrorActionPreference = 'SilentlyContinue'
    Write-Verbose -Message ($LocalizedData.ItemTest -f 'Cipher', $Cipher)
    if ($currentCipher.Ensure -eq $Ensure)
    {
        $Compliant = $true
    }

    if ($Compliant -eq $true)
    {
        Write-Verbose -Message ($LocalizedData.ItemCompliant -f 'Cipher', $Cipher)
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.ItemNotCompliant -f 'Cipher', $Cipher)
    }
    return $Compliant
}

Export-ModuleMember -Function *-TargetResource
