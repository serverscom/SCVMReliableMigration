function Test-SCVirtualMachineBackingUpStatus {
    #Requires -Version 3.0
    #Requires -Modules virtualmachinemanager

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    Param (
        [Parameter(Mandatory)]
        [Microsoft.SystemCenter.VirtualMachineManager.VM]$VM
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$VM: ''{0}''' -f $VM.Name)

        Write-Debug -Message '$VMHost = $VM.VMHost'
        $VMHost = $VM.VMHost
        Write-Debug -Message ('$VMHost: ''{0}''' -f [string]$VMHost)

        Write-Debug -Message ('$HVVM = Invoke-Command -ComputerName ''{0}'' -ScriptBlock {{Get-VM -Id ''{1}'')}}' -f $VMHost.Name, $VM.VMId)
        $HVVM = Invoke-Command -ComputerName $VMHost.Name -ScriptBlock {Get-VM -Id $using:VM.VMid}
        Write-Debug -Message ('$HVVM: ''{0}''' -f [string]$HVVM)

        Write-Debug -Message ('$HVVM.PrimaryOperationalStatus: ''{0}''' -f $HVVM.PrimaryOperationalStatus)
        Write-Debug -Message ('$HVVM.SecondaryOperationalStatus: ''{0}''' -f $HVVM.SecondaryOperationalStatus)
        Write-Debug -Message 'if ($HVVM.PrimaryOperationalStatus -eq ''InService'' -and $HVVM.SecondaryOperationalStatus -eq ''BackingUpVirtualMachine'')'
        if ($HVVM.PrimaryOperationalStatus -eq 'InService' -and $HVVM.SecondaryOperationalStatus -eq 'BackingUpVirtualMachine') {
            Write-Debug -Message '$true'
            $true
        }
        else {
            Write-Debug -Message '$false'
            $false
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