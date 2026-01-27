<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        resource SChannelDsc module. This file should only contain
        localized strings for private functions, public command, and
        classes (that are not a DSC resource).
#>

ConvertFrom-StringData @'
    ## Assert-TlsProtocol
    Assert_TlsProtocol_NotEnabled = One or more specified protocols are not enabled: {0}. (ATP0001)
    Assert_TlsProtocol_NotDisabled = One or more specified protocols are not disabled: {0}. (ATP0002)

    ## ConvertTo-TlsProtocolRegistryKeyName
    ConvertTo_TlsProtocolRegistryKeyName_UnknownProtocol = Unknown protocol '{0}'. Valid values are Ssl2, Ssl3, Tls, Tls11, Tls12, Tls13. (CTTPRKN0001)

    ## Enable-TlsProtocol
    Enable_TlsProtocol_ShouldProcessDescription = Enable TLS protocol: {0} ({1}). (ETP0001)
    Enable_TlsProtocol_FailedToEnable = Failed to enable protocol '{0}': {1}. (ETP0002)

    ## Disable-TlsProtocol
    Disable_TlsProtocol_ShouldProcessDescription = Disable TLS protocol: {0} ({1}). (DTP0001)
    Disable_TlsProtocol_FailedToDisable = Failed to disable protocol '{0}': {1}. (DTP0002)
'@
