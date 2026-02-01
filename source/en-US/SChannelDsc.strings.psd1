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

    ## Set-TlsProtocolRegistryValue
    Set_TlsProtocolRegistryValue_Enable_ShouldProcessDescription = Enable TLS protocol: {0} ({1}). (STPRV0003)
    Set_TlsProtocolRegistryValue_Enable_ShouldProcessConfirmation = Enable TLS protocol {0}? (STPRV0004)
    Set_TlsProtocolRegistryValue_Enable_ShouldProcessCaption = Enable TLS Protocol (STPRV0005)
    Set_TlsProtocolRegistryValue_FailedToEnable = Failed to enable protocol '{0}'. (STPRV0001)
    Set_TlsProtocolRegistryValue_Disable_ShouldProcessDescription = Disable TLS protocol: {0} ({1}). (STPRV0006)
    Set_TlsProtocolRegistryValue_Disable_ShouldProcessConfirmation = Disable TLS protocol {0}? (STPRV0007)
    Set_TlsProtocolRegistryValue_Disable_ShouldProcessCaption = Disable TLS Protocol (STPRV0008)
    Set_TlsProtocolRegistryValue_FailedToDisable = Failed to disable protocol '{0}'. (STPRV0002)

    ## Test-TlsNegotiation
    Test_TlsNegotiation_TryingProtocol = Attempting TLS negotiation using protocol: {0}. (TTN0001)
    Test_TlsNegotiation_ConnectTimeout = Connect timed out after {0} seconds. (TTN0002)

    ## Reset-TlsProtocol
    Reset_TlsProtocol_ShouldProcessDescription = Reset TLS protocol: {0} ({1}). (RTP0002)
    Reset_TlsProtocol_ShouldProcessConfirmation = Reset TLS protocol {0}? (RTP0003)
    Reset_TlsProtocol_ShouldProcessCaption = Reset TLS Protocol (RTP0004)
    Reset_TlsProtocol_FailedToReset = Failed to reset protocol '{0}'. (RTP0001)
'@
