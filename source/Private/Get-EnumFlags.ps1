<#
    .SYNOPSIS
        Expands a [Flags] enum value into its individual flags.

    .DESCRIPTION
        Accepts an enum value and returns the individual enum members that are set.

    .PARAMETER Value
        The enum value (or numeric value) to expand. Can be a pipeline input.

    .OUTPUTS
        System.Enum

    .EXAMPLE
        Get-EnumFlags -Value ([SChannelSslProtocols]::Tls12 -bor [SChannelSslProtocols]::Tls13)
#>
function Get-EnumFlags
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [System.Enum]
        $Value
    )

    process
    {
        $enumType = $Value.GetType()

        foreach ($flag in [Enum]::GetValues($enumType))
        {
            if ([System.Int32] $flag -ne 0 -and $Value.HasFlag($flag))
            {
                $flag
            }
        }
    }
}
