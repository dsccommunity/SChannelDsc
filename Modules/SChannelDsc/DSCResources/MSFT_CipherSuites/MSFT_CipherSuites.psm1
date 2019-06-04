# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        ItemTest                       = Testing {0} {1}
        ItemEnable                     = Changing {0} {1}
        ItemDisable                    = Removing {0} {1}
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
        [ValidateSet("Yes")]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [System.String[]]
        $CipherSuitesOrder,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    Write-Verbose -Message "Getting configuration for cipher suites order"

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
        [ValidateSet("Yes")]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [System.String[]]
        $CipherSuitesOrder,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    Write-Verbose -Message "Setting configuration for cipher suites order"

    $itemKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002'

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ($LocalizedData.ItemEnable -f 'CipherSuites' , $Ensure)
        $cipherSuitesAsString = [string]::join(',', $cipherSuitesOrder)
        New-Item $itemKey -Force
        New-ItemProperty -Path $itemKey -Name 'Functions' -Value $cipherSuitesAsString -PropertyType 'String' -Force | Out-Null
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.ItemDisable -f 'CipherSuites' , $Ensure)
        Remove-ItemProperty -Path $itemKey -Name 'Functions' -Force
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Yes")]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [System.String[]]
        $CipherSuitesOrder,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    Write-Verbose -Message "Testing configuration for cipher suites order"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-SPDscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-SPDscHashtableToString -Hashtable $PSBoundParameters)"

    if ($null -ne $CipherSuitesOrder)
    {
        $cipherSuitesAsString = [string]::join(',', $cipherSuitesOrder)
    }
    if ($null -ne $CurrentValues.CipherSuitesOrder)
    {
        $currentSuitesOrderAsString = [string]::join(',', $CurrentValues.CipherSuitesOrder)
    }
    else
    {
        $currentSuitesOrderAsString = $null
    }

    $Compliant = $false

    if ($Ensure -eq "Present" -and `
        $currentSuitesOrderAsString -eq $cipherSuitesAsString)
    {
        $Compliant = $true
    }

    if ($Ensure -eq "Absent" -and `
        $null -eq $currentSuitesOrderAsString)
    {
        $Compliant = $true
    }

    if ($Compliant -eq $true)
    {
        Write-Verbose -Message ($LocalizedData.ItemCompliant -f "CipherSuitesOrder" , $Ensure)
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.ItemNotCompliant -f "CipherSuitesOrder" , $Ensure)
    }

    return $Compliant
}

Export-ModuleMember -Function *-TargetResource
