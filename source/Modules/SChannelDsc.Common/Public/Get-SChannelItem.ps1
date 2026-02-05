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
        4294967295
        {
            return 'Enabled'
        }
        1
        {
            return 'Enabled'
        }
    }
}
