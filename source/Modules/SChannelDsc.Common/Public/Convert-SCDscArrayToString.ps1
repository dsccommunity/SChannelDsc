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
