<#
.EXAMPLE
    This example shows how to enable the AES 128/128 hash.
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
                State  = "Enabled"
            }
        }
    }
