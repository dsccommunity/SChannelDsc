<#
.EXAMPLE
    This example shows how to disable the SSL v3.0 protocol.
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
