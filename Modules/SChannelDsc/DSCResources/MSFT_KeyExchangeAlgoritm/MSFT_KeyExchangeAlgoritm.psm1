# Load the Helper Module
Import-Module -Name "$PSScriptRoot\..\Helper.psm1"

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
        [ValidateSet("Diffie-Hellman","ECDH","PKCS")]
        [System.String]
        $KeyExchangeAlgoritm,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )
    $RootKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms'
    $Key = $RootKey + "\" + $KeyExchangeAlgoritm

    if (Test-SchannelItem -itemKey $Key -enable $true)
    {
        $Result = "Present"
    }
    else
    {
        $Result = "Absent"
    }

    $returnValue = @{
        KeyExchangeAlgoritm = [System.String]$KeyExchangeAlgoritm
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
        [ValidateSet("Diffie-Hellman","ECDH","PKCS")]
        [System.String]
        $KeyExchangeAlgoritm,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    $RootKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms'
    $Key = $RootKey + "\" + $KeyExchangeAlgoritm


    if ($Ensure -eq "Present")
    {
        Write-Verbose -Message ($LocalizedData.ItemEnable -f 'KeyExchangeAlgoritm', $KeyExchangeAlgoritm)
        Switch-SchannelItem -itemKey $Key -enable $true
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.ItemDisable -f 'KeyExchangeAlgoritm', $KeyExchangeAlgoritm)
        Switch-SchannelItem -itemKey $Key -enable $false
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Diffie-Hellman","ECDH","PKCS")]
        [System.String]
        $KeyExchangeAlgoritm,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )
    $RootKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms'
    $Key = $RootKey + "\" + $KeyExchangeAlgoritm
    $currentKEA = Get-TargetResource @PSBoundParameters
    $Compliant = $false

    $ErrorActionPreference = "SilentlyContinue"
    Write-Verbose -Message ($LocalizedData.ItemTest -f 'KeyExchangeAlgoritm', $Cipher)
    if ($currentKEA.Ensure -eq $Ensure -and (Get-ItemProperty -Path $Key -Name Enabled))
    {
        $Compliant = $true
    }

    if ($Compliant)
    {
        Write-Verbose -Message ($LocalizedData.ItemCompliant -f 'KeyExchangeAlgoritm', $KeyExchangeAlgoritm)
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.ItemNotCompliant -f 'KeyExchangeAlgoritm', $KeyExchangeAlgoritm)
    }
    return $Compliant
}

Export-ModuleMember -Function *-TargetResource
