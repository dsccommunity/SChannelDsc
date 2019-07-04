<#
.EXAMPLE
    This example shows how to reset the MD5 hash to the OS default.
#>

Configuration Example
{
    param(
    )

    Import-DscResource -ModuleName SChannelDsc

    node localhost {
        Hash DisableMD5
        {
            Hash  = "MD5"
            State = "Default"
        }
    }
}
