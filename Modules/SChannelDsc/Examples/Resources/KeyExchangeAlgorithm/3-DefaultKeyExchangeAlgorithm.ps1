<#
.EXAMPLE
    This example shows how to reset the ECDH key exchange algorithm to the OS default.
#>

Configuration Example
{
    param(
    )

    Import-DscResource -ModuleName SChannelDsc

    node localhost {
        KeyExchangeAlgorithm DisableECDH
        {
            KeyExchangeAlgorithm = "ECDH"
            State                = "Default"
        }
    }
}
