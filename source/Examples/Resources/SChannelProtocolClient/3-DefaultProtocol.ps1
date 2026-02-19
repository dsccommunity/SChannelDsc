
<#PSScriptInfo

.VERSION 1.2.0

.GUID 5e62b413-cece-4ef3-bc47-d3c9fd072f8a

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
 This example shows how to reset the SSL v3.0 protocol to the OS default.

#>

Configuration Example
{
    param ()

    Import-DscResource -ModuleName SChannelDsc

    node localhost {
        SChannelProtocolClient ResetSSLv3
        {
            IsSingleInstance = 'Yes'
            ProtocolsDefault = 'Ssl3'
        }
    }
}
