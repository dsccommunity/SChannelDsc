$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'
$script:resourceHelperModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'SChannelDsc.Util'
Import-Module -Name (Join-Path -Path $script:resourceHelperModulePath -ChildPath 'SChannelDsc.Util.psm1')

$script:localizedData = SChannelDsc.Util\Get-LocalizedData -ResourceName 'MSFT_CipherSuites'

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
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Boolean]
        $RebootWhenRequired = $false
    )

    Write-Verbose -Message "Getting configuration for cipher suites order"

    If (([System.Environment]::OSVersion.Version).Major -lt 10) {
        $itemKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002'
        $item = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -Name 'Functions' -ErrorAction SilentlyContinue).Functions
        If (-Not ($item)) {
            $item = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Cryptography\Configuration\Local\SSL\00010002' -Name 'Functions' -ErrorAction SilentlyContinue).Functions
        }
    }
    Else {
        $item = (Get-TlsCipherSuite).Name
    }

    $order = $null
    if ($null -ne $item)
    {
        $Ensure = 'Present'
        $order = $item
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
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Boolean]
        $RebootWhenRequired = $false
    )

    If ($Ensure -ne 'Absent') {
        Write-Verbose -Message "Setting configuration for cipher suites order"
    }
    If (([System.Environment]::OSVersion.Version).Major -ge 10) {
        if ($Ensure -eq 'Present')
        {
            Write-Verbose -Message ($script:localizedData.ItemEnable -f 'CipherSuites' , $Ensure)
            $Posision = 0
            Foreach ($CipherSuite in $CipherSuitesOrder) {
                Enable-TlsCipherSuite -Name $CipherSuite -Position ($Posision++)
            }
        }
        else
        {
            Write-Verbose -Message ($script:localizedData.ItemDisable -f 'CipherSuites' , $Ensure)
            Foreach ($CipherSuite in $CipherSuitesOrder) {
                Write-Verbose -Message "Disabeling cipher suite $($CipherSuite)"
                Disable-TlsCipherSuite -Name $CipherSuite
            }
        }
    }
    Else {
        If ($Ensure -eq 'Present') {
            Write-Verbose -Message ($script:localizedData.ItemEnable -f 'CipherSuites' , $Ensure)
        }
        Else {
            Write-Verbose -Message ($script:localizedData.ItemDisable -f 'CipherSuites' , $Ensure)
            $item = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -Name 'Functions' -ErrorAction SilentlyContinue).Functions
            If (-Not ($item)) {
                $item = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Cryptography\Configuration\Local\SSL\00010002' -Name 'Functions' -ErrorAction SilentlyContinue).Functions
            }
            [System.Collections.ArrayList]$array = @($item)

            foreach ($CipherSuite in $CipherSuitesOrder){
                while ($array -contains "$CipherSuite") {
                    $array.Remove("$CipherSuite")
                }
            }
            $CipherSuitesOrder = $array
        }
        $itemKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002'
        $cipherSuitesAsString = [string]::join(',', $cipherSuitesOrder)
        New-Item $itemKey -Force
        New-ItemProperty -Path $itemKey -Name 'Functions' -Value $cipherSuitesAsString -PropertyType 'String' -Force | Out-Null
    }

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
        [ValidateSet("Yes")]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [System.String[]]
        $CipherSuitesOrder,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Boolean]
        $RebootWhenRequired = $false
    )

    Write-Verbose -Message "Testing configuration for cipher suites order"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-SCDscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-SCDscHashtableToString -Hashtable $PSBoundParameters)"

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

    if ($Ensure -eq "Absent")
    {
        Foreach ($CipherSuite in $currentSuitesOrderAsString) { 
            If (($currentSuitesOrderAsString).Contains($CipherSuite)) {
                $Compliant = $true
            } 
        }
    }

    if ($Compliant -eq $true)
    {
        Write-Verbose -Message ($script:localizedData.ItemCompliant -f "CipherSuitesOrder" , $Ensure)
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.ItemNotCompliant -f "CipherSuitesOrder" , $Ensure)
    }

    return $Compliant
}

Export-ModuleMember -Function *-TargetResource
