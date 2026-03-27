[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Suppressing this rule because Script Analyzer does not understand Pester syntax.')]
param ()

BeforeDiscovery {
    try
    {
        if (-not (Get-Module -Name 'DscResource.Test'))
        {
            # Assumes dependencies has been resolved, so if this module is not available, run 'noop' task.
            if (-not (Get-Module -Name 'DscResource.Test' -ListAvailable))
            {
                # Redirect all streams to $null, except the error stream (stream 2)
                & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 3>&1 4>&1 5>&1 6>&1 > $null
            }

            # If the dependencies has not been resolved, this will throw an error.
            Import-Module -Name 'DscResource.Test' -Force -ErrorAction 'Stop'
        }
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks build" first.'
    }
}

BeforeAll {
    $script:dscModuleName = 'SChannelDsc'

    Import-Module -Name $script:dscModuleName -ErrorAction 'Stop'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe 'SChannelReason' -Tag 'SChannelReason' {
    Context 'When instantiating the class' {
        It 'Should not throw an error' {
            $script:mockSChannelReasonInstance = InModuleScope -ScriptBlock {
                [SChannelReason]::new()
            }
        }

        It 'Should be of the correct type' {
            $mockSChannelReasonInstance | Should -Not -BeNullOrEmpty
            $mockSChannelReasonInstance.GetType().Name | Should -Be 'SChannelReason'
        }
    }

    Context 'When setting and reading values' {
        It 'Should be able to set value in instance' {
            $script:mockSChannelReasonInstance = InModuleScope -ScriptBlock {
                $SChannelReasonInstance = [SChannelReason]::new()

                $SChannelReasonInstance.Code = 'SChannelReason:SChannelReason:Ensure'
                $SChannelReasonInstance.Phrase = 'The property Ensure should be "Present", but was "Absent"'

                return $SChannelReasonInstance
            }
        }

        It 'Should be able read the values from instance' {
            $mockSChannelReasonInstance.Code | Should -Be 'SChannelReason:SChannelReason:Ensure'
            $mockSChannelReasonInstance.Phrase | Should -Be 'The property Ensure should be "Present", but was "Absent"'
        }
    }
}
