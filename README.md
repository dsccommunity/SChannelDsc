## SChannelDsc

[![Build Status](https://dev.azure.com/dsccommunity/SChannelDsc/_apis/build/status/dsccommunity.SChannelDsc?branchName=master)](https://dev.azure.com/dsccommunity/SChannelDsc/_build/latest?definitionId=32&branchName=master)
![Azure DevOps coverage (branch)](https://img.shields.io/azure-devops/coverage/dsccommunity/SChannelDsc/32/master)
[![Azure DevOps tests](https://img.shields.io/azure-devops/tests/dsccommunity/SChannelDsc/32/master)](https://dsccommunity.visualstudio.com/SChannelDsc/_test/analytics?definitionId=32&contextType=build)
[![PowerShell Gallery (with prereleases)](https://img.shields.io/powershellgallery/vpre/SChannelDsc?label=SChannelDsc%20Preview)](https://www.powershellgallery.com/packages/SChannelDsc/)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/SChannelDsc?label=SChannelDsc)](https://www.powershellgallery.com/packages/SChannelDsc/)

The SChannelDsc PowerShell module provides DSC resources that can be used to
manage SChannel settings. It is based of the [cSchannel](https://github.com/bdanse/cSchannel)
resource created by Bart Danse.

Please leave comments, feature requests, and bug reports in the issues tab for
this module.

## Contributing

Please check out common DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing).

## Code of Conduct

This project has adopted this [Code of Conduct](CODE_OF_CONDUCT.md).

## Releases

For each merge to the branch `master` a preview release will be
deployed to [PowerShell Gallery](https://www.powershellgallery.com/).
Periodically a release version tag will be pushed which will deploy a
full release to [PowerShell Gallery](https://www.powershellgallery.com/).

## Installation

To manually install the module, download the source code and unzip the contents
of the \Modules\SChannelDsc directory to the
$env:ProgramFiles\WindowsPowerShell\Modules folder

To install from the [PowerShell Gallery](https://www.powershellgallery.com/packages/SChannelDsc)
using PowerShellGet (in PowerShell 5.0) run the following command:

```PowerShell
Find-Module -Name SChannelDsc -Repository PSGallery | Install-Module
```

To confirm installation, run the below command and ensure you see the
SChannel DSC resoures available:

```PowerShell
Get-DscResource -Module SChannelDsc
```

## Requirements

The minimum PowerShell version required is 4.0, which ships in Windows 8.1
or Windows Server 2012R2 (or higher versions). The preferred version is
PowerShell 5.0 or higher, which ships with Windows 10 or Windows Server 2016.
This is discussed [on the SChannelDsc wiki](https://github.com/dsccommunity/SChannelDsc/wiki/Remote%20sessions%20and%20the%20InstallAccount%20variable),
but generally PowerShell 5 will run the SChannel DSC resources faster and
with improved verbose level logging.

## Documentation and examples

For a full list of resources in SChannelDsc and examples on their use, check
out the [SChannelDsc wiki](https://github.com/dsccommunity/SChannelDsc/wiki).
You can also review the "examples" directory in the SChannelDsc module for
some general use scenarios for all of the resources that are in the module.

## Changelog

A full list of changes in each version can be found in the
[change log](CHANGELOG.md)

## Third Party Notices

\---------------------- START OF THIRD PARTY NOTICES ----------------------

This file incorporates material from the projects listed below (Third Party IP).
[cSchannel](https://github.com/bdanse/cSchannel)
Copyright (c) Bart Danse
License: MIT

MIT License

Copyright (c) 2016

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

\----------------------END OF THIRD PARTY NOTICES----------------------
