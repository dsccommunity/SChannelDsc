
<#PSScriptInfo

.VERSION 1.2.0

.GUID 5dcb25fd-9d9d-49d2-a657-60c55578aa02

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
 This example shows how to disable the AES 128/128 hash.

#>

Configuration Example
{
    param ()

    Import-DscResource -ModuleName SChannelDsc

    node localhost
    {
        Cipher DisableAES128
        {
            Cipher = 'AES 128/128'
            State  = 'Disabled'
        }
    }
}
