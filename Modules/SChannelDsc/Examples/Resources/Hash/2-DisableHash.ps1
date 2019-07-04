<#
.EXAMPLE
    This example shows how to disable the MD5 hash.
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
            State = "Disabled"
        }
    }
}
