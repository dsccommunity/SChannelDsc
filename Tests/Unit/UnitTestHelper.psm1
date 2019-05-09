function New-SCDscUnitTestHelper
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'DscResource')]
        [String]
        $DscResource,

        [Parameter(Mandatory = $true, ParameterSetName = 'SubModule')]
        [String]
        $SubModulePath,

        [Parameter()]
        [Switch]
        $ExcludeInvokeHelper,

        [Parameter()]
        [Switch]
        $IncludeDistributedCacheStubs
    )

    $repoRoot = Join-Path -Path $PSScriptRoot -ChildPath "..\..\" -Resolve
    $moduleRoot = Join-Path -Path $repoRoot -ChildPath "Modules\SChannelDsc"

    $mainModule = Join-Path -Path $moduleRoot -ChildPath "SChannelDsc.psd1"
    Import-Module -Name $mainModule -Global

    if ($PSBoundParameters.ContainsKey("SubModulePath") -eq $true)
    {
        $describeHeader = "Sub-module '$SubModulePath'"
        $moduleToLoad = Join-Path -Path $moduleRoot -ChildPath $SubModulePath
        $moduleName = (Get-Item -Path $moduleToLoad).BaseName
    }

    if ($PSBoundParameters.ContainsKey("DscResource") -eq $true)
    {
        $describeHeader = "DSC Resource '$DscResource'"
        $moduleName = "MSFT_$DscResource"
        $modulePath = "DSCResources\MSFT_$DscResource\MSFT_$DscResource.psm1"
        $moduleToLoad = Join-Path -Path $moduleRoot -ChildPath $modulePath
    }

    Import-Module -Name $moduleToLoad -Global

    $initScript = @"
            Set-StrictMode -Version 1
            Import-Module -Name "$moduleToLoad"
"@

    if ($ExcludeInvokeHelper -eq $false)
    {
        $initScript += @"
            # Additional Mocks
            #Mock Invoke-Command {
            #}
"@
    }

    return @{
        DescribeHeader         = $describeHeader
        ModuleName             = $moduleName
        InitializeScript       = [ScriptBlock]::Create($initScript)
        RepoRoot               = $repoRoot
        CleanupScript          = [ScriptBlock]::Create(@"

            Get-Variable -Scope Global -Name "SCDsc*" | Remove-Variable -Force -Scope "Global"
            `$global:DSCMachineStatus = 0

"@)
    }
}
