<#
.EXAMPLE
    This example shows how to reset the AES 128/128 cipher to the OS default.
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
