# Localized messages
data LocalizedData
{
    # culture='en-US'
    ConvertFrom-StringData -StringData @'
        ItemTest                       = Testing {0} {1}
        ItemEnable                     = Enabling {0} {1}
        ItemDisable                    = Disabling {0} {1}
        ItemDefault                    = Defaulting {0} {1}
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
        [ValidateSet('MD5','SHA','SHA256','SHA384','SHA512')]
        [System.String]
        $Hash,

        [Parameter()]
        [ValidateSet('Enabled','Disabled','Default')]
        [System.String]
        $State = 'Default'
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
        [ValidateSet('MD5','SHA','SHA256','SHA384','SHA512')]
        [System.String]
        $Hash,

        [Parameter()]
        [ValidateSet('Enabled','Disabled','Default')]
        [System.String]
        $State = 'Default'
    )

    Write-Verbose -Message "Setting configuration for hash $Hash"

    $rootKey = 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes'
    $key = $rootKey + '\' + $Hash

    switch ($State)
    {
        'Default'  {
            Write-Verbose -Message ($LocalizedData.ItemDefault -f 'Hash', $Hash)
            Set-SChannelItem -ItemKey $key -State $State
        }
        'Disabled' {
            Write-Verbose -Message ($LocalizedData.ItemDisable -f 'Hash', $Hash)
            Set-SChannelItem -ItemKey $key -State $State
        }
        'Enabled'  {
            Write-Verbose -Message ($LocalizedData.ItemEnable -f 'Hash', $Hash)
            Set-SChannelItem -ItemKey $key -State $State
        }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('MD5','SHA','SHA256','SHA384','SHA512')]
        [System.String]
        $Hash,

        [Parameter()]
        [ValidateSet('Enabled','Disabled','Default')]
        [System.String]
        $State = 'Default'
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
        Write-Verbose -Message ($LocalizedData.ItemCompliant -f 'Hash', $Hash)
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.ItemNotCompliant -f 'Hash', $Hash)
    }

    return $Compliant
}

Export-ModuleMember -Function *-TargetResource
