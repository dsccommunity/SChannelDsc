# Change log for SChannelDsc

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- SChannelDsc
  - Updated tests to support Pester v5
  - Pinned to Sampler v0.105.6 because of issue in 0.106

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
