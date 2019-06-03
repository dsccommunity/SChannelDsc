<#
.EXAMPLE
    This example shows how to enable the MD5 hash.
#>

    Configuration Example
    {
        param(
        )

        Import-DscResource -ModuleName SChannelDsc

        node localhost {
            Hash EnableMD5
            {
                Cipher = "MD5"
                Ensure = "Present"
            }
        }
    }
