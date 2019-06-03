<#
.EXAMPLE
    This example shows how to enable the SSL v3.0 protocol.
#>

    Configuration Example
    {
        param(
        )

        Import-DscResource -ModuleName SChannelDsc

        node localhost {
            Protocol EnableSSLv3
            {
                Protocol = "SSL 3.0"
                Ensure   = "Present"
            }
        }
    }
