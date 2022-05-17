#https://www.hass.de/content/setup-your-iis-ssl-perfect-forward-secrecy-and-tls-12
#https://support.microsoft.com/en-us/kb/245030

<#
    .SYNOPSIS
        Retrieves the localized string data based on the machine's culture.
        Falls back to en-US strings if the machine's culture is not supported.
    .PARAMETER ResourceName
        The name of the resource as it appears before '.strings.psd1' of the localized string file.
        For example:
            For WindowsOptionalFeature: MSFT_WindowsOptionalFeature
            For Service: MSFT_ServiceResource
            For Registry: MSFT_RegistryResource
            For Helper: SqlServerDscHelper
    .PARAMETER ScriptRoot
        Optional. The root path where to expect to find the culture folder. This is only needed
        for localization in helper modules. This should not normally be used for resources.
    .NOTES
        To be able to use localization in the helper function, this function must
        be first in the file, before Get-LocalizedData is used by itself to load
        localized data for this helper module (see directly after this function).
#>
function Get-LocalizedData
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourceName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ScriptRoot
    )

    if (-not $ScriptRoot)
    {
        $dscResourcesFolder = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'DSCResources'
        $resourceDirectory = Join-Path -Path $dscResourcesFolder -ChildPath $ResourceName
    }
    else
    {
        $resourceDirectory = $ScriptRoot
    }

    $localizedStringFileLocation = Join-Path -Path $resourceDirectory -ChildPath $PSUICulture

    if (-not (Test-Path -Path $localizedStringFileLocation))
    {
        # Fallback to en-US
        $localizedStringFileLocation = Join-Path -Path $resourceDirectory -ChildPath 'en-US'
    }

    Import-LocalizedData `
        -BindingVariable 'localizedData' `
        -FileName "$ResourceName.strings.psd1" `
        -BaseDirectory $localizedStringFileLocation

    return $localizedData
}

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
            $str = "$($pair.Key)=$(Convert-SCDscArrayToString -Array $pair.Value)"
        }
        elseif ($pair.Value -is [System.Collections.Hashtable])
        {
            $str = "$($pair.Key)={$(Convert-SCDscHashtableToString -Hashtable $pair.Value)}"
        }
        elseif ($pair.Value -is [Microsoft.Management.Infrastructure.CimInstance])
        {
            $str = "$($pair.Key)=$(Convert-SCDscCIMInstanceToString -CIMInstance $pair.Value)"
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

function Convert-SCDscArrayToString
{
    param
    (
        [Parameter()]
        [System.Array]
        $Array
    )

    $str = "("
    for ($i = 0; $i -lt $Array.Count; $i++)
    {
        $item = $Array[$i]
        if ($item -is [System.Collections.Hashtable])
        {
            $str += "{"
            $str += Convert-SCDscHashtableToString -Hashtable $item
            $str += "}"
        }
        elseif ($Array[$i] -is [Microsoft.Management.Infrastructure.CimInstance])
        {
            $str += Convert-SCDscCIMInstanceToString -CIMInstance $item
        }
        else
        {
            $str += $item
        }

        if ($i -lt ($Array.Count - 1))
        {
            $str += ","
        }
    }
    $str += ")"

    return $str
}

function Convert-SCDscCIMInstanceToString
{
    param
    (
        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $CIMInstance
    )

    $str = "{"
    foreach ($prop in $CIMInstance.CimInstanceProperties)
    {
        if ($str -notmatch "{$")
        {
            $str += "; "
        }
        $str += "$($prop.Name)=$($prop.Value)"
    }
    $str += "}"

    return $str
}

function Get-SCDscOSVersion
{
    [CmdletBinding()]
    param ()
    return [System.Environment]::OSVersion.Version
}

function Get-SChannelItem
{
    [CmdletBinding()]
    [OutputType([System.String])]
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

    if ($null -eq $value)
    {
        return 'Default'
    }

    $value = Get-ItemPropertyValue -Path $ItemKey -Name $ItemValue

    switch ($value)
    {
        $null
        {
            return 'Default'
        }
        0
        {
            return 'Disabled'
        }
        1
        {
            return 'Enabled'
        }
        4294967295
        {
            return 'Enabled'
        } # 0xffffffff
    }
}

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
        $State
    )

    $fullSubKey = $ItemKey + '\' + $ItemSubKey

    if ($ItemKey -match "(.*:).*")
    {
        $root = $Matches[1]
    }

    $path = ($ItemKey -replace $root, "").TrimStart('\')

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
                $null = $regKey.SetValue($ItemValue, 0xffffffff, [Microsoft.Win32.RegistryValueKind]::DWORD)
            }
        }
    }
}

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
        # Update registry key
        if ($Key -match "(.*:).*")
        {
            $root = $Matches[1]
        }

        $path = ($Key -replace $root, "").TrimStart('\')

        $currentKey = Get-Item -Path $fullSubKey -ErrorAction SilentlyContinue
        if ($null -eq $currentKey)
        {
            $currentKey = New-Item -Path $fullSubKey -Force
        }
        $null = Set-ItemProperty -Path $fullSubKey -Name $Name -Value $Value -Type 'Dword' -Force
    }
}

function Test-SCDscObjectHasProperty
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true, Position = 1)]
        [Object]
        $Object,

        [Parameter(Mandatory = $true, Position = 2)]
        [String]
        $PropertyName
    )

    if (([bool]($Object.PSobject.Properties.Name -contains $PropertyName)) -eq $true)
    {
        if ($null -ne $Object.$PropertyName)
        {
            return $true
        }
    }

    return $false
}

$script:localizedData = SChannelDsc.Util\Get-LocalizedData -ResourceName 'SChannelDsc.Util' -ScriptRoot $PSScriptRoot
