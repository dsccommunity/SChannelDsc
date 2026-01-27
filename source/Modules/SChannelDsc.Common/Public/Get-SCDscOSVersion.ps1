function Get-SCDscOSVersion
{
    [CmdletBinding()]
    param ()
    return [System.Environment]::OSVersion.Version
}
