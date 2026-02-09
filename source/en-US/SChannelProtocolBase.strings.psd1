<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        resource SChannelProtocolBase. This file should only contain
        localized strings for private functions, public command, and
        classes (that are not a DSC resource).
#>

ConvertFrom-StringData @'
    ## Strings overrides for the ResourceBase's default strings.
    # None

    ## Strings directly used by the derived class SChannelProtocolBase.
    DuplicateProtocolValues = Property values cannot be specified multiple times. Ensure that each protocol is only specified once across all protocol properties. (SCHPB0001)
'@
