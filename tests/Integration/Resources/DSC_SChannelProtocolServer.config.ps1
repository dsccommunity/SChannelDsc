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
            ProtocolsEnabled   = @(
                'Tls12'
                'Tls13'
            )
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
            ProtocolsDisabled  = 'Tls11'
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
            ProtocolsDefault   = 'Tls11', 'Tls13'
            RebootWhenRequired = $Node.RebootWhenRequired
        }
    }
}
