
<#PSScriptInfo

.VERSION 1.2.0

.GUID b2c3d4e5-6f70-8192-a3b4-cdef01234567

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
 This example shows how to configure the Kerberos Supported
 Encryption Types.

#>

Configuration Example
{
    param ()

    Import-DscResource -ModuleName SChannelDsc

    node localhost
    {
        SChannelSettings 'ConfigureKerberosEncrTypes'
        {
            IsSingleInstance                = 'Yes'
            KerberosSupportedEncryptionType = @("RC4-HMAC-MD5","AES128-HMAC-SHA1","AES256-HMAC-SHA1")
        }
    }
}
