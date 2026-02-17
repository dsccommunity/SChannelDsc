
<#PSScriptInfo

.VERSION 1.2.0

.GUID c3d4e5f6-7081-92a3-b4c5-def012345678

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
 This example shows how to configure the WinHTTP Default
 Secure Protocols.

#>

Configuration Example
{
    param ()

    Import-DscResource -ModuleName SChannelDsc

    node localhost
    {
        SChannelSettings 'ConfigureWinHTTPProtocols'
        {
            IsSingleInstance              = 'Yes'
            WinHttpDefaultSecureProtocols = @("TLS1.1", "TLS1.2")
        }
    }
}
