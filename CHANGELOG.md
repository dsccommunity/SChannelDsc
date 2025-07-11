# Changelog for SChannelDsc

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- SChannelDsc
  - Changed the build pipeline to use the build worked image `windows-latest`.
  - Updated repository files from Sampler template.

## [1.4.0] - 2022-05-17

### Changed

- SChannelDsc
  - Moved some documentation from the README.md to the GitHub repository
    wiki page.
  - Updated the pipeline files to use the latest from Sampler.

### Fixed

- SChannelDsc
  - Explicitly use the correct version of the command `Get-LocalizedData`
    ([issue #27](https://github.com/dsccommunity/SChannelDsc/issues/27)).
- SChannelSettings
  - Now the resource imports the dependent module *DscResource.Common*.
  - Now the property `WinHttpDefaultSecureProtocols` always return an array
    even if only one value is set in the current state ([issue #28](https://github.com/dsccommunity/SChannelDsc/issues/28)).

## [1.3.0] - 2022-02-11

### Added

- Cipher
  - Added ability to reboot the machine after update
- CipherSuite
  - Added ability to reboot the machine after update
- Hash
  - Added ability to reboot the machine after update
- KeyExchangeAlgorithm
  - Added ability to reboot the machine after update
- Protocol
  - Added support for TLS 1.3
  - Added ability to reboot the machine after update
- SChannelSettings
  - Added ability to reboot the machine after update

### Changed

- Updated pipeline files.

### Fixed

- Fixed issue #20 in Protocol where IncludeClientSide was always being returned as true causing the resource to always be out of compliance.

## [1.2.2] - 2020-12-16

### Changed

- Updated pipeline files.

### Fixed

- Fixed issue in SChannelSettings where existing Diffie-Hellman settings
  were overwritten.

## [1.2.1] - 2020-09-08

### Changed

- SChannelDsc
  - Prepared upgrade to Pester v5 (wait until code coverage support is added)
  - Removed pin of ModuleBuilder, now always takes the latest version
- Updated pipeline files.

### Fixed

- Fixed issue with SChannelSettings where TLS12 settings weren't applied with
  .Net Framework v4.6.2 or later

## [1.2.0] - 2020-04-30

### Added

- SChannelSettings
  - Added the possiblity to configure the Kerberos Encryption Types
  - Added the possiblity to configure the WinHTTP Default Secure Protocols

### Changed

- SChannelDsc
  - Implemented the new DSC Community CD/CI system

### Deprecated

- None

### Removed

- None

### Fixed

- None

### Security

- None

## [1.1.0.0] - 2020-03-19

### Fixed

- SChannelDsc
  - Updated Readme to correct faulty module name
- Protocol
  - Corrected incorrect detection if DisabledByDefault was configured

## [1.0.0.0] - 2019-07-03

### Added

- Initial public release of SChannelDsc
