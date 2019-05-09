<#
.EXAMPLE
    This example shows how to enable or disable a specific cipher.
#>

    Configuration Example 
    {
        param(
        )

        Import-DscResource -ModuleName SChannelDsc

        node localhost {
            Cipher EnableAES128
            {
                Cipher = "AES 128/128"
                Ensure = "Present"
            }
        }
    }
