function Convert-SCDscHashtableToString
{
    param
    (
        [Parameter()]
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

function Switch-SChannelProtocol
{
    param
    (
        [Parameter()]
        [ValidateSet('Multi-Protocol Unified Hello','PCT 1.0','SSL 2.0','SSL 3.0','TLS 1.0','TLS 1.1','TLS 1.2')]
        [System.String]
        $Protocol,

        [Parameter()]
        [ValidateSet('Server','Client')]
        [System.String]
        $Type,

        [Parameter()]
        [System.Boolean]
        $Enable
    )

    $protocolRootKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols'
    $protocolKey = $protocolRootKey + '\' + $Protocol + '\' + $Type
    if ((Test-Path -Path $protocolKey) -eq $false)
    {
        New-Item -Path $protocolKey -Force | Out-Null
    }

    switch ($Enable)
    {
        $true  { $value = '0xffffffff' }
        $false { $value = '0' }
    }

    New-ItemProperty -Path $protocolKey `
                     -Name 'Enabled' `
                     -Value $value `
                     -PropertyType Dword `
                     -Force | Out-Null

    New-ItemProperty -Path $protocolKey `
                     -Name 'DisabledByDefault' `
                     -Value ([int](-not $Enable)) `
                     -PropertyType Dword `
                     -Force | Out-Null
}

function Test-SChannelItem
{
    param
    (
        [Parameter()]
        [System.String]
        $ItemKey,

        [Parameter()]
        [System.Boolean]
        $Enable
    )

    switch ($Enable)
    {
        $true  { $value = '4294967295' }
        $false { $value = '0' }
    }

    $result = $false
    $ErrorActionPreference = 'SilentlyContinue'
    if ($null -ne (Get-ItemProperty -Path $ItemKey -Name Enabled))
    {
        if ((Get-ItemPropertyValue -Path $ItemKey -Name Enabled) -eq $value)
        {
            $result = $true
        }
    }

    return $result
}

function Switch-SChannelItem
{
    param
    (
        [Parameter()]
        [System.String]
        $ItemKey,

        [Parameter()]
        [System.Boolean]
        $Enable
    )

    if ((Test-Path -Path $ItemKey) -eq $false)
    {
        if ($ItemKey -match '\\SecurityProviders\\SCHANNEL\\Ciphers')
        {
            $itemKeyArray = $ItemKey.Split('\')
            $rootKey = [string]::Join('\', $itemKeyArray[0..4])
            $subKey = $itemKeyArray[5]
            $keyCreate = $itemKeyArray[6]
            [void](Get-Item $rootKey).openSubKey($subKey, $true).CreateSubKey($keyCreate)
        }
        else
        {
            New-Item -Path $ItemKey -Force | Out-Null
        }
    }

    switch ($Enable)
    {
        $true  { $value = '0xffffffff' }
        $false { $value = '0' }
    }

    New-ItemProperty -Path $itemKey `
                     -Name 'Enabled' `
                     -Value $value `
                     -PropertyType Dword `
                     -Force | Out-Null
    #New-ItemProperty -Path $itemKey -Name 'DisabledByDefault' -Value ([int](-not $enable)) -PropertyType Dword -Force | Out-Null
}
