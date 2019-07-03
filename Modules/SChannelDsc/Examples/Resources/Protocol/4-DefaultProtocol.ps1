<#
.EXAMPLE
    This example shows how to reset the SSL v3.0 protocol to the OS default.
#>

Configuration Example
{
    param(
    )

    Import-DscResource -ModuleName SChannelDsc

    node localhost {
        Protocol DisableSSLv3
        {
            Protocol = "SSL 3.0"
            State    = "Default"
        }
    }
}
