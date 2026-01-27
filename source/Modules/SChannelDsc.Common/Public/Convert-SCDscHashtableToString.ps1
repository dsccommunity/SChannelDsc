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
