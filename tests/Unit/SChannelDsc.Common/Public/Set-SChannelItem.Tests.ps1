<#
    .SYNOPSIS
        Unit test for helper functions in module SChannelDsc.Common.
#>

# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Suppressing this rule because Script Analyzer does not understand Pester syntax.')]
param ()

BeforeDiscovery {
    try
    {
        if (-not (Get-Module -Name 'DscResource.Test'))
        {
            # Assumes dependencies have been resolved, so if this module is not available, run 'noop' task.
            if (-not (Get-Module -Name 'DscResource.Test' -ListAvailable))
            {
                # Redirect all streams to $null, except the error stream (stream 2)
                & "$PSScriptRoot/../../../../build.ps1" -Tasks 'noop' 3>&1 4>&1 5>&1 6>&1 > $null
            }

            # If the dependencies have not been resolved, this will throw an error.
            Import-Module -Name 'DscResource.Test' -Force -ErrorAction 'Stop'
        }
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks noop" first.'
    }
}

BeforeAll {
    $script:moduleName = 'SChannelDsc'
    $script:subModuleName = 'SChannelDsc.Common'

    $script:parentModule = Get-Module -Name $script:moduleName -ListAvailable | Select-Object -First 1
    $script:subModulesFolder = Join-Path -Path $script:parentModule.ModuleBase -ChildPath 'Modules'

    $script:subModulePath = Join-Path -Path $script:subModulesFolder -ChildPath $script:subModuleName

    Import-Module -Name $script:subModulePath -ErrorAction 'Stop'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:subModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:subModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:subModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:subModuleName -All | Remove-Module -Force
}

Describe 'SChannelDsc.Common\Set-SChannelItem' {
    Context 'When the state should be Default' {
        BeforeAll {
            $null = New-Item -Path 'TestRegistry:\SCHANNEL\Protocols\SSL 3.0' -Force
            $null = New-ItemProperty -Path 'TestRegistry:\SCHANNEL\Protocols\SSL 3.0' -Name 'Enabled' -Value 1 -Force
        }

        It 'Should remove the key' {
            $mockParams = @{
                ItemKey    = 'TestRegistry:\SCHANNEL\Protocols'
                ItemSubKey = 'SSL 3.0'
                State      = 'Default'
            }

            $null = Set-SChannelItem @mockParams

            (Get-Item -Path 'TestRegistry:\SCHANNEL\Protocols\SSL 3.0' -ErrorAction SilentlyContinue) | Should -BeNullOrEmpty
        }
    }

    Context 'When the state should be Enabled' {

        BeforeAll {
            $null = New-Item -Path 'TestRegistry:\SCHANNEL\Protocols\SSL 3.0' -Force
            $null = New-ItemProperty -Path 'TestRegistry:\SCHANNEL\Protocols\SSL 3.0' -Name 'Enabled' -Value 1 -Force
        }

        It 'Should remove the key' {
            $mockParams = @{
                ItemKey    = 'TestRegistry:\SCHANNEL\Protocols'
                ItemSubKey = 'SSL 3.0'
                State      = 'Enabled'
            }

            $null = Set-SChannelItem @mockParams

            (Get-ItemPropertyValue -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled') | Should -Be 1
        }
    }

    Context 'When the state should be Disabled' {

        BeforeAll {
            $null = New-Item -Path 'TestRegistry:\SCHANNEL\Protocols\SSL 3.0' -Force
            $null = New-ItemProperty -Path 'TestRegistry:\SCHANNEL\Protocols\SSL 3.0' -Name 'Enabled' -Value 1 -Force
        }

        It 'Should remove the key' {
            $mockParams = @{
                ItemKey    = 'TestRegistry:\SCHANNEL\Protocols'
                ItemSubKey = 'SSL 3.0'
                State      = 'Disabled'
            }

            $null = Set-SChannelItem @mockParams

            (Get-ItemPropertyValue -Path 'TestRegistry:\SChannel\Protocols\SSL 3.0' -Name 'Enabled') | Should -Be 0
        }
    }
}
