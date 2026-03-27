$configFile = [System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Path, 'json')
if (Test-Path -Path $configFile)
{
    <#
        Allows reading the configuration data from a JSON file,
        for real testing scenarios outside of the CI.
    #>
    $ConfigurationData = Get-Content -Path $configFile | ConvertFrom-Json
}
else
{
    $ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName           = 'localhost'
                ProtocolsEnabled   = @(
                    'Tls12'
                    'Tls13'
                )
                ProtocolsDisabled  = 'Tls11'
                ProtocolsDefault   = 'Tls11', 'Tls13'
                RebootWhenRequired = $false
            }
        )
    }
}

Configuration DSC_SChannelProtocolServer_EnableTls12And13
{
    Import-DscResource -ModuleName SChannelDsc

    node $AllNodes.NodeName
    {
        SChannelProtocolServer 'Integration_Test'
        {
            IsSingleInstance   = 'Yes'
            ProtocolsEnabled   = $Node.ProtocolsEnabled
            RebootWhenRequired = $Node.RebootWhenRequired
        }
    }
}

Configuration DSC_SChannelProtocolServer_DisableTls11
{
    Import-DscResource -ModuleName SChannelDsc

    node $AllNodes.NodeName
    {
        SChannelProtocolServer 'Integration_Test'
        {
            IsSingleInstance   = 'Yes'
            ProtocolsDisabled  = $Node.ProtocolsDisabled
            RebootWhenRequired = $Node.RebootWhenRequired
        }
    }
}

Configuration DSC_SChannelProtocolServer_ResetToDefault
{
    Import-DscResource -ModuleName SChannelDsc

    node $AllNodes.NodeName
    {
        SChannelProtocolServer 'Integration_Test'
        {
            IsSingleInstance   = 'Yes'
            ProtocolsDefault   = $Node.ProtocolsDefault
            RebootWhenRequired = $Node.RebootWhenRequired
        }
    }
}
