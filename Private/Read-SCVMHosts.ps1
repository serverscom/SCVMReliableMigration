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
                    Write-Debug -Message 'if ($_.Exception.HResult -eq 2606)'
                    if ($_.Exception.HResult -eq 2606) {
                        Write-Debug -Message ('$Count: ''{0}''' -f $Count)
                        Write-Debug -Message ('$MaxAttempts: ''{0}''' -f $MaxAttempts)
                        Write-Debug -Message 'if ($Count -ge $MaxAttempts)'
                        if ($Count -ge $MaxAttempts) {
                            $Message = ('Could not refresh SCVMM Host ''{0}'' after ''{1}'' retries.' -f $SCVMHost, $MaxAttempts)
                            $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.ApplicationException' -ArgumentList ($Message, $_)), 'HostLocked', [System.Management.Automation.ErrorCategory]::InvalidResult, $null)))
                        }
                        Write-Debug -Message ('Start-Sleep -Seconds {0}' -f $Timeout)
                        Start-Sleep -Seconds $Timeout
                    }
                    else {
                        Write-Debug -Message ('{0}: $PSCmdlet.ThrowTerminatingError($_)' -f $MyInvocation.MyCommand.Name)
                        $PSCmdlet.ThrowTerminatingError($_)
                    }
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