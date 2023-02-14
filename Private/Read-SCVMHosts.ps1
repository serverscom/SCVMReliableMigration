function Read-SCVMHosts {
    #Requires -Version 3.0
    #Requires -Modules virtualmachinemanager

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [Microsoft.SystemCenter.VirtualMachineManager.Host[]]$VMHost,
        [int]$MaxAttempts = $ModuleWideHostRefreshMaxAttempts,
        [int]$Timeout = $ModuleWideHostRefreshTimeout
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)
    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$VMHost: ''{0}''' -f [string]$VMHost)
        Write-Debug -Message ('$MaxAttempts = {0}' -f $MaxAttempts)
        Write-Debug -Message ('$Timeout = {0}' -f $Timeout)

        Write-Debug -Message 'foreach ($SCVMHost in $VMHost)'
        foreach ($SCVMHost in $VMHost) {
            Write-Debug -Message ('$SCVMHost: ''{0}''' -f [string]$SCVMHost)
            for ($Count = 0; $Count -le $MaxAttempts; $Count++) {
                Write-Debug -Message ('$Count = {0}' -f $Count)
                try {
                    Write-Debug -Message '$ReadSCVMHost = $null'
                    $ReadSCVMHost = $null
                    Write-Debug -Message '$ReadSCVMHost = Read-SCVMHost -VMHost $SCVMHost'
                    $ReadSCVMHost = Read-SCVMHost -VMHost $SCVMHost
                    Write-Debug -Message ('$ReadSCVMHost: ''{0}''' -f [string]$ReadSCVMHost)
                    Write-Debug -Message 'if ($ReadSCVMHost)'
                    if ($ReadSCVMHost) {
                        Write-Debug -Message 'break'
                        break
                    }
                }
                catch {
                    Write-Debug -Message ('$_.Exception.HResult: {0}' -f $_.Exception.HResult)
                    Write-Debug -Message ('$_.Exception.Message: {0}' -f $_.Exception.Message)
                    Write-Debug -Message ('$_.InvocationInfo.PositionMessage: {0}' -f $_.InvocationInfo.PositionMessage)
                    Write-Debug -Message ('$_.ScriptStackTrace: {0}' -f $_.ScriptStackTrace)
                    Write-Debug -Message ('$_.Exception.ScriptStackTrace: {0}' -f $_.Exception.ScriptStackTrace)
                    Write-Debug -Message ('$_.TargetObject: {0}' -f $_.TargetObject)
                    Write-Debug -Message ('$_.FullyQualifiedErrorId: {0}' -f $_.FullyQualifiedErrorId)
                    Write-Debug -Message ('$_.CategoryInfo.Category: {0}' -f $_.CategoryInfo.Category)
                    Write-Debug -Message ('$_.CategoryInfo.Activity: {0}' -f $_.CategoryInfo.Activity)
                    Write-Debug -Message ('$_.CategoryInfo.Reason: {0}' -f $_.CategoryInfo.Reason)
                    Write-Debug -Message ('$_.CategoryInfo.TargetName: {0}' -f $_.CategoryInfo.TargetName)
                    Write-Debug -Message ('$_.CategoryInfo.TargetType: {0}' -f $_.CategoryInfo.TargetType)

                    Write-Debug -Message ('$Count = {0}' -f $Count)
                    Write-Debug -Message ('$MaxAttempts = {0}' -f $MaxAttempts)
                    Write-Debug -Message 'if ($Count -ge $MaxAttempts)'
                    if ($Count -ge $MaxAttempts) {
                        Write-Debug -Message ('{0}: $PSCmdlet.ThrowTerminatingError($_)' -f $MyInvocation.MyCommand.Name)
                        $PSCmdlet.ThrowTerminatingError($_)
                        }

                    Write-Debug -Message ('Start-Sleep -Seconds {0}' -f $Timeout)
                    Start-Sleep -Seconds $Timeout
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