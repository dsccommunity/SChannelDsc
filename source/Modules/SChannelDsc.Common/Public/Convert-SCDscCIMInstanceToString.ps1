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
