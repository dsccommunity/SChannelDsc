## Welcome to the SChannelDsc wiki!

Here you will find all the information you need to make use of the SChannel DSC resources, including details of the resources that are available, current capabilities and known issues.

Please leave comments, feature requests, and bug reports in the [issues section](https://github.com/dsccommunity/SChannelDsc/issues) for this module.

### Getting started

To get started, download SChannelDsc from the [PowerShell Gallery](http://www.powershellgallery.com/packages/SChannelDsc/) and then unzip it to one of your PowerShell modules folders (such as $env:ProgramFiles\WindowsPowerShell\Modules).
To install from the PowerShell gallery using PowerShellGet (in PowerShell 5.0), run the following command:

    Find-Module -Name SChannelDsc -Repository PSGallery | Install-Module

To confirm installation, run the below command and ensure you see the SChannel DSC resources available:

    Get-DscResource -Module SChannelDsc

#### DSC requirements

To run PowerShell DSC, you need to have PowerShell 4.0 or higher (which is included in Windows Management Framework 4.0 or higher).
This version of PowerShell is shipped with Windows Server 2012 R2, and Windows 8.1 or higher.
To use DSC on earlier versions of Windows, install the Windows Management Framework 4.0.
It is strongly recommended that PowerShell 5.0 (or above) is used, however, as it adds support for the PsDscRunAsCredential parameter.
[PowerShell 5.1](https://www.microsoft.com/en-us/download/details.aspx?id=54616) includes significant improvements in Desired State Configuration and PowerShell Script Debugging.

## Included resources

The SChannelDsc module includes the following DSC resources

- [Cipher](Cipher)
- [CipherSuites](CipherSuites)
- [Hash](Hash)
- [Key Exchange Algorithm](KeyExchangeAlgorithm)
- [Protocol](Protocol)
- [SChannelSettings](SChannelSettings)
