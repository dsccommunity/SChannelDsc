<#
.EXAMPLE
    This example shows how to disable the ECDH key exchange algorithm.
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
