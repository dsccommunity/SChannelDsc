
<#PSScriptInfo

.VERSION 1.2.0

.GUID 36718e73-0fc0-4d75-9547-97d8b689829b

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
 This example shows how to enable the ECDH key exchange algorithm.

#>

Configuration Example
{
    param ()

    Import-DscResource -ModuleName SChannelDsc

    node localhost
    {
        KeyExchangeAlgorithm EnableECDH
        {
            KeyExchangeAlgorithm = 'ECDH'
            State                = 'Enabled'
        }
    }
}
