<#
    .SYNOPSIS
        DSC Resource for managing SChannel Protocol server side settings.

    .DESCRIPTION
        This DSC Resource manages the enabled, disabled, and default protocols for
        the server side of SCHANNEL. It inherits from SChannelProtocolBase which has
        properties for managing the protocols and a property for rebooting when required.
        The compliance part (audit via Azure Policy) of Azure AutoManage Machine Configuration
        uses the properties of this resource to check if the server side SCHANNEL protocols
        are in the desired state.
#>

[DscResource()]
class SChannelProtocolServer : SChannelProtocolBase
{
    SChannelProtocolServer () : base ()
    {
        $this.ClientSide = $false
    }

    [SChannelProtocolServer] Get()
    {
        # Call the base method to return the properties.
        return ([ResourceBase] $this).Get()
    }

    [void] Set()
    {
        # Call the base method to enforce the properties.
        ([ResourceBase] $this).Set()
    }

    [System.Boolean] Test()
    {
        # Call the base method to test all of the properties that should be enforced.
        return ([ResourceBase] $this).Test()
    }
}
