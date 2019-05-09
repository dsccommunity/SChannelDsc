# Load the Helper Module
Import-Module -Name "$PSScriptRoot\..\Helper.psm1"

# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        ProtocolSetServer              = Setting Server side protocol [{0}] enable {1}.
        ProtocolSetClient              = Setting Client side protocol [{0}] enable {1}.
        ProtocolTestServer             = Testing Server side protocol [{0}] enable {1}.
        ProtocolTestClient             = Testing Client side protocol [{0}] enable {1}.
        ProtocolNotCompliant           = Protocol {0} not compliant.
        ProtocolCompliant              = Protocol {0} compliant.

'@
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Multi-Protocol Unified Hello","PCT 1.0","SSL 2.0","SSL 3.0","TLS 1.0","TLS 1.1","TLS 1.2")]
        [System.String]
        $Protocol,

        [Parameter()]
        [System.Boolean]
        $includeClientSide,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    $itemRoot = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols'
    $itemKey = $itemRoot + "\" + $Protocol

    $sItem = Get-Item -Path ($itemKey + '\Server')  -ErrorAction SilentlyContinue
    if (($sItem | Get-ItemProperty).Enabled -eq 4294967295 -and `
        ($sItem | Get-ItemProperty).DisabledByDefault -eq 0)
    {
        $Ensure = "Present"
    }
    else
    {
        $Ensure = "Absent"
    }

    $cItem = Get-Item -Path ($itemKey + '\Client')  -ErrorAction SilentlyContinue
    if (($cItem | Get-ItemProperty).Enabled -eq ($sItem | Get-ItemProperty).Enabled -and `
        ($cItem | Get-ItemProperty).DisabledByDefault -eq ($sItem | Get-ItemProperty).DisabledByDefault)
    {
         $clientside = $true
    }
    else
    {
        $clientside = $false
    }

    $returnValue = @{
    Protocol = [System.String]$Protocol
    includeClientSide = [System.Boolean]$clientside
    Ensure = [System.String]$Ensure
    }

    $returnValue

}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Multi-Protocol Unified Hello","PCT 1.0","SSL 2.0","SSL 3.0","TLS 1.0","TLS 1.1","TLS 1.2")]
        [System.String]
        $Protocol,

        [Parameter()]
        [System.Boolean]
        $includeClientSide,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    if ($includeClientSide -eq $true)
    {
        Write-Verbose -Message ($LocalizedData.SetClientProtocol -f $Protocol, $Ensure)
        Switch-SchannelProtocol -protocol $Protocol -type Client -enable ($Ensure -eq "Present")
    }

    Write-Verbose -Message ($LocalizedData.SetServerProtocol -f $this.Protocol, $this.Ensure)
    Switch-SchannelProtocol -protocol $Protocol -type Server -enable ($Ensure -eq "Present")
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Multi-Protocol Unified Hello","PCT 1.0","SSL 2.0","SSL 3.0","TLS 1.0","TLS 1.1","TLS 1.2")]
        [System.String]
        $Protocol,

        [Parameter()]
        [System.Boolean]
        $includeClientSide,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    $currentProtocol = Get-TargetResource -Protocol $Protocol
    $Compliant = $false

    $ErrorActionPreference = "SilentlyContinue"
    Write-Verbose -Message ($LocalizedData.TestClientProtocol -f $Protocol, $Ensure)

    $RootKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols'
    $Key = $RootKey + "\" + $Protocol

    if ($currentProtocol.Ensure -eq $Ensure -and $currentProtocol.includeClientSide -eq $includeClientSide -and (Test-Path -Path $Key))
    {
        $Compliant = $true
    }

    if ($Compliant)
    {
        Write-Verbose -Message ($LocalizedData.ProtocolCompliant -f $Protocol, $Ensure)
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.ProtocolNotCompliant -f $Protocol, $this.Ensure)
    }

    return $Compliant
}

Export-ModuleMember -Function *-TargetResource
