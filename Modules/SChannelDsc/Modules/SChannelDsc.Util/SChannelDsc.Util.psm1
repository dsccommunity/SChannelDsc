#https://www.hass.de/content/setup-your-iis-ssl-perfect-forward-secrecy-and-tls-12
#https://support.microsoft.com/en-us/kb/245030

function Convert-SCDscHashtableToString
{
    [CmdletBinding()]
    [OutputType([System.String])]
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

        $regKey = (Get-Item -Path $root).OpenSubKey($path, $true)

        if ((Test-Path -Path $fullSubKey) -eq $false)
        {
            $regKey = $regKey.CreateSubKey($SubKey)
        }
        else
        {
            $regKey = $regKey.OpenSubKey($SubKey, $true)
        }

        $null = $regKey.SetValue($Name, $Value, [Microsoft.Win32.RegistryValueKind]::DWORD)
    }
}

function Test-SCDscObjectHasProperty
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true,Position=1)]
        [Object]
        $Object,

        [Parameter(Mandatory = $true,Position=2)]
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
        [Parameter(Mandatory = $true, Position=1)]
        [HashTable]
        $CurrentValues,

        [Parameter(Mandatory = $true, Position=2)]
        [Object]
        $DesiredValues,

        [Parameter(, Position=3)]
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
                            Write-Verbose -Message ("Expected to find an array value for " + `
                                                    "property $fieldName in the current " + `
                                                    "values, but it was either not present or " + `
                                                    "was null. This has caused the test method " + `
                                                    "to return false.")
                            $returnValue = $false
                        }
                        else
                        {
                            $arrayCompare = Compare-Object -ReferenceObject $CurrentValues.$fieldName `
                                                           -DifferenceObject $DesiredValues.$fieldName
                            if ($null -ne $arrayCompare)
                            {
                                Write-Verbose -Message ("Found an array for property $fieldName " + `
                                                        "in the current values, but this array " + `
                                                        "does not match the desired state. " + `
                                                        "Details of the changes are below.")
                                $arrayCompare | ForEach-Object -Process {
                                    Write-Verbose -Message "$($_.InputObject) - $($_.SideIndicator)"
                                }
                                $returnValue = $false
                            }
                        }
                    }
                    else
                    {
                        switch ($desiredType.Name)
                        {
                            "String" {
                                if ([string]::IsNullOrEmpty($CurrentValues.$fieldName) -and `
                                    [string]::IsNullOrEmpty($DesiredValues.$fieldName))
                                {}
                                else
                                {
                                    Write-Verbose -Message ("String value for property " + `
                                                            "$fieldName does not match. " + `
                                                            "Current state is " + `
                                                            "'$($CurrentValues.$fieldName)' " + `
                                                            "and desired state is " + `
                                                            "'$($DesiredValues.$fieldName)'")
                                    $returnValue = $false
                                }
                            }
                            "Int32" {
                                if (($DesiredValues.$fieldName -eq 0) -and `
                                    ($null -eq $CurrentValues.$fieldName))
                                {}
                                else
                                {
                                    Write-Verbose -Message ("Int32 value for property " + `
                                                            "$fieldName does not match. " + `
                                                            "Current state is " + `
                                                            "'$($CurrentValues.$fieldName)' " + `
                                                            "and desired state is " + `
                                                            "'$($DesiredValues.$fieldName)'")
                                    $returnValue = $false
                                }
                            }
                            "Int16" {
                                if (($DesiredValues.$fieldName -eq 0) -and `
                                    ($null -eq $CurrentValues.$fieldName))
                                {}
                                else
                                {
                                    Write-Verbose -Message ("Int16 value for property " + `
                                                            "$fieldName does not match. " + `
                                                            "Current state is " + `
                                                            "'$($CurrentValues.$fieldName)' " + `
                                                            "and desired state is " + `
                                                            "'$($DesiredValues.$fieldName)'")
                                    $returnValue = $false
                                }
                            }
                            "Boolean" {
                                if ($CurrentValues.$fieldName -ne $DesiredValues.$fieldName)
                                {
                                    Write-Verbose -Message ("Boolean value for property " + `
                                                            "$fieldName does not match. " + `
                                                            "Current state is " + `
                                                            "'$($CurrentValues.$fieldName)' " + `
                                                            "and desired state is " + `
                                                            "'$($DesiredValues.$fieldName)'")
                                    $returnValue = $false
                                }
                            }
                            "Single" {
                                if (($DesiredValues.$fieldName -eq 0) -and `
                                    ($null -eq $CurrentValues.$fieldName))
                                {}
                                else
                                {
                                    Write-Verbose -Message ("Single value for property " + `
                                                            "$fieldName does not match. " + `
                                                            "Current state is " + `
                                                            "'$($CurrentValues.$fieldName)' " + `
                                                            "and desired state is " + `
                                                            "'$($DesiredValues.$fieldName)'")
                                    $returnValue = $false
                                }
                            }
                            default {
                                Write-Verbose -Message ("Unable to compare property $fieldName " + `
                                                        "as the type ($($desiredType.Name)) is " + `
                                                        "not handled by the " + `
                                                        "Test-SCDscParameterState cmdlet")
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
