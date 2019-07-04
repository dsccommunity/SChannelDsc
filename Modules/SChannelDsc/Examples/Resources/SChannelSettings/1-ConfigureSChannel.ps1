<#
.EXAMPLE
    This example shows how to configure SChannel.
#>

    Configuration Example
    {
        param(
        )

        Import-DscResource -ModuleName SChannelDsc

        node localhost {
            SChannelSettings 'ConfigureSChannel'
            {
                IsSingleInstance              = 'Yes'
                TLS12State                    = 'Enabled'
                DiffieHellmanMinClientKeySize = 4096
                DiffieHellmanMinServerKeySize = 4096
                EnableFIPSAlgorithmPolicy     = $false
            }
        }
    }
