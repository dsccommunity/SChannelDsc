function Set-SChannelRegKeyValue
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SubKey,

        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [System.Int32]
        $Value,

        [Parameter()]
        [Switch]
        $Remove,

        [Parameter()]
        [Switch]
        $Force
    )

    $fullSubKey = $Key + '\' + $SubKey

    if ($Remove)
    {
        if ($PSBoundParameters.ContainsKey("Name"))
        {
            $null = Remove-ItemProperty -Path $fullSubKey -Name $Name -ErrorAction SilentlyContinue
        }

        # Remove registry key
        if (Test-Path -Path $fullSubKey)
        {
            $item = Get-Item -Path $fullSubKey

            if (($item.ValueCount -eq 0 -and `
                        $item.SubKeyCount -eq 0) -or
                $Force)
            {
                if ($SubKey -match '\\')
                {
                    $fullSubKey = $Key + '\' + ($Subkey -split '\\')[0]
                }
                $null = Remove-Item -Path $fullSubKey -Force -Recurse
            }
        }
    }
    else
    {
        $currentKey = Get-Item -Path $fullSubKey -ErrorAction SilentlyContinue
        if ($null -eq $currentKey)
        {
            $currentKey = New-Item -Path $fullSubKey -Force
        }

        $null = Set-ItemProperty -Path $fullSubKey -Name $Name -Value $Value -Type 'Dword' -Force
    }
}
