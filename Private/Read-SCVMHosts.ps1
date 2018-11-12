function Read-SCVMHosts {
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

        foreach ($SCVMHost in $VMHost) {
            Write-Debug -Message ('$SCVMHost: ''{0}''' -f [string]$SCVMHost)

            Write-Debug -Message '$null = Read-SCVMHost -VMHost $SCVMHost'
            $null = Read-SCVMHost -VMHost $SCVMHost
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