# SChannelDsc

The SChannelDsc PowerShell module provides DSC resources that can be used to
manage SChannel settings. It is based of the [cSchannel](https://github.com/bdanse/cSchannel)
resource created by Bart Danse.

Please leave comments, feature requests, and bug reports in the issues tab for
this module.

If you would like to modify SharePointDsc module, please feel free. Please
refer to the [Contribution Guidelines](https://github.com/Microsoft/SChannelDsc/wiki/Contributing%20to%20SChannelDSC)
for information about style guides, testing and patterns for contributing
to DSC resources.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/)
or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any
additional questions or comments.

## Branches

### master

[![Build status](https://ci.appveyor.com/api/projects/status/aj6ce04iy5j4qcd4/branch/master?svg=true)](https://ci.appveyor.com/project/Microsoft/SChannelDsc/branch/master)
[![codecov](https://codecov.io/gh/Microsoft/SChannelDsc/branch/master/graph/badge.svg)](https://codecov.io/gh/Microsoft/SChannelDsc/branch/master)

This is the branch containing the latest release -
no contributions should be made directly to this branch.

### dev

[![Build status](https://ci.appveyor.com/api/projects/status/aj6ce04iy5j4qcd4/branch/dev?svg=true)](https://ci.appveyor.com/project/Microsoft/SChannelDsc/branch/dev)
[![codecov](https://codecov.io/gh/Microsoft/SChannelDsc/branch/dev/graph/badge.svg)](https://codecov.io/gh/Microsoft/SChannelDsc/branch/dev)

This is the development branch to which contributions should be proposed by
contributors as pull requests. This development branch will periodically be
merged to the master branch, and be released to the
[PowerShell Gallery](https://www.powershellgallery.com/).

## Installation

To manually install the module, download the source code and unzip the contents
of the \Modules\SChannelDsc directory to the
$env:ProgramFiles\WindowsPowerShell\Modules folder

To install from the PowerShell gallery using PowerShellGet (in PowerShell 5.0)
run the following command:

    Find-Module -Name SChannelDsc -Repository PSGallery | Install-Module

To confirm installation, run the below command and ensure you see the
SharePoint DSC resoures available:

    Get-DscResource -Module SChannelDsc

## Requirements

The minimum PowerShell version required is 4.0, which ships in Windows 8.1
or Windows Server 2012R2 (or higher versions). The preferred version is
PowerShell 5.0 or higher, which ships with Windows 10 or Windows Server 2016.
This is discussed [on the SChannelDsc wiki](https://github.com/Microsoft/SChannelDsc/wiki/Remote%20sessions%20and%20the%20InstallAccount%20variable),
but generally PowerShell 5 will run the SChannel DSC resources faster and
with improved verbose level logging.

## Documentation and examples

For a full list of resources in SChannelDsc and examples on their use, check
out the [SChannelDsc wiki](https://github.com/Microsoft/SChannelDsc/wiki).
You can also review the "examples" directory in the SChannelDsc module for
some general use scenarios for all of the resources that are in the module.

## Changelog

A full list of changes in each version can be found in the
[change log](CHANGELOG.md)

## Project Throughput

[![Throughput Graph](https://graphs.waffle.io/Microsoft/SChannelDsc/throughput.svg)](https://waffle.io/Microsoft/SChannelDsc/metrics/throughput)

---------------------- START OF THIRD PARTY NOTICES ----------------------
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
----------------------END OF THIRD PARTY NOTICES----------------------
