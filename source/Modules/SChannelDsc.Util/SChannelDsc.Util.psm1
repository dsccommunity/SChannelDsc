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

function Compare-PSCustomObjectArrays
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Object[]]
        $DesiredValues,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Object[]]
        $CurrentValues
    )

    $DriftedProperties = @()
    foreach ($DesiredEntry in $DesiredValues)
    {
        $Properties = $DesiredEntry.PSObject.Properties
        $KeyProperty = $Properties.Name[0]

        $EquivalentEntryInCurrent = $CurrentValues | Where-Object -FilterScript { $_.$KeyProperty -eq $DesiredEntry.$KeyProperty }
        if ($null -eq $EquivalentEntryInCurrent)
        {
            $result = @{
                Property     = $DesiredEntry
                PropertyName = $KeyProperty
                Desired      = $DesiredEntry.$KeyProperty
                Current      = $null
            }
            $DriftedProperties += $DesiredEntry
        }
        else
        {
            foreach ($property in $Properties)
            {
                $propertyName = $property.Name

                if ($DesiredEntry.$PropertyName -is [System.Array])
                {
                    $result = Compare-Object -ReferenceObject $DesiredEntry.$PropertyName -DifferenceObject $EquivalentEntryInCurrent.$PropertyName
                    if ($null -ne $result)
                    {
                        $result = @{
                            Property     = $DesiredEntry
                            PropertyName = $PropertyName
                            Desired      = $DesiredEntry.$PropertyName
                            Current      = $EquivalentEntryInCurrent.$PropertyName
                        }
                        $DriftedProperties += $result
                    }
                }
                else
                {
                    if ($DesiredEntry.$PropertyName -ne $EquivalentEntryInCurrent.$PropertyName)
                    {
                        $result = @{
                            Property     = $DesiredEntry
                            PropertyName = $PropertyName
                            Desired      = $DesiredEntry.$PropertyName
                            Current      = $EquivalentEntryInCurrent.$PropertyName
                        }
                        $DriftedProperties += $result
                    }
                }
            }
        }
    }

    return $DriftedProperties
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
            $currentKey = New-Item -Path $fullSubKey
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

function Test-SCDscParameterState
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true, Position = 1)]
        [HashTable]
        $CurrentValues,

        [Parameter(Mandatory = $true, Position = 2)]
        [Object]
        $DesiredValues,

        [Parameter(Position = 3)]
        [Array]
        $ValuesToCheck
    )

    $returnValue = $true

    if (($DesiredValues.GetType().Name -ne "HashTable") -and `
        ($DesiredValues.GetType().Name -ne "CimInstance") -and `
        ($DesiredValues.GetType().Name -ne "PSBoundParametersDictionary"))
    {
        throw ("Property 'DesiredValues' in Test-SCDscParameterState must be either a " + `
                "Hashtable or CimInstance. Type detected was $($DesiredValues.GetType().Name)")
    }

    if (($DesiredValues.GetType().Name -eq "CimInstance") -and ($null -eq $ValuesToCheck))
    {
        throw ("If 'DesiredValues' is a CimInstance then property 'ValuesToCheck' must contain " + `
                "a value")
    }

    if (($null -eq $ValuesToCheck) -or ($ValuesToCheck.Count -lt 1))
    {
        $KeyList = $DesiredValues.Keys
    }
    else
    {
        $KeyList = $ValuesToCheck
    }

    $KeyList | ForEach-Object -Process {
        if ($_ -ne "Verbose")
        {
            if (($CurrentValues.ContainsKey($_) -eq $false) -or `
                ($CurrentValues.$_ -ne $DesiredValues.$_) -or `
                (($DesiredValues.ContainsKey($_) -eq $true) -and `
                    ($null -ne $DesiredValues.$_ -and `
                            $DesiredValues.$_.GetType().IsArray)))
            {
                if ($DesiredValues.GetType().Name -eq "HashTable" -or `
                        $DesiredValues.GetType().Name -eq "PSBoundParametersDictionary")
                {
                    $CheckDesiredValue = $DesiredValues.ContainsKey($_)
                }
                else
                {
                    $CheckDesiredValue = Test-SCDscObjectHasProperty -Object $DesiredValues -PropertyName $_
                }

                if ($CheckDesiredValue)
                {
                    $desiredType = $DesiredValues.$_.GetType()
                    $fieldName = $_
                    if ($desiredType.IsArray -eq $true)
                    {
                        if (($CurrentValues.ContainsKey($fieldName) -eq $false) -or `
                            ($null -eq $CurrentValues.$fieldName))
                        {
                            Write-Verbose -Message ($script:localizedData.EmptyArray -f $fieldName)
                            $returnValue = $false
                        }
                        elseif ($desiredType.Name -eq 'ciminstance[]')
                        {
                            Write-Verbose "The current property {$_} is a CimInstance[]"
                            $AllDesiredValuesAsArray = @()
                            foreach ($item in $DesiredValues.$_)
                            {
                                $currentEntry = @{ }
                                foreach ($prop in $item.CIMInstanceProperties)
                                {
                                    $value = $prop.Value
                                    if ([System.String]::IsNullOrEmpty($value))
                                    {
                                        $value = $null
                                    }
                                    $currentEntry.Add($prop.Name, $value)
                                }
                                $AllDesiredValuesAsArray += [PSCustomObject]$currentEntry
                            }

                            $arrayCompare = Compare-PSCustomObjectArrays -CurrentValues $CurrentValues.$fieldName `
                                -DesiredValues $AllDesiredValuesAsArray
                            if ($null -ne $arrayCompare)
                            {
                                $returnValue = $false
                            }
                        }
                        else
                        {
                            $arrayCompare = Compare-Object -ReferenceObject $CurrentValues.$fieldName `
                                -DifferenceObject $DesiredValues.$fieldName
                            if ($null -ne $arrayCompare -and `
                                    -not [System.String]::IsNullOrEmpty($arrayCompare.InputObject))
                            {
                                Write-Verbose -Message ($script:localizedData.ArrayNotInDesiredState -f $fieldName)
                                $arrayCompare | ForEach-Object -Process {
                                    Write-Verbose -Message ($script:localizedData.ArrayItemIncorrect -f $_.InputObject, $_.SideIndicator)
                                }

                                $returnValue = $false
                            }
                        }
                    }
                    else
                    {
                        switch ($desiredType.Name)
                        {
                            "String"
                            {
                                if ([string]::IsNullOrEmpty($CurrentValues.$fieldName) -and `
                                        [string]::IsNullOrEmpty($DesiredValues.$fieldName))
                                {
                                }
                                else
                                {
                                    Write-Verbose -Message ($script:localizedData.ValueInDesiredState -f "String", $fieldName, $CurrentValues.$fieldName, $DesiredValues.$fieldName)
                                    $returnValue = $false
                                }
                            }
                            "Int32"
                            {
                                if (($DesiredValues.$fieldName -eq 0) -and `
                                    ($null -eq $CurrentValues.$fieldName))
                                {
                                }
                                else
                                {
                                    Write-Verbose -Message ($script:localizedData.ValueInDesiredState -f "Int32", $fieldName, $CurrentValues.$fieldName, $DesiredValues.$fieldName)
                                    $returnValue = $false
                                }
                            }
                            "Int16"
                            {
                                if (($DesiredValues.$fieldName -eq 0) -and `
                                    ($null -eq $CurrentValues.$fieldName))
                                {
                                }
                                else
                                {
                                    Write-Verbose -Message ($script:localizedData.ValueInDesiredState -f "Int16", $fieldName, $CurrentValues.$fieldName, $DesiredValues.$fieldName)
                                    $returnValue = $false
                                }
                            }
                            "Boolean"
                            {
                                if ($CurrentValues.$fieldName -ne $DesiredValues.$fieldName)
                                {
                                    Write-Verbose -Message ($script:localizedData.ValueInDesiredState -f "Boolean", $fieldName, $CurrentValues.$fieldName, $DesiredValues.$fieldName)
                                    $returnValue = $false
                                }
                            }
                            "Single"
                            {
                                if (($DesiredValues.$fieldName -eq 0) -and `
                                    ($null -eq $CurrentValues.$fieldName))
                                {
                                }
                                else
                                {
                                    Write-Verbose -Message ($script:localizedData.ValueInDesiredState -f "Single", $fieldName, $CurrentValues.$fieldName, $DesiredValues.$fieldName)
                                    $returnValue = $false
                                }
                            }
                            "Hashtable"
                            {
                                Write-Verbose -Message "The current property {$fieldName} is a Hashtable"
                                $AllDesiredValuesAsArray = @()
                                foreach ($item in $DesiredValues.$fieldName)
                                {
                                    $currentEntry = @{ }
                                    foreach ($key in $item.Keys)
                                    {
                                        $value = $item.$key
                                        if ([System.String]::IsNullOrEmpty($value))
                                        {
                                            $value = $null
                                        }
                                        $currentEntry.Add($key, $value)
                                    }
                                    $AllDesiredValuesAsArray += [PSCustomObject]$currentEntry
                                }

                                if ($null -ne $DesiredValues.$fieldName -and $null -eq $CurrentValues.$fieldName)
                                {
                                    $returnValue = $false
                                }
                                else
                                {
                                    $AllCurrentValuesAsArray = @()
                                    foreach ($item in $CurrentValues.$fieldName)
                                    {
                                        $currentEntry = @{ }
                                        foreach ($key in $item.Keys)
                                        {
                                            $value = $item.$key
                                            if ([System.String]::IsNullOrEmpty($value))
                                            {
                                                $value = $null
                                            }
                                            $currentEntry.Add($key, $value)
                                        }
                                        $AllCurrentValuesAsArray += [PSCustomObject]$currentEntry
                                    }
                                    $arrayCompare = Compare-PSCustomObjectArrays -CurrentValues $AllCurrentValuesAsArray `
                                        -DesiredValues $AllDesiredValuesAsArray
                                    if ($null -ne $arrayCompare)
                                    {
                                        $returnValue = $false
                                    }
                                }
                            }
                            default
                            {
                                Write-Verbose -Message ($script:localizedData.UnableToCompare -f $fieldName, $desiredType.Name)
                                $returnValue = $false
                            }
                        }
                    }
                }
            }
        }
    }

    return $returnValue
}

$script:localizedData = Get-LocalizedData -ResourceName 'SChannelDsc.Util' -ScriptRoot $PSScriptRoot
