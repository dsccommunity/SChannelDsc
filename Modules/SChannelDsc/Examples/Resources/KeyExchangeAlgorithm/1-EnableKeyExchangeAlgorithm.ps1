<#
.EXAMPLE
    This example shows how to enable the ECDH key exchange algorithm.
#>

Configuration Example
{
    param(
    )

    Import-DscResource -ModuleName SChannelDsc

    node localhost {
        KeyExchangeAlgorithm EnableECDH
        {
            KeyExchangeAlgorithm = "ECDH"
            Ensure               = "Present"
        }
    }
}
