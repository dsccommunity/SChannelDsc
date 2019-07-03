# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        ItemTest                       = Testing {0} {1}
        ItemEnable                     = Enabling {0} {1}
        ItemDisable                    = Disabling {0} {1}
        ItemDefault                    = Defaulting {0} {1}
        ItemNotCompliant               = {0} not compliant.
        ItemCompliant                  = {0} compliant.
'@
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Yes")]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled', 'Default')]
        [System.String]
        $TLS12State,

        [Parameter()]
        [ValidateSet(1024, 2048, 3072, 4096)]
        [System.UInt32]
        $DiffieHellmanMinClientKeySize,

        [Parameter()]
        [ValidateSet(1024, 2048, 3072, 4096)]
        [System.UInt32]
        $DiffieHellmanMinServerKeySize,

        [Parameter()]
        [System.Boolean]
        $EnableFIPSAlgorithmPolicy
    )

    Write-Verbose -Message "Getting SChannel configuration settings"

    # TLS v1.2 state for the .Net Framework
    Write-Verbose -Message "Getting TLS v1.2 state"

    $currentTls12State = $null

    $dotnetKey = 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
    $keyExists = Get-ItemProperty -Path $dotnetKey -ErrorAction SilentlyContinue

    # Only check TLS12State if .Net Framework is 4.5 or lower
    # https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
    if ($null -eq $keyExists -or
        (Get-ItemPropertyValue -Path $dotnetKey -Name Release) -lt 390000)
    {
        # 64 bit keys
        Write-Verbose -Message "Used .Net Framework 4.5 or lower"

        # .Net Framework 2.0 - 3.5
        $dotnet2Key = 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727'
        $dotnet4Key = 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319'

        $net2DefaultTLSVersions = Get-SChannelRegKeyValue -Key $dotnet2Key `
                                                          -Name 'SystemDefaultTlsVersions'
        $net2StrongCrypto       = Get-SChannelRegKeyValue -Key $dotnet2Key `
                                                          -Name 'SchUseStrongCrypto'
        $net4DefaultTLSVersions = Get-SChannelRegKeyValue -Key $dotnet4Key `
                                                          -Name 'SystemDefaultTlsVersions'
        $net4StrongCrypto       = Get-SChannelRegKeyValue -Key $dotnet4Key `
                                                          -Name 'SchUseStrongCrypto'

        if (Test-Path -Path 'HKLM:\SOFTWARE\Wow6432Node')
        {
            # 32 bit keys
            $dotnet2Key = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727'
            $dotnet4Key = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319'

            $net2DefaultTLSVersions32 = Get-SChannelRegKeyValue -Key $dotnet2Key `
                                                                -Name 'SystemDefaultTlsVersions'
            $net2StrongCrypto32       = Get-SChannelRegKeyValue -Key $dotnet2Key `
                                                                -Name 'SchUseStrongCrypto'
            $net4DefaultTLSVersions32 = Get-SChannelRegKeyValue -Key $dotnet4Key `
                                                                -Name 'SystemDefaultTlsVersions'
            $net4StrongCrypto32       = Get-SChannelRegKeyValue -Key $dotnet4Key `
                                                                -Name 'SchUseStrongCrypto'

            if ($null -eq $net2DefaultTLSVersions -and
                $null -eq $net2StrongCrypto -and
                $null -eq $net4DefaultTLSVersions -and
                $null -eq $net4StrongCrypto -and
                $null -eq $net2DefaultTLSVersions32 -and
                $null -eq $net2StrongCrypto32 -and
                $null -eq $net4DefaultTLSVersions32 -and
                $null -eq $net4StrongCrypto32)
            {
                $currentTls12State = "Default"
            }

            if ($net2DefaultTLSVersions -eq 1 -and
                $net2StrongCrypto -eq 1 -and
                $net4DefaultTLSVersions -eq 1 -and
                $net4StrongCrypto -eq 1 -and
                $net2DefaultTLSVersions32 -eq 1 -and
                $net2StrongCrypto32 -eq 1 -and
                $net4DefaultTLSVersions32 -eq 1 -and
                $net4StrongCrypto32 -eq 1)
            {
                $currentTls12State = "Enabled"
            }

            if ($net2DefaultTLSVersions -eq 0 -and
                $net2StrongCrypto -eq 0 -and
                $net4DefaultTLSVersions -eq 0 -and
                $net4StrongCrypto -eq 0 -and
                $net2DefaultTLSVersions32 -eq 0 -and
                $net2StrongCrypto32 -eq 0 -and
                $net4DefaultTLSVersions32 -eq 0 -and
                $net4StrongCrypto32 -eq 0)
            {
                $currentTls12State = "Disabled"
            }
        }
        else
        {
            if ($null -eq $net2DefaultTLSVersions -and
                $null -eq $net2StrongCrypto -and
                $null -eq $net4DefaultTLSVersions -and
                $null -eq $net4StrongCrypto)
            {
                $currentTls12State = "Default"
            }

            if ($net2DefaultTLSVersions -eq 1 -and
                $net2StrongCrypto -eq 1 -and
                $net4DefaultTLSVersions -eq 1 -and
                $net4StrongCrypto -eq 1)
            {
                $currentTls12State = "Enabled"
            }

            if ($net2DefaultTLSVersions -eq 0 -and
                $net2StrongCrypto -eq 0 -and
                $net4DefaultTLSVersions -eq 0 -and
                $net4StrongCrypto -eq 0)
            {
                $currentTls12State = "Disabled"
            }
        }
    }
    else
    {
        Write-Verbose -Message ".Net Framework 4.6 or higher used, TLS 1.2 state not applicable"
    }

    # Diffie Hellman Minimum Key Size
    Write-Verbose -Message "Getting Diffie Hellman Key Size"

    $dhMinKeySizeKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\Diffie-Hellman'
    $dhMinClientKeySizeValue = Get-SChannelRegKeyValue -Key $dhMinKeySizeKey `
                                                       -Name 'ClientMinKeyBitLength'
    $dhMinServerKeySizeValue = Get-SChannelRegKeyValue -Key $dhMinKeySizeKey `
                                                       -Name 'ServerMinKeyBitLength'

    # FIPS Algorithm Policy
    Write-Verbose -Message "Getting FIPS Algorithm Policy"

    $fipsKey = 'HKLM:SYSTEM\CurrentControlSet\Control\LSA\FIPSAlgorithmPolicy'
    $fipsAlgorithmPolicyValue = Get-SChannelRegKeyValue -Key $fipsKey `
                                                        -Name 'Enabled'

    if ($null -eq $fipsAlgorithmPolicyValue)
    {
        $fipsValue = $false
    }
    else
    {
        switch ($fipsAlgorithmPolicyValue)
        {
            0
            {
                $fipsValue = $false
            }
            1
            {
                $fipsValue = $true
            }
        }
    }

    $returnValue = @{
        IsSingleInstance              = 'Yes'
        TLS12State                    = $currentTls12State
        DiffieHellmanMinClientKeySize = $dhMinClientKeySizeValue
        DiffieHellmanMinServerKeySize = $dhMinServerKeySizeValue
        EnableFIPSAlgorithmPolicy     = $fipsValue
    }

    return $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Yes")]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled', 'Default')]
        [System.String]
        $TLS12State,

        [Parameter()]
        [ValidateSet(1024, 2048, 3072, 4096)]
        [System.UInt32]
        $DiffieHellmanMinClientKeySize,

        [Parameter()]
        [ValidateSet(1024, 2048, 3072, 4096)]
        [System.UInt32]
        $DiffieHellmanMinServerKeySize,

        [Parameter()]
        [System.Boolean]
        $EnableFIPSAlgorithmPolicy
    )

    Write-Verbose -Message "Setting SChannel configuration settings"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    $dotnetKey = 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
    $keyExists = Get-ItemProperty -Path $dotnetKey -ErrorAction SilentlyContinue

    # Only check TLS12State if .Net Framework is 4.5 or lower
    # https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
    if ($null -eq $keyExists -or
        (Get-ItemPropertyValue -Path $dotnetKey -Name Release) -lt 390000)
    {
        if ($TLS12State -ne $CurrentValues.TLS12State)
        {
            Write-Verbose -Message "Configuring TLS v1.2 state"

            $dotnet64Key = 'HKLM:\SOFTWARE\Microsoft\.NETFramework'
            $dotnet32Key = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework'

            if ($TLS12State -eq 'Default')
            {
                # 64 bit keys
                # .Net Framework 2.0 - 3.5
                Set-SChannelRegKeyValue -Key $dotnet64Key `
                                        -SubKey 'v2.0.50727' `
                                        -Name 'SystemDefaultTlsVersions' `
                                        -Remove
                Set-SChannelRegKeyValue -Key $dotnet64Key `
                                        -SubKey 'v2.0.50727' `
                                        -Name 'SchUseStrongCrypto' `
                                        -Remove

                # .Net Framework 4.0 - 4.5
                Set-SChannelRegKeyValue -Key $dotnet64Key `
                                        -SubKey 'v4.0.30319' `
                                        -Name 'SystemDefaultTlsVersions' `
                                        -Remove
                Set-SChannelRegKeyValue -Key $dotnet64Key `
                                        -SubKey 'v4.0.30319' `
                                        -Name 'SchUseStrongCrypto' `
                                        -Remove

                if (Test-Path -Path 'HKLM:\SOFTWARE\Wow6432Node')
                {
                    # 32 bit keys
                    # .Net Framework 2.0 - 3.5
                    Set-SChannelRegKeyValue -Key $dotnet32Key `
                                            -SubKey 'v2.0.50727' `
                                            -Name 'SystemDefaultTlsVersions' `
                                            -Remove
                    Set-SChannelRegKeyValue -Key $dotnet32Key `
                                            -SubKey 'v2.0.50727' `
                                            -Name 'SchUseStrongCrypto' `
                                            -Remove

                    # .Net Framework 4.0 - 4.5
                    Set-SChannelRegKeyValue -Key $dotnet32Key `
                                            -SubKey 'v4.0.30319' `
                                            -Name 'SystemDefaultTlsVersions' `
                                            -Remove
                    Set-SChannelRegKeyValue -Key $dotnet32Key `
                                            -SubKey 'v4.0.30319' `
                                            -Name 'SchUseStrongCrypto' `
                                            -Remove
                }
            }
            else
            {
                if ($TLS12State -eq 'Enabled')
                {
                    $state = 1
                }
                else
                {
                    $state = 0
                }

                # 64 bit keys
                # .Net Framework 2.0 - 3.5
                Set-SChannelRegKeyValue -Key $dotnet64Key `
                                        -SubKey 'v2.0.50727' `
                                        -Name 'SystemDefaultTlsVersions' `
                                        -Value $state
                Set-SChannelRegKeyValue -Key $dotnet64Key `
                                        -SubKey 'v2.0.50727' `
                                        -Name 'SchUseStrongCrypto' `
                                        -Value $state

                # .Net Framework 4.0 - 4.5
                Set-SChannelRegKeyValue -Key $dotnet64Key `
                                        -SubKey 'v4.0.30319' `
                                        -Name 'SystemDefaultTlsVersions' `
                                        -Value $state
                Set-SChannelRegKeyValue -Key $dotnet64Key `
                                        -SubKey 'v4.0.30319' `
                                        -Name 'SchUseStrongCrypto' `
                                        -Value $state

                if (Test-Path -Path 'HKLM:\SOFTWARE\Wow6432Node')
                {
                    # 32 bit keys
                    # .Net Framework 2.0 - 3.5
                    Set-SChannelRegKeyValue -Key $dotnet32Key `
                                            -SubKey 'v2.0.50727' `
                                            -Name 'SystemDefaultTlsVersions' `
                                            -Value $state
                    Set-SChannelRegKeyValue -Key $dotnet32Key `
                                            -SubKey 'v2.0.50727' `
                                            -Name 'SchUseStrongCrypto' `
                                            -Value $state

                    # .Net Framework 4.0 - 4.5
                    Set-SChannelRegKeyValue -Key $dotnet32Key `
                                            -SubKey 'v4.0.30319' `
                                            -Name 'SystemDefaultTlsVersions' `
                                            -Value $state
                    Set-SChannelRegKeyValue -Key $dotnet32Key `
                                            -SubKey 'v4.0.30319' `
                                            -Name 'SchUseStrongCrypto' `
                                            -Value $state
                }
            }
        }
    }
    else
    {
        Write-Verbose -Message ('.NET Framework 4.6 or higher detected. Configuration of ' + `
                                'TLS v1.2 not necessary')
    }

    $keaKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms'
    if ($DiffieHellmanMinClientKeySize -ne 0 -and
        $DiffieHellmanMinClientKeySize -ne $CurrentValues.DiffieHellmanMinClientKeySize)
    {
        Write-Verbose -Message 'Configuring Diffie Hellman Min Client Key Size'
        Set-SChannelRegKeyValue -Key $keaKey `
                                -SubKey 'Diffie-Hellman' `
                                -Name 'ClientMinKeyBitLength' `
                                -Value $DiffieHellmanMinClientKeySize
    }

    if ($DiffieHellmanMinServerKeySize -ne 0 -and
        $DiffieHellmanMinServerKeySize -ne $CurrentValues.DiffieHellmanMinServerKeySize)
    {
        Write-Verbose -Message 'Configuring Diffie Hellman Min Server Key Size'
        Set-SChannelRegKeyValue -Key $keaKey `
                                -SubKey 'Diffie-Hellman' `
                                -Name 'ServerMinKeyBitLength' `
                                -Value $DiffieHellmanMinServerKeySize
    }

    if ($null -ne $EnableFIPSAlgorithmPolicy -and
        $EnableFIPSAlgorithmPolicy -ne $CurrentValues.EnableFIPSAlgorithmPolicy)
    {
        Write-Verbose -Message 'Configuring FIPS Algorithm Policy'
        $lsaKey = 'HKLM:SYSTEM\CurrentControlSet\Control\LSA'
        if ($EnableFIPSAlgorithmPolicy)
        {
            Set-SChannelRegKeyValue -Key $lsaKey `
                                    -SubKey 'FIPSAlgorithmPolicy' `
                                    -Name 'Enabled' `
                                    -Value 1
        }
        else
        {
            Set-SChannelRegKeyValue -Key $lsaKey `
                                    -SubKey 'FIPSAlgorithmPolicy' `
                                    -Name 'Enabled' `
                                    -Value 0
        }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Yes")]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled', 'Default')]
        [System.String]
        $TLS12State,

        [Parameter()]
        [ValidateSet(1024, 2048, 3072, 4096)]
        [System.UInt32]
        $DiffieHellmanMinClientKeySize,

        [Parameter()]
        [ValidateSet(1024, 2048, 3072, 4096)]
        [System.UInt32]
        $DiffieHellmanMinServerKeySize,

        [Parameter()]
        [System.Boolean]
        $EnableFIPSAlgorithmPolicy
    )

    Write-Verbose -Message "Testing SChannel configuration settings"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $compliant = $false

    Write-Verbose -Message "Current Values: $(Convert-SCDscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-SCDscHashtableToString -Hashtable $PSBoundParameters)"

    $ErrorActionPreference = 'SilentlyContinue'

    # Only check TLS12State if .Net Framework is 4.5 or lower
    # https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
    $dotnetKey = 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
    $keyExists = Get-ItemProperty -Path $dotnetKey -ErrorAction SilentlyContinue
    if ($null -eq $keyExists -or
        (Get-ItemPropertyValue -Path $dotnetKey -Name Release) -lt 390000)
    {
        $compliant = Test-SCDscParameterState -CurrentValues $CurrentValues `
                                              -DesiredValues $PSBoundParameters `
                                              -ValuesToCheck @('DiffieHellmanMinClientKeySize', `
                                                               'DiffieHellmanMinServerKeySize', `
                                                               'EnableFIPSAlgorithmPolicy', `
                                                               "TLS12State")
    }
    else
    {
        $compliant = Test-SCDscParameterState -CurrentValues $CurrentValues `
                                              -DesiredValues $PSBoundParameters `
                                              -ValuesToCheck @('DiffieHellmanMinClientKeySize', `
                                                               'DiffieHellmanMinServerKeySize', `
                                                               'EnableFIPSAlgorithmPolicy')
    }

    if ($compliant -eq $true)
    {
        Write-Verbose -Message ($LocalizedData.ItemCompliant -f 'SChannel settings')
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.ItemNotCompliant -f 'SChannel settings ')
    }
    return $compliant
}

Export-ModuleMember -Function *-TargetResource
