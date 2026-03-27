
<#PSScriptInfo

.VERSION 1.2.0

.GUID dce47d32-1538-40d0-8d0b-beedb7c7db38

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
 This example shows how to enable the MD5 hash.

#>

Configuration Example
{
    param ()

    Import-DscResource -ModuleName SChannelDsc

    node localhost
    {
        Hash EnableMD5
        {
            Hash  = 'MD5'
            State = 'Enabled'
        }
    }
}
