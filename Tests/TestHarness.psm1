function Invoke-TestHarness
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $TestResultsFile,

        [Parameter()]
        [System.String]
        $DscTestsPath,

        [Parameter()]
        [Switch]
        $IgnoreCodeCoverage
    )

    Write-Verbose -Message 'Commencing all SChannelDsc tests'

    $repoDir = Join-Path -Path $PSScriptRoot -ChildPath '..\' -Resolve

    $testCoverageFiles = @()
    if ($IgnoreCodeCoverage.IsPresent -eq $false)
    {
        Get-ChildItem -Path "$repoDir\modules\SChannelDsc\DSCResources\**\*.psm1" -Recurse | ForEach-Object {
            if ($_.FullName -notlike '*\DSCResource.Tests\*')
            {
                $testCoverageFiles += $_.FullName
            }
        }
    }

    $testResultSettings = @{}
    if ([String]::IsNullOrEmpty($TestResultsFile) -eq $false)
    {
        $testResultSettings.Add('OutputFormat', 'NUnitXml' )
        $testResultSettings.Add('OutputFile', $TestResultsFile)
    }

    Import-Module -Name "$repoDir\modules\SChannelDsc\SChannelDsc.psd1"
    $testsToRun = @()

    # Run Unit Tests
    $testsToRun += @(@{
        'Path' = (Join-Path -Path $repoDir -ChildPath "\Tests\Unit")
    })

    # DSC Common Tests
    if ($PSBoundParameters.ContainsKey('DscTestsPath') -eq $true)
    {
        $getChildItemParameters = @{
            Path = $DscTestsPath
            Recurse = $true
            Filter = '*.Tests.ps1'
        }

        # Get all tests '*.Tests.ps1'.
        $commonTestFiles = Get-ChildItem @getChildItemParameters

        # Remove DscResource.Tests unit and integration tests.
        $commonTestFiles = $commonTestFiles | Where-Object -FilterScript {
            $_.FullName -notmatch 'DSCResource.Tests\\Tests'
        }

        $testsToRun += @( $commonTestFiles.FullName )
    }

    if ($IgnoreCodeCoverage.IsPresent -eq $false)
    {
        $testResultSettings.Add('CodeCoverage', $testCoverageFiles)
    }

    $results = Invoke-Pester -Script $testsToRun -PassThru @testResultSettings

    return $results
}
