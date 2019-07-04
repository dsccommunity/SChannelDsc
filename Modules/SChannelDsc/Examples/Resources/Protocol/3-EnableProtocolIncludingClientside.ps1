<#
.EXAMPLE
    This example shows how to enable the SSL v3.0 protocol,
    including the client side configuration (outbound).
#>

    Configuration Example
    {
        param(
        )

        Import-DscResource -ModuleName SChannelDsc

        node localhost {
            Protocol EnableSSLv3
            {
                Protocol          = "SSL 3.0"
                IncludeClientSide = $true
                State             = "Enabled"
            }
        }
    }
