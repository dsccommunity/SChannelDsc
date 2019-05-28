# Localized messages
data LocalizedData
{
    # culture='en-US'
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
        [ValidateSet('Diffie-Hellman','ECDH','PKCS')]
        [System.String]
        $KeyExchangeAlgorithm,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )
    $RootKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms'
    $Key = $RootKey + '\' + $KeyExchangeAlgorithm

    if ((Test-SChannelItem -ItemKey $Key -Enable $true) -eq $true)
    {
        $Result = 'Present'
    }
    else
    {
        $Result = 'Absent'
    }

    $returnValue = @{
        KeyExchangeAlgorithm = [System.String]$KeyExchangeAlgorithm
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
        [ValidateSet('Diffie-Hellman','ECDH','PKCS')]
        [System.String]
        $KeyExchangeAlgorithm,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $RootKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms'
    $Key = $RootKey + '\' + $KeyExchangeAlgorithm


    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ($LocalizedData.ItemEnable -f 'KeyExchangeAlgorithm', $KeyExchangeAlgorithm)
        Switch-SChannelItem -ItemKey $Key -Enable $true
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.ItemDisable -f 'KeyExchangeAlgorithm', $KeyExchangeAlgorithm)
        Switch-SChannelItem -ItemKey $Key -Enable $false
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Diffie-Hellman','ECDH','PKCS')]
        [System.String]
        $KeyExchangeAlgorithm,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $currentKEA = Get-TargetResource @PSBoundParameters
    $Compliant = $false

    $ErrorActionPreference = 'SilentlyContinue'
    Write-Verbose -Message ($LocalizedData.ItemTest -f 'KeyExchangeAlgorithm', $KeyExchangeAlgorithm)
    if ($currentKEA.Ensure -eq $Ensure)
    {
        $Compliant = $true
    }

    if ($Compliant -eq $true)
    {
        Write-Verbose -Message ($LocalizedData.ItemCompliant -f 'KeyExchangeAlgorithm', $KeyExchangeAlgorithm)
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.ItemNotCompliant -f 'KeyExchangeAlgorithm', $KeyExchangeAlgorithm)
    }

    return $Compliant
}

Export-ModuleMember -Function *-TargetResource
