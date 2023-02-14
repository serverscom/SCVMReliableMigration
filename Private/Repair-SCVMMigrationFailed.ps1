function Repair-SCVMMigrationFailed {
    #Requires -Version 3.0
    #Requires -Modules virtualmachinemanager

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [Microsoft.SystemCenter.VirtualMachineManager.Host[]]$VMHost
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$VMHost: ''{0}''' -f [string]$VMHost)

        Write-Debug -Message 'foreach ($SCVMHost in $VMHost)'
        foreach ($SCVMHost in $VMHost) {
            Write-Debug -Message ('$SCVMHost: ''{0}''' -f [string]$SCVMHost)

            Write-Debug -Message '$SCVMMigrationFailedList = Get-SCVirtualMachine -VMHost $SCVMHost | Where-Object -FilterScript {$_.Status -eq [Microsoft.VirtualManager.Utils.VMComputerSystemState]::MigrationFailed}'
            $SCVMMigrationFailedList = Get-SCVirtualMachine -VMHost $SCVMHost | Where-Object -FilterScript {$_.Status -eq [Microsoft.VirtualManager.Utils.VMComputerSystemState]::MigrationFailed}
            Write-Debug -Message ('$SCVMMigrationFailedList: ''{0}''' -f $SCVMMigrationFailedList.Name)

            Write-Debug -Message 'if ($SCVMMigrationFailedList)'
            if ($SCVMMigrationFailedList) {

                Write-Debug -Message 'foreach ($SCVM in $SCVMMigrationFailedList)'
                foreach ($SCVM in $SCVMMigrationFailedList) {
                    Write-Debug -Message ('$SCVM: ''{0}''' -f $SCVM.Name)

                    Write-Debug -Message '$SCVM = Repair-SCVirtualMachine -VM $SCVM -Dismiss -Force'
                    $SCVM = Repair-SCVirtualMachine -VM $SCVM -Dismiss -Force

                    Write-Debug -Message '$null = Read-SCVirtualMachine -VM $SCVM'
                    $null = Read-SCVirtualMachine -VM $SCVM
                }
            }
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