#https://www.hass.de/content/setup-your-iis-ssl-perfect-forward-secrecy-and-tls-12
#https://support.microsoft.com/nl-nl/kb/245030

#region Helper function
function Switch-SchannelProtocol
{
    param(
        [ValidateSet('Multi-Protocol Unified Hello','PCT 1.0','SSL 2.0','SSL 3.0','TLS 1.0','TLS 1.1','TLS 1.2')]
        [string]$protocol,
        [ValidateSet("Server","Client")] 
        [string]$type,
        [bool]$enable
    )
    $protocalRootKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols' 
    $protocalKey = $protocalRootKey + "\" + $protocol + "\" + $type
    if(-not (Test-Path -Path $protocalKey))
    {
        New-Item -Path $protocalKey -Force | Out-Null
    }

    switch ($enable)
    {
        True {$value = '0xffffffff'}
        False {$value = '0'}
    }

    New-ItemProperty -Path $protocalKey -Name 'Enabled' -Value $value -PropertyType Dword -Force | Out-Null
    New-ItemProperty -Path $protocalKey -Name 'DisabledByDefault' -Value ([int](-not $enable)) -PropertyType Dword -Force | Out-Null
}

function Test-SchannelItem
{
    param(
        [string]$itemKey,
        [bool]$enable
    )
    
    switch ($enable)
    {
        True {$value = '4294967295'}
        False {$value = '0'}
    }

    $result = $false
    $ErrorActionPreference = "SilentlyContinue"
    if(Get-ItemProperty -Path $itemKey -Name Enabled)
    { 
        if ((Get-ItemPropertyValue -Path $itemKey -Name Enabled) -eq $value)
        {
            $result = $true
        }
    }
    return $result
}

function Switch-SchannelItem
{
    param(
        [string]$itemKey,
        [bool]$enable
    )

    if(-not (Test-Path -Path $itemKey))
    {
        if($itemKey -match "\\SecurityProviders\\SCHANNEL\\Ciphers")
        {
            $itemKeyArray = $itemKey.Split('\')
            $rootKey = [string]::Join('\', $itemKeyArray[0..4])
            $subKey = $itemKeyArray[5]
            $keyCreate = $itemKeyArray[6]
            [void](Get-Item $rootKey).openSubKey($subKey, $true).CreateSubKey($keyCreate)
        }
        else
        {
            New-Item -Path $itemKey -Force | Out-Null
        }
    }
    switch ($enable)
    {
        True {$value = '0xffffffff'}
        False {$value = '0'}
    }

    New-ItemProperty -Path $itemKey -Name 'Enabled' -Value $value -PropertyType Dword -Force | Out-Null
    #New-ItemProperty -Path $itemKey -Name 'DisabledByDefault' -Value ([int](-not $enable)) -PropertyType Dword -Force | Out-Null
    
}

#endregion
