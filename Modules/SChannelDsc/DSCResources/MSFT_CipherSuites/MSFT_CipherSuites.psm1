# Load the Helper Module
Import-Module -Name "$PSScriptRoot\..\Helper.psm1"

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
        [Parameter()]
        [System.String[]]
        $CipherSuitesOrder,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    $itemKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002'
    $item = Get-ItemProperty -Path $itemKey -ErrorAction SilentlyContinue

    if ($item)
    {
        $Ensure = 'Present'
        $Order = (Get-ItemPropertyValue -Path $itemKey -Name Functions -ErrorAction SilentlyContinue).Split(',')
    }
    else
    {
        $Ensure = 'Absent'
    }

    $returnValue = @{
        CipherSuitesOrder = [System.String[]]$Order
        Ensure = [System.String]$Ensure
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String[]]
        $CipherSuitesOrder,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    if ($Ensure -eq "Present")
    {
        Write-Verbose -Message ($LocalizedData.ItemEnable -f "CipherSuites" , $Ensure)
        $itemKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002'
        $cipherSuitesAsString = [string]::join(',', $cipherSuitesOrder)
        New-Item $itemKey -Force
        New-ItemProperty -Path $itemKey -Name 'Functions' -Value $cipherSuitesAsString -PropertyType 'String' -Force | Out-Null
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.ItemDisable -f "CipherSuites" , $Ensure)
        $itemKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\'
        Remove-Item $itemKey -Force
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.String[]]
        $CipherSuitesOrder,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    $cipherSuites = Get-TargetResource @PSBoundParameters
    if ($CipherSuitesOrder)
    {
        $cipherSuitesAsString = [string]::join(',', $cipherSuitesOrder)
    }
    if ($cipherSuites.CipherSuitesOrder)
    {
        $currentSuitesOrderAsString = [string]::join(',', $cipherSuites.CipherSuitesOrder)
    }

    $Compliant = $false

    Write-Verbose -Message ($LocalizedData.ItemTest -f "CipherSuitesOrder" , $Ensure)
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

    if ($Compliant)
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
