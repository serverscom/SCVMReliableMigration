function Test-SCVirtualMachineLiveMigrationEligibility {
    #Requires -Version 3.0
    #Requires -Modules virtualmachinemanager

    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    Param (
        [Parameter(Mandatory)]
        [Microsoft.SystemCenter.VirtualMachineManager.VM]$VM,
        [Parameter(Mandatory)]
        [Microsoft.SystemCenter.VirtualMachineManager.Host]$VMHost
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$VM: ''{0}''' -f $VM.Name)
        Write-Debug -Message ('$VMHost: ''{0}''' -f [string]$VMHost)

        $SCVMStatesPoweredDown = @(
            [Microsoft.VirtualManager.Utils.VMComputerSystemState]::Paused
            [Microsoft.VirtualManager.Utils.VMComputerSystemState]::PowerOff
            [Microsoft.VirtualManager.Utils.VMComputerSystemState]::Saved
        )
        Write-Debug -Message ('$SCVMStatesPoweredDown: {0}' -f [string]$SCVMStatesPoweredDown)

        $SCVMStatesRunning = @(
            [Microsoft.VirtualManager.Utils.VMComputerSystemState]::Running
        )
        Write-Debug -Message ('$SCVMStatesRunning: {0}' -f [string]$SCVMStatesRunning)

        $SCVMStatesMigrating = @(
            [Microsoft.VirtualManager.Utils.VMComputerSystemState]::UnderMigration
        )
        Write-Debug -Message ('$SCVMStatesMigrating: {0}' -f [string]$SCVMStatesMigrating)

        Write-Debug -Message '$Result = $false'
        $Result = $false
        Write-Debug -Message ('$Result: ''{0}''' -f [string]$Result)
        Write-Debug -Message '$Reason = ''OK'''
        $Reason = 'OK'
        Write-Debug -Message ('$Reason = ''{0}''' -f $Reason)

        Write-Debug -Message '$SourceVMHost = $VM.VMHost'
        $SourceVMHost = $VM.VMHost
        Write-Debug -Message ('$SourceVMHost: ''{0}''' -f [string]$SourceVMHost)
        Write-Debug -Message '$DestinationVMHost = $VMHost'
        $DestinationVMHost = $VMHost
        Write-Debug -Message ('$DestinationVMHost: ''{0}''' -f [string]$DestinationVMHost)

        Write-Debug -Message 'Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost)'
        Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost)

        $SourceVMs = Get-SCVirtualMachine -VMHost $SourceVMHost
        Write-Debug -Message ('$SourceVMs: ''{0}''' -f [string]$SourceVMs)
        $DestinationVMs = Get-SCVirtualMachine -VMHost $DestinationVMHost
        Write-Debug -Message ('$DestinationVMs: ''{0}''' -f [string]$DestinationVMs)

        Write-Debug -Message ('$VM.Status: ''{0}''' -f $VM.Status)
        Write-Debug -Message 'if ($VM -notin $SourceVMs)'
        if ($VM -notin $SourceVMs) {
            Write-Debug -Message '$Reason = ''NotFound'''
            $Reason = 'NotFound'
        }
        elseif ($VM -in $DestinationVMs) {
            Write-Debug -Message '$Reason = ''Migrated'''
            $Reason = 'Migrated'
        }
        elseif ($VM.Status -in $SCVMStatesMigrating) {
            Write-Debug -Message '$Reason = ''Migrating'''
            $Reason = 'Migrating'
        }
        elseif ($VM.Status -like '*Failed') {
            Write-Debug -Message '$Reason = ''Failed'''
            $Reason = 'Failed'
        }
        elseif ($VM.Status -notin $SCVMStatesRunning) {
            Write-Debug -Message '$Reason = ''NotRunning'''
            $Reason = 'NotRunning'
        }
        else {
            Write-Debug -Message '$SCVMIsBackingUp = Test-SCVirtualMachineBackingUpStatus -VM $VM'
            $SCVMIsBackingUp = Test-SCVirtualMachineBackingUpStatus -VM $VM
            Write-Debug -Message ('$SCVMIsBackingUp: ''{0}''' -f [string]$SCVMIsBackingUp)
            Write-Debug -Message 'if ($SCVMIsBackingUp)'
            if ($SCVMIsBackingUp) {
                Write-Debug -Message '$Reason = ''BackingUp'''
                $Reason = 'BackingUp'
            }
            else {
                Write-Debug -Message '$Result = $true'
                $Result = $true
            }
        }
        Write-Debug -Message ('$Reason = ''{0}''' -f $Reason)
        Write-Debug -Message ('$Result: ''{0}''' -f [string]$Result)

        Write-Debug -Message ('@{{Result = {0}; $Reason = ''{1}''; Status = ''{2}''}}' -f [string]$Result, $Reason, [string]$VM.Status)
        @{
            Result = $Result
            Reason = $Reason
            Status = $VM.Status
        }

        Write-Debug -Message ('EXIT TRY {0}' -f $MyInvocation.MyCommand.Name)
    }
    catch {
        Write-Debug -Message ('ENTER CATCH {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('{0}: $PSCmdlet.ThrowTerminatingError($_)' -f $MyInvocation.MyCommand.Name)
        $PSCmdlet.ThrowTerminatingError($_)

        Write-Debug -Message ('EXIT CATCH {0}' -f $MyInvocation.MyCommand.Name)
    }

    Write-Debug -Message ('EXIT {0}' -f $MyInvocation.MyCommand.Name)
}