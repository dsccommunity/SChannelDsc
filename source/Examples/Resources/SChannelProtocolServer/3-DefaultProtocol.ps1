
<#PSScriptInfo

.VERSION 1.2.0

.GUID d31d24cb-df94-40ff-a03b-3075bf81ab37

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
        SChannelProtocolServer ResetSSLv3
        {
            IsSingleInstance = 'Yes'
            ProtocolsDefault = 'Ssl3'
        }
    }
}
