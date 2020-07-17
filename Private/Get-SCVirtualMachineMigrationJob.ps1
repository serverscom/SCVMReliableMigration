function Get-SCVirtualMachineMigrationJob {
    #Requires -Version 3.0
    #Requires -Modules virtualmachinemanager

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [Microsoft.SystemCenter.VirtualMachineManager.VM]$VM
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$VM: ''{0}''' -f $VM.Name)

        Write-Debug -Message ('$SourceVMHost.ServerConnection: ''{0}''' -f [string]$VM.ServerConnection.FullyQualifiedDomainName)
        Write-Debug -Message '$SCRunningJobs = Get-SCJob -VMMServer $VM.ServerConnection -Running'
        $SCRunningJobs = Get-SCJob -VMMServer $VM.ServerConnection -Running
        Write-Debug -Message ('$SCRunningJobs: ''{0}''' -f [string]$SCRunningJobs)
        # We use a separate filtering command, because it does not work in a single command: somehow the '-Running' parameter prevents subsequent filters from working correctly
        Write-Debug -Message ('$MigrationJobs = $SCRunningJobs | Where-Object -FilterScript {{$_.ResultName -eq ''{0}''}}' -f $VM.Name)
        $MigrationJobs = $SCRunningJobs | Where-Object -FilterScript {$_.ResultName -eq $VM.Name}
        Write-Debug -Message ('$MigrationJobs: ''{0}''' -f [string]$MigrationJobs)

        Write-Debug -Message '$MigrationJobs'
        $MigrationJobs

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