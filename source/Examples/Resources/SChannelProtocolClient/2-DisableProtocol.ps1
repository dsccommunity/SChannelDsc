
<#PSScriptInfo

.VERSION 1.2.0

.GUID f52c4bf0-5e6f-4516-9055-920b7f0c5fbc

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
 This example shows how to disable the SSL v3.0 protocol.

#>

Configuration Example
{
    param ()

    Import-DscResource -ModuleName SChannelDsc

    node localhost {
        SChannelProtocolClient DisableSSLv3
        {
            IsSingleInstance  = 'Yes'
            ProtocolsDisabled = 'Ssl3'
        }
    }
}
