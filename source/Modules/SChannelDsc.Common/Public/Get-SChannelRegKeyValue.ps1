function Get-SChannelRegKeyValue
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    $value = Get-ItemProperty -Path $Key -Name $Name -ErrorAction SilentlyContinue

    if ($null -eq $value)
    {
        return $null
    }

    $value = Get-ItemPropertyValue -Path $Key -Name $Name

    return $value
}
