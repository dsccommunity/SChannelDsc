# Localized messages
data LocalizedData
{
    # culture='en-US'
    ConvertFrom-StringData -StringData @'
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
        [ValidateSet('Enabled','Disabled','Default')]
        [System.String]
        $State = 'Default'
    )

    Write-Verbose -Message "Getting configuration for key exchange algorithm $KeyExchangeAlgorithm"

    $rootKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms'
    $key = $rootKey + '\' + $KeyExchangeAlgorithm
    $result = Get-SChannelItem -ItemKey $key

    $returnValue = @{
        KeyExchangeAlgorithm  = $KeyExchangeAlgorithm
        State                 = $result
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
        [ValidateSet('Enabled','Disabled','Default')]
        [System.String]
        $State = 'Default'
    )

    Write-Verbose -Message "Setting configuration for key exchange algorithm $KeyExchangeAlgorithm"

    $rootKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms'

    switch ($State)
    {
        'Default'  {
            Write-Verbose -Message ($LocalizedData.ItemDefault -f 'KeyExchangeAlgorithm', $KeyExchangeAlgorithm)
        }
        'Disabled' {
            Write-Verbose -Message ($LocalizedData.ItemDisable -f 'KeyExchangeAlgorithm', $KeyExchangeAlgorithm)
        }
        'Enabled'  {
            Write-Verbose -Message ($LocalizedData.ItemEnable -f 'KeyExchangeAlgorithm', $KeyExchangeAlgorithm)
        }
    }
    Set-SChannelItem -ItemKey $rootKey -ItemSubKey $KeyExchangeAlgorithm -State $State
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
        [ValidateSet('Enabled','Disabled','Default')]
        [System.String]
        $State = 'Default'
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
        Write-Verbose -Message ($LocalizedData.ItemCompliant -f 'KeyExchangeAlgorithm', $KeyExchangeAlgorithm)
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.ItemNotCompliant -f 'KeyExchangeAlgorithm', $KeyExchangeAlgorithm)
    }

    return $Compliant
}

Export-ModuleMember -Function *-TargetResource
