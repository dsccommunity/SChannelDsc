function Convert-SCDscHashtableToString
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Hashtable
    )
    $values = @()
    foreach ($pair in $Hashtable.GetEnumerator())
    {
        if ($pair.Value -is [System.Array])
        {
            $str = "$($pair.Key)=($($pair.Value -join ","))"
        }
        elseif ($pair.Value -is [System.Collections.Hashtable])
        {
            $str = "$($pair.Key)={$(Convert-SCDscHashtableToString -Hashtable $pair.Value)}"
        }
        else
        {
            $str = "$($pair.Key)=$($pair.Value)"
        }
        $values += $str
    }

    [array]::Sort($values)
    return ($values -join "; ")
}

#https://www.hass.de/content/setup-your-iis-ssl-perfect-forward-secrecy-and-tls-12
#https://support.microsoft.com/en-us/kb/245030
function Get-SChannelItem
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ItemKey,

        [Parameter()]
        [System.String]
        $ItemValue = 'Enabled'
    )

    $value = Get-ItemProperty -Path $ItemKey -Name $ItemValue -ErrorAction SilentlyContinue
    switch ($value)
    {
        $null { return 'Default' }
        0     { return 'Disabled' }
        1     { return 'Enabled' }
        0xffffffff { return 'Enabled' }
    }
}

function Set-SChannelItem
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ItemKey,

        [Parameter()]
        [System.String]
        $ItemValue = 'Enabled',

        [Parameter(Mandatory = $true)]
        [ValidateSet('Enabled','Disabled','Default')]
        [System.String]
        $State
    )

    switch ($State)
    {
        'Default'  {
            if (Test-Path -Path $ItemKey)
            {
                Remove-Item -Path $ItemKey -Force
            }
        }
        'Disabled' {
            if ((Test-Path -Path $ItemKey) -eq $false)
            {
                New-Item -Path $ItemKey -Force | Out-Null
            }
            New-ItemProperty -Path $ItemKey `
                             -Name $ItemValue `
                             -Value '0x0' `
                             -PropertyType Dword `
                             -Force | Out-Null
        }
        'Enabled'  {
            if ((Test-Path -Path $ItemKey) -eq $false)
            {
                New-Item -Path $ItemKey -Force | Out-Null
            }
            New-ItemProperty -Path $ItemKey `
                             -Name $ItemValue `
                             -Value '0xffffffff' `
                             -PropertyType Dword `
                             -Force | Out-Null
        }
    }
}
