<#
.EXAMPLE
    This example shows how to disable the AES 128/128 hash.
#>

    Configuration Example
    {
        param(
        )

        Import-DscResource -ModuleName SChannelDsc

        node localhost {
            Cipher DisableAES128
            {
                Cipher = "AES 128/128"
                State  = "Default"
            }
        }
    }
