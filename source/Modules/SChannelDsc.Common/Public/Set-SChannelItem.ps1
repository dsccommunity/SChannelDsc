function Set-SChannelItem
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ItemKey,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ItemSubKey,

        [Parameter()]
        [System.String]
        $ItemValue = 'Enabled',

        [Parameter(Mandatory = $true)]
        [ValidateSet('Enabled', 'Disabled', 'Default')]
        [System.String]
        $State,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Protocol
    )

    $fullSubKey = $ItemKey + '\' + $ItemSubKey

    if ($ItemKey -match '(.*:).*')
    {
        $root = $Matches[1]
    }

    $path = ($ItemKey -replace $root, '').TrimStart('\')

    $regKey = (Get-Item -Path $root).OpenSubKey($path, $true)

    switch ($State)
    {
        'Default'
        {
            if (Test-Path -Path $fullSubKey)
            {
                if ($ItemSubKey -match '\\')
                {
                    $fullSubKey = $ItemKey + '\' + ($ItemSubkey -split '\\')[0]
                }
                $null = Remove-Item -Path $fullSubKey -Force -Recurse
            }
        }
        'Disabled'
        {
            if ((Test-Path -Path $fullSubKey) -eq $false)
            {
                $regKey = $regKey.CreateSubKey($ItemSubKey)
            }
            else
            {
                $regKey = $regKey.OpenSubKey($ItemSubKey, $true)
            }

            if ($ItemValue -eq 'DisabledByDefault')
            {
                $null = $regKey.SetValue($ItemValue, 1, [Microsoft.Win32.RegistryValueKind]::DWORD)
            }
            else
            {
                $null = $regKey.SetValue($ItemValue, 0, [Microsoft.Win32.RegistryValueKind]::DWORD)
            }
        }
        'Enabled'
        {
            if ((Test-Path -Path $fullSubKey) -eq $false)
            {
                $regKey = $regKey.CreateSubKey($ItemSubKey)
            }
            else
            {
                $regKey = $regKey.OpenSubKey($ItemSubKey, $true)
            }

            if ($ItemValue -eq 'DisabledByDefault')
            {
                $null = $regKey.SetValue($ItemValue, 0, [Microsoft.Win32.RegistryValueKind]::DWORD)
            }
            else
            {
                if ($Protocol.IsPresent)
                {
                    $null = $regKey.SetValue($ItemValue, 1, [Microsoft.Win32.RegistryValueKind]::DWORD)
                }
                else
                {
                    $null = $regKey.SetValue($ItemValue, 0xffffffff, [Microsoft.Win32.RegistryValueKind]::DWORD)
                }
            }
        }
    }
}
