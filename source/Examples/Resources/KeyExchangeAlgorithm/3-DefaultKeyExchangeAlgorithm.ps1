
<#PSScriptInfo

.VERSION 1.2.0

.GUID ff3180b6-a198-4180-8c5a-e4b2d78c4325

.AUTHOR DSC Community

.COMPANYNAME DSC Community

.COPYRIGHT DSC Community contributors. All rights reserved.

.TAGS

.LICENSEURI https://github.com/dsccommunity/SChannelDsc/blob/main/LICENSE

.PROJECTURI https://github.com/dsccommunity/SChannelDsc

.ICONURI https://dsccommunity.org/images/DSC_Logo_300p.png

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Updated author, copyright notice, and URLs.

.PRIVATEDATA

#>

<#

.DESCRIPTION
 This example shows how to reset the ECDH key exchange algorithm to the OS default.

#>

Configuration Example
{
    param ()

    Import-DscResource -ModuleName SChannelDsc

    node localhost {
        KeyExchangeAlgorithm DisableECDH
        {
            KeyExchangeAlgorithm = 'ECDH'
            State                = 'Default'
        }
    }
}
