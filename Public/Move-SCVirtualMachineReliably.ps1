function Move-SCVirtualMachineReliably {
    #Requires -Version 3.0
    #Requires -Modules virtualmachinemanager

    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName = 'ByHost', Mandatory)]
        [Microsoft.SystemCenter.VirtualMachineManager.Host]$SourceVMHost,
        [Parameter(ParameterSetName = 'ByVM', Mandatory)]
        [Microsoft.SystemCenter.VirtualMachineManager.VM[]]$VM,
        [Parameter(ParameterSetName = 'ByHost', Mandatory)]
        [Parameter(ParameterSetName = 'ByVM', Mandatory)]
        [Microsoft.SystemCenter.VirtualMachineManager.Host]$DestinationVMHost,
        [Parameter(ParameterSetName = 'ByHost', Mandatory)]
        [Parameter(ParameterSetName = 'ByVM', Mandatory)]
        [string]$Path,
        [Parameter(ParameterSetName = 'ByHost')]
        [Parameter(ParameterSetName = 'ByVM')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Timeout = $ModuleWideMigrationTimeout,
        [Parameter(ParameterSetName = 'ByHost')]
        [Parameter(ParameterSetName = 'ByVM')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$MaxAttempts = $ModuleWideMigrationMaxAttempts,
        [Parameter(ParameterSetName = 'ByHost')]
        [Parameter(ParameterSetName = 'ByVM')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$MaxParallelMigrations,
        [Parameter(ParameterSetName = 'ByHost')]
        [Parameter(ParameterSetName = 'ByVM')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$MigrationJobGetTimeout = $ModuleWideMigrationJobGetTimeout,
        [Parameter(ParameterSetName = 'ByHost')]
        [Parameter(ParameterSetName = 'ByVM')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$MigrationJobGetMaxAttempts = $ModuleWideMigrationJobGetMaxAttempts,
        [Parameter(ParameterSetName = 'ByHost')]
        [Parameter(ParameterSetName = 'ByVM')]
        [System.TimeSpan]$BackupThreshold = $ModuleWideBackupThreshold,
        [Parameter(ParameterSetName = 'ByHost')]
        [Parameter(ParameterSetName = 'ByVM')]
        [switch]$Bulletproof,
        [Parameter(ParameterSetName = 'ByHost')]
        [Parameter(ParameterSetName = 'ByVM')]
        [switch]$CrashOnUnmigratable
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$SourceVMHost: ''{0}''' -f [string]$SourceVMHost)
        Write-Debug -Message ('$DestinationVMHost: ''{0}''' -f [string]$DestinationVMHost)
        Write-Debug -Message ('$Path = ''{0}''' -f $Path)
        Write-Debug -Message ('$Timeout = {0}' -f $Timeout)
        Write-Debug -Message ('$MaxAttempts = {0}' -f $MaxAttempts)
        Write-Debug -Message ('$MaxParallelMigrations = {0}' -f $MaxParallelMigrations)
        Write-Debug -Message ('$MigrationJobGetTimeout = {0}' -f $MigrationJobGetTimeout)
        Write-Debug -Message ('$MigrationJobGetMaxAttempts = {0}' -f $MigrationJobGetMaxAttempts)
        Write-Debug -Message ('$VM: ''{0}''' -f [string]$VM.Name)
        Write-Debug -Message ('$BackupThreshold: ''{0}''' -f [string]$BackupThreshold)
        Write-Debug -Message ('$Bulletproof: ''{0}''' -f [string]$Bulletproof)
        Write-Debug -Message ('$CrashOnUnmigratable: ''{0}''' -f [string]$CrashOnUnmigratable)

        Write-Debug -Message 'if ($VM)'
        if ($VM) {
            Write-Debug -Message '$UniqueVMHosts = $VM.VMHost | Select-Object -Unique'
            $UniqueVMHosts = $VM.VMHost | Select-Object -Unique
            Write-Debug -Message ('$UniqueVMHosts: ''{0}''' -f [string]$UniqueVMHosts)
            Write-Debug -Message ('$UniqueVMHosts.Count: {0}' -f $UniqueVMHosts.Count)
            Write-Debug -Message 'if ($UniqueVMHosts.Count -eq 1)'
            if ($UniqueVMHosts.Count -eq 1) {
                # Right now the function supports moving VMs between two SCVMHosts only
                Write-Debug -Message '$SourceVMHost = $UniqueVMHosts'
                $SourceVMHost = $UniqueVMHosts
                Write-Debug -Message ('$SourceVMHost: ''{0}''' -f [string]$SourceVMHost)
            }
            elseif ($UniqueVMHosts.Count -lt 1) {
                $Message = ('Somehow there are no unique VMHosts: {0}' -f [string]$UniqueVMHosts.Name)
                $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.Management.Automation.PSNotSupportedException' -ArgumentList $Message), 'PSNotSupportedException', [System.Management.Automation.ErrorCategory]::InvalidData, $UniqueVMHosts)))
            }
            else {
                $Message = ('Input VMs are from several VMHosts: {0}' -f [string]$UniqueVMHosts.Name)
                $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.Management.Automation.PSNotSupportedException' -ArgumentList $Message), 'PSNotSupportedException', [System.Management.Automation.ErrorCategory]::InvalidData, $UniqueVMHosts)))
            }
        }

        Write-Debug -Message 'if ($SourceVMHost -ne $DestinationVMHost)'
        if ($SourceVMHost -ne $DestinationVMHost) {
            Write-Debug -Message ('$SourceVMHost.ServerConnection.ManagedComputer.Name: ''{0}''' -f [string]$SourceVMHost.ServerConnection.ManagedComputer.Name)
            Write-Debug -Message ('$SourceVMHost.ServerConnection.ManagedComputer.ID: ''{0}''' -f [string]$SourceVMHost.ServerConnection.ManagedComputer.ID)
            Write-Debug -Message ('$DestinationVMHost.ServerConnection.ManagedComputer.Name: ''{0}''' -f [string]$DestinationVMHost.ServerConnection.ManagedComputer.Name)
            Write-Debug -Message ('$DestinationVMHost.ServerConnection.ManagedComputer.ID: ''{0}''' -f [string]$DestinationVMHost.ServerConnection.ManagedComputer.ID)
            Write-Debug -Message 'if ($SourceVMHost.ServerConnection.ManagedComputer.ID -eq $DestinationVMHost.ServerConnection.ManagedComputer.ID)'
            if ($SourceVMHost.ServerConnection.ManagedComputer.ID -eq $DestinationVMHost.ServerConnection.ManagedComputer.ID) {
                Write-Debug -Message 'if (-not $VM)'
                if (-not $VM) {
                    Write-Debug -Message '$VM = Get-SCVirtualMachine -VMHost $SourceVMHost'
                    $VM = Get-SCVirtualMachine -VMHost $SourceVMHost
                }
                Write-Debug -Message ('$VM: ''{0}''' -f [string]$VM.Name)

                Write-Debug -Message 'if ($VM)'
                if ($VM) {
                    $SCVMStatesRunning = @(
                        [Microsoft.VirtualManager.Utils.VMComputerSystemState]::Running
                    )
                    Write-Debug -Message ('$SCVMStatesRunning: ''{0}''' -f [string]$SCVMStatesRunning)

                    $SCVMStatesMigrating = @(
                        [Microsoft.VirtualManager.Utils.VMComputerSystemState]::UnderMigration
                    )
                    Write-Debug -Message ('$SCVMStatesMigrating: ''{0}''' -f [string]$SCVMStatesMigrating)

                    Write-Debug -Message '[System.Collections.ArrayList]$UnmigratableVMs = @()'
                    [System.Collections.ArrayList]$UnmigratableVMs = @()
                    Write-Debug -Message '[System.Collections.ArrayList]$BackingUpVMs = @()'
                    [System.Collections.ArrayList]$BackingUpVMs = @()
                    Write-Debug -Message '[System.Collections.ArrayList]$VMMigrationRetryInfo = @()'
                    [System.Collections.ArrayList]$VMMigrationRetryInfo = @()

                    Write-Debug -Message '$SourceVMHostLiveMigrationMaximum = $SourceVMHost.LiveMigrationMaximum'
                    $SourceVMHostLiveMigrationMaximum = $SourceVMHost.LiveMigrationMaximum
                    Write-Debug -Message ('$SourceVMHostLiveMigrationMaximum = {0}' -f $SourceVMHostLiveMigrationMaximum)

                    Write-Debug -Message '$DestinationVMHostLiveMigrationMaximum = $DestinationVMHost.LiveMigrationMaximum'
                    $DestinationVMHostLiveMigrationMaximum = $DestinationVMHost.LiveMigrationMaximum
                    Write-Debug -Message ('$DestinationVMHostLiveMigrationMaximum = {0}' -f $DestinationVMHostLiveMigrationMaximum)
                    Write-Debug -Message ('$LiveMigrationMaximum = (({0}, {1}) | Measure-Object -Minimum).Minimum' -f $SourceVMHostLiveMigrationMaximum, $DestinationVMHostLiveMigrationMaximum)
                    $LiveMigrationMaximum = (($SourceVMHostLiveMigrationMaximum, $DestinationVMHostLiveMigrationMaximum) | Measure-Object -Minimum).Minimum
                    Write-Debug -Message ('$LiveMigrationMaximum = {0}' -f $LiveMigrationMaximum)

                    Write-Debug -Message ('$MaxParallelMigrations = {0}' -f $MaxParallelMigrations)
                    Write-Debug -Message 'if ($MaxParallelMigrations)'
                    if ($MaxParallelMigrations) {
                        Write-Debug -Message ('$LiveMigrationMaximum = (({0}, {1}) | Measure-Object -Minimum).Minimum' -f $LiveMigrationMaximum, $MaxParallelMigrations)
                        $LiveMigrationMaximum = (($LiveMigrationMaximum, $MaxParallelMigrations) | Measure-Object -Minimum).Minimum
                    }
                    Write-Debug -Message ('$LiveMigrationMaximum = {0}' -f $LiveMigrationMaximum)

                    do {
                        Write-Debug -Message ('$PsCmdlet.ParameterSetName: ''{0}''' -f $PsCmdlet.ParameterSetName)
                        switch ($PsCmdlet.ParameterSetName) {
                            'ByHost' {
                                $Filter = {$_ -notin $UnmigratableVMs}
                            }
                            'ByVM' {
                                $Filter = {$_ -in $VM -and $_ -notin $UnmigratableVMs}
                            }
                        }
                        Write-Debug -Message ('$Filter = ''{0}''' -f $Filter)

                        Write-Debug -Message 'Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost)'
                        Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost)
                        
                        $SourceSCVMs = Get-SCVirtualMachine -VMHost $SourceVMHost | Where-Object -FilterScript $Filter # Getting those VMs of which we care about
                        Write-Debug -Message ('$SourceSCVMs: ''{0}''' -f [string]$SourceSCVMs.Name)
                        Write-Debug -Message 'if ($SourceSCVMs)'
                        if ($SourceSCVMs) {
                            Write-Debug -Message '$SourceSCVMsMigrating = $SourceSCVMs | Where-Object -FilterScript {$_.Status -in $SCVMStatesMigrating}'
                            $SourceSCVMsMigrating = $SourceSCVMs | Where-Object -FilterScript {$_.Status -in $SCVMStatesMigrating}
                            Write-Debug -Message ('$SourceSCVMsMigrating: ''{0}''' -f [string]$SourceSCVMsMigrating.Name)
                            Write-Debug -Message '$SourceSCVMsNotMigrating = $SourceSCVMs | Where-Object -FilterScript {$_ -notin $SourceSCVMsMigrating}'
                            $SourceSCVMsNotMigrating = $SourceSCVMs | Where-Object -FilterScript {$_ -notin $SourceSCVMsMigrating}
                            Write-Debug -Message ('$SourceSCVMsNotMigrating: ''{0}''' -f [string]$SourceSCVMsNotMigrating.Name)
                            Write-Debug -Message '$SourceSCVMsNotMigratingRunning = $SourceSCVMsNotMigrating | Where-Object -FilterScript {$_.Status -in $SCVMStatesRunning}'
                            $SourceSCVMsNotMigratingRunning = $SourceSCVMsNotMigrating | Where-Object -FilterScript {$_.Status -in $SCVMStatesRunning}
                            Write-Debug -Message ('$SourceSCVMsNotMigratingRunning: ''{0}''' -f [string]$SourceSCVMsNotMigratingRunning.Name)
                            Write-Verbose -Message ('VMs left to migrate: {0}' -f [string]$SourceSCVMs.Name)

                            if ($SourceSCVMsNotMigratingRunning) {
                                Write-Debug -Message '$SourceVMsToMigrate = $SourceSCVMsNotMigratingRunning'
                                $SourceVMsToMigrate = $SourceSCVMsNotMigratingRunning # We TRY to migrate VMs which have just been running
                            }
                            else {
                                Write-Debug -Message '$SourceVMsToMigrate = $SourceSCVMsNotMigrating'
                                $SourceVMsToMigrate = $SourceSCVMsNotMigrating
                            }
                            
                            Write-Debug -Message '$FirstVM = $true'
                            $FirstVM = $true
                            Write-Debug -Message ('$FirstVM: ''{0}''' -f [string]$FirstVM)

                            Write-Debug -Message ('$SourceVMsToMigrate: ''{0}''' -f [string]$SourceVMsToMigrate.Name)
                            foreach ($SCVM in $SourceVMsToMigrate) {
                                # If a VM is migrating already - we don't care about it
                                Write-Debug -Message ('$SCVM: ''{0}''' -f $SCVM.Name)

                                Write-Debug -Message ('$FirstVM: ''{0}''' -f [string]$FirstVM)
                                Write-Debug -Message 'if ($FirstVM)'
                                if ($FirstVM) {
                                    # If this is the first VM in the loop, no need to refresh hosts' status again
                                    Write-Debug -Message '$FirstVM = $false'
                                    $FirstVM = $false
                                    Write-Debug -Message ('$FirstVM: ''{0}''' -f [string]$FirstVM)
                                }
                                else {
                                    Write-Debug -Message ('$Bulletproof: ''{0}''' -f [string]$Bulletproof)
                                    Write-Debug -Message 'if ($Bulletproof)'
                                    if ($Bulletproof) {
                                        Write-Debug -Message 'Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost)'
                                        Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost)
                                    }
                                }

                                Write-Debug -Message '$SourceVMHostVMs = Get-SCVirtualMachine -VMHost $SourceVMHost'
                                $SourceVMHostVMs = Get-SCVirtualMachine -VMHost $SourceVMHost
                                Write-Debug -Message ('$SourceVMHostVMs: ''{0}''' -f [string]$SourceSCVMsNotMigratingRunning.Name)
                                Write-Debug -Message '$SourceVMHostVMs = Get-SCVirtualMachine -VMHost $DestinationVMHost'
                                $DestinationVMHostVMs = Get-SCVirtualMachine -VMHost $DestinationVMHost
                                Write-Debug -Message ('$DestinationVMHostVMs: ''{0}''' -f [string]$SourceSCVMsNotMigratingRunning.Name)
                                
                                Write-Debug -Message '$SourceVMHostMigratingVMs = $SourceVMHostVMs | Where-Object -FilterScript {$_.Status -in $SCVMStatesMigrating}'
                                $SourceVMHostMigratingVMs = $SourceVMHostVMs | Where-Object -FilterScript {$_.Status -in $SCVMStatesMigrating}
                                Write-Debug -Message ('$SourceVMHostMigratingVMs: ''{0}''' -f [string]$SourceVMHostMigratingVMs.Name)
                                Write-Debug -Message '$DestinationVMHostMigratingVMs = $DestinationVMHostVMs | Where-Object -FilterScript {$_.Status -in $SCVMStatesMigrating}'
                                $DestinationVMHostMigratingVMs = $DestinationVMHostVMs | Where-Object -FilterScript {$_.Status -in $SCVMStatesMigrating}
                                Write-Debug -Message ('$DestinationVMHostMigratingVMs: ''{0}''' -f [string]$DestinationVMHostMigratingVMs.Name)
                                Write-Debug -Message ('$VMHostMigratingVMs = {0} + {1}' -f $SourceVMHostMigratingVMs.Count, $DestinationVMHostMigratingVMs.Count)
                                $VMHostMigratingVMsCount = $SourceVMHostMigratingVMs.Count + $DestinationVMHostMigratingVMs.Count
                                Write-Debug -Message ('$VMHostMigratingVMsCount = {0}' -f $VMHostMigratingVMsCount)

                                Write-Debug -Message ('$SourceVMHost.ServerConnection: ''{0}''' -f [string]$SourceVMHost.ServerConnection.FullyQualifiedDomainName)
                                Write-Debug -Message '$SCRunningJobs = Get-SCJob -VMMServer $SourceVMHost.ServerConnection -Running'
                                $SCRunningJobs = Get-SCJob -VMMServer $SourceVMHost.ServerConnection -Running
                                Write-Debug -Message ('$SCRunningJobs: ''{0}''' -f [string]$SCRunningJobs)
                                foreach ($SCRunningJob in $SCRunningJobs) {
                                    Write-Debug -Message ('$SCRunningJob.Name: ''{0}''' -f [string]$SCRunningJob.Name)
                                    Write-Debug -Message ('$SCRunningJob.CmdletName: ''{0}''' -f [string]$SCRunningJob.CmdletName)
                                    Write-Debug -Message ('$SCRunningJob.Source: ''{0}''' -f [string]$SCRunningJob.Source)
                                    Write-Debug -Message ('$SCRunningJob.Target: ''{0}''' -f [string]$SCRunningJob.Target)
                                }

                                # We use a separate filtering command, because it does not work in a single command: somehow the '-Running' parameter prevents subsequent filters from working correctly
                                # Turns out, "Source" and "Target" attributes have a delay for filling up, that's why I look for them in the name of the job as well.
                                Write-Debug -Message ('$MigrationJobs = $SCRunningJobs | Where-Object -FilterScript {{$_.CmdletName -eq ''Move-SCVirtualMachine'' -and ($_.Source -in @(''{0}'', ''{1}'') -or $_.Target -in @(''{0}'', ''{1}'') -or $_.Name -like (''*{{0}}*'' -f ''{0}'') -or $_.Name -like (''*{{0}}*'' -f ''{1}''))}}' -f $SourceVMHost.Name, $DestinationVMHost.Name)
                                $MigrationJobs = $SCRunningJobs | Where-Object -FilterScript {$_.CmdletName -eq 'Move-SCVirtualMachine' -and ($_.Source -in @($SourceVMHost.Name, $DestinationVMHost.Name) -or $_.Target -in @($SourceVMHost.Name, $DestinationVMHost.Name) -or $_.Name -like ('*{0}*' -f $SourceVMHost.Name) -or $_.Name -like ('*{0}*' -f $DestinationVMHost.Name))}
                                Write-Debug -Message ('$MigrationJobs: ''{0}''' -f [string]$MigrationJobs)
                                Write-Debug -Message ('$MigrationJobs.Count: {0}' -f $MigrationJobs.Count)
                                foreach ($MigrationJob in $MigrationJobs) {
                                    Write-Debug -Message ('$MigrationJob.Name: ''{0}''' -f [string]$MigrationJob.Name)
                                    Write-Debug -Message ('$MigrationJob.CmdletName: ''{0}''' -f [string]$MigrationJob.CmdletName)
                                    Write-Debug -Message ('$MigrationJob.Source: ''{0}''' -f [string]$MigrationJob.Source)
                                    Write-Debug -Message ('$MigrationJob.Target: ''{0}''' -f [string]$MigrationJob.Target)
                                }

                                Write-Debug -Message ('$CurrentLiveMigrationCount = (({0}, {1}) | Measure-Object -Maximum).Maximum' -f $MigrationJobs.Count, $VMHostMigratingVMsCount)
                                $CurrentLiveMigrationCount = (($MigrationJobs.Count, $VMHostMigratingVMsCount) | Measure-Object -Maximum).Maximum
                                Write-Debug -Message ('$CurrentLiveMigrationCount = {0}' -f $CurrentLiveMigrationCount)

                                Write-Debug -Message ('$LiveMigrationMaximum = {0}' -f $LiveMigrationMaximum)
                                Write-Debug -Message 'if ($CurrentLiveMigrationCount -lt $LiveMigrationMaximum)'
                                if ($CurrentLiveMigrationCount -lt $LiveMigrationMaximum) {
                                    # If the migration queue is not full (if it is full, we do no care who filled it up)
                                    $SCVirtualMachineLiveMigrationEligibility = Test-SCVirtualMachineLiveMigrationEligibility -VM $SCVM -VMHost $DestinationVMHost
                                    Write-Debug -Message ('$SCVirtualMachineLiveMigrationEligibility.Result: ''{0}''' -f $SCVirtualMachineLiveMigrationEligibility.Result)
                                    Write-Debug -Message ('$SCVirtualMachineLiveMigrationEligibility.Reason: ''{0}''' -f $SCVirtualMachineLiveMigrationEligibility.Reason)
                                    
                                    Write-Debug -Message 'if ($SCVirtualMachineLiveMigrationEligibility.Status -eq [Microsoft.VirtualManager.Utils.VMComputerSystemState]::IncompleteVMConfig)'
                                    if ($SCVirtualMachineLiveMigrationEligibility.Status -eq [Microsoft.VirtualManager.Utils.VMComputerSystemState]::IncompleteVMConfig) {
                                        Write-Debug -Message '$null = Read-SCVirtualMachine -VM $SCVM'
                                        $null = Read-SCVirtualMachine -VM $SCVM
                                        Write-Debug -Message '$null = $VMMigrationRetryInfo.Add($SCVM)'
                                        $null = $VMMigrationRetryInfo.Add($SCVM)
                                        Write-Debug -Message 'Continue'
                                        Continue
                                    }
                                    
                                    Write-Debug -Message 'if ($SCVirtualMachineLiveMigrationEligibility.Result -or $SCVirtualMachineLiveMigrationEligibility.Reason -eq ''NotRunning'')'
                                    if ($SCVirtualMachineLiveMigrationEligibility.Result -or $SCVirtualMachineLiveMigrationEligibility.Reason -eq 'NotRunning') {
                                        $VMMigrationRetryInfoCount = ($VMMigrationRetryInfo | Where-Object -FilterScript {$_ -eq $SCVM}).Count
                                        Write-Debug -Message 'if ($VMMigrationRetryInfoCount -ge $MaxAttempts)'
                                        if ($VMMigrationRetryInfoCount -ge $MaxAttempts) {
                                            Write-Verbose -Message ('VM {0} is unmigratable' -f $SCVM.Name)
                                            if ($CrashOnUnmigratable) {
                                                $Message = ('Tried to migrate VM {0} {1} times - did not succeed' -f $SCVM.Name, $MaxAttempts)
                                                $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.ServiceModel.Channels.RetryException' -ArgumentList $Message), 'RetryException', [System.Management.Automation.ErrorCategory]::OperationTimeout, $SCVM)))
                                            }
                                            else {
                                                Write-Debug -Message '$null = $UnmigratableVMs.Add($SCVM)'
                                                $null = $UnmigratableVMs.Add($SCVM)
                                            }
                                        }
                                    }

                                    Write-Debug -Message ('$UnmigratableVMs: ''{0}''' -f [string]$UnmigratableVMs.Name)
                                    Write-Debug -Message 'if ($SCVM -notin $UnmigratableVMs)'
                                    if ($SCVM -notin $UnmigratableVMs) {
                                        Write-Debug -Message 'if ($SCVirtualMachineLiveMigrationEligibility.Result)'
                                        if ($SCVirtualMachineLiveMigrationEligibility.Result) {
                                            Write-Debug -Message ('$Bulletproof: ''{0}''' -f [string]$Bulletproof)
                                            Write-Debug -Message 'if ($Bulletproof)'
                                            if ($Bulletproof) {
                                                Write-Debug -Message 'Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost)'
                                                Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost)
                                            }

                                            Write-Debug -Message ('$SCVM.VMHost: ''{0}''' -f [string]$SCVM.VMHost)
                                            Write-Debug -Message 'if ($SCVM.VMHost -ne $DestinationVMHost)'
                                            if ($SCVM.VMHost -ne $DestinationVMHost) {
                                                # Better safe than sorry
                                                Write-Debug -Message '$null = $VMMigrationRetryInfo.Add($SCVM)'
                                                $null = $VMMigrationRetryInfo.Add($SCVM)
                                                Write-Debug -Message ('$VMMigrationRetryInfo: ''{0}''' -f [string]$VMMigrationRetryInfo.Name)
                                                Write-Verbose -Message ('Trying to live-migrate a VM {0} from {1} to {2}' -f $SCVM.Name, $SCVM.VMHost.Name, $DestinationVMHost.Name)
                                                Write-Debug -Message ('$null = Move-SCVirtualMachine -VM $SCVM -VMHost $DestinationVMHost -Path ''{0}'' -RunAsynchronously' -f $Path)
                                                $null = Move-SCVirtualMachine -VM $SCVM -VMHost $DestinationVMHost -Path $Path -RunAsynchronously
                                                Write-Debug -Message ('$MigrationJobGetMaxAttempts = {0}' -f $MigrationJobGetMaxAttempts)
                                                Write-Debug -Message 'for ($MigrationJobGetCounter = 0; $MigrationJobGetCounter -lt $MigrationJobGetMaxAttempts; $MigrationJobGetCounter++)'
                                                for ($MigrationJobGetCounter = 0; $MigrationJobGetCounter -lt $MigrationJobGetMaxAttempts; $MigrationJobGetCounter++) {
                                                    Write-Debug -Message ('$MigrationJobGetCounter = {0}' -f $MigrationJobGetCounter)
                                                    Write-Debug -Message '$VMMigrationJob = Get-SCVirtualMachineMigrationJob -VM $SCVM'
                                                    $VMMigrationJob = Get-SCVirtualMachineMigrationJob -VM $SCVM
                                                    Write-Debug -Message ('$VMMigrationJob: ''{0}''' -f [string]$VMMigrationJob)
                                                    Write-Debug -Message 'if (-not $VMMigrationJob)'
                                                    if (-not $VMMigrationJob) {
                                                        Write-Debug -Message ('Start-Sleep -Seconds {0}' -f $MigrationJobGetTimeout)
                                                        Start-Sleep -Seconds $MigrationJobGetTimeout
                                                    }
                                                    else {
                                                        Write-Debug -Message 'break'
                                                        break
                                                    }
                                                }
                                                Write-Debug -Message 'if (-not $VMMigrationJob)'
                                                if (-not $VMMigrationJob) {
                                                    Write-Debug -Message 'Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost)'
                                                    Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost)
                                                }
                                                Write-Debug -Message '$LastVMWasPoweredDown = $false'
                                                $LastVMWasPoweredDown = $false
                                                Write-Debug -Message ('$LastVMWasPoweredDown: ''{0}''' -f [string]$LastVMWasPoweredDown)

                                                Write-Debug -Message ('$BackingUpVMs.VM: ''{0}''' -f [string]$BackingUpVMs.VM.Name)
                                                Write-Debug -Message 'if ($BackingUpVMs.VM -contains $SCVM)'
                                                if ($BackingUpVMs.VM -contains $SCVM) {
                                                    Write-Debug -Message '$BackingUpVMDescription = $BackingUpVMs | Where-Object -FilterScript {$_.VM -eq $SCVM}'
                                                    $BackingUpVMDescription = $BackingUpVMs | Where-Object -FilterScript {$_.VM -eq $SCVM}
                                                    Write-Debug -Message ('$BackingUpVMDescription: ''{0}''' -f [string]$BackingUpVMDescription)
                                                    Write-Debug -Message '$null = $BackingUpVMs.Remove($BackingUpVMDescription)'
                                                    $null = $BackingUpVMs.Remove($BackingUpVMDescription)
                                                    Write-Debug -Message ('$BackingUpVMs.VM: ''{0}''' -f [string]$BackingUpVMs.VM.Name)
                                                }
                                            }
                                        }
                                        else {
                                            Write-Verbose -Message ('Skipping VM {0} this time because: {1}' -f $SCVM.Name, $SCVirtualMachineLiveMigrationEligibility.Reason)
                                            switch ($SCVirtualMachineLiveMigrationEligibility.Reason) {
                                                'BackingUp' {
                                                    Write-Debug -Message ('$BackingUpVMs.VM: ''{0}''' -f [string]$BackingUpVMs.VM.Name)
                                                    Write-Debug -Message 'if ($BackingUpVMs.VM -contains $SCVM)'
                                                    if ($BackingUpVMs.VM -contains $SCVM) {
                                                        Write-Debug -Message '$BackingUpVMDescription = $BackingUpVMs | Where-Object -FilterScript {$_.VM -eq $SCVM}'
                                                        $BackingUpVMDescription = $BackingUpVMs | Where-Object -FilterScript {$_.VM -eq $SCVM}
                                                        Write-Debug -Message '$BackupAddDateTime = $BackingUpVMDescription.DateTime'
                                                        $BackupAddDateTime = $BackingUpVMDescription.DateTime
                                                        Write-Debug -Message ('$BackupAddDateTime: ''{0}''' -f [string]$BackupAddDateTime)
                                                        Write-Debug -Message '$CurrentDateTime = Get-Date'
                                                        $CurrentDateTime = Get-Date
                                                        Write-Debug -Message ('$CurrentDateTime: ''{0}''' -f [string]$CurrentDateTime)
                                                        Write-Debug -Message '$BackupDateTimeThreshold = $BackupAddDateTime + $BackupThreshold'
                                                        $BackupDateTimeThreshold = $BackupAddDateTime + $BackupThreshold
                                                        Write-Debug -Message ('$BackupDateTimeThreshold: ''{0}''' -f [string]$BackupDateTimeThreshold)
                                                        Write-Debug -Message 'if ($CurrentDateTime -gt $BackupDateTimeThreshold)'
                                                        if ($CurrentDateTime -gt $BackupDateTimeThreshold) {
                                                            Write-Verbose -Message ('VM {0} is unmigratable' -f $SCVM.Name)
                                                            if ($CrashOnUnmigratable) {
                                                                $Message = ('VM {0} is in backing up state for more than {1} already' -f $SCVM.Name, [string]$BackupThreshold)
                                                                $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.TimeoutException' -ArgumentList $Message), 'TimeoutException', [System.Management.Automation.ErrorCategory]::OperationTimeout, $SCVM)))
                                                            }
                                                            else {
                                                                Write-Debug -Message '$null = $UnmigratableVMs.Add($SCVM)'
                                                                $null = $UnmigratableVMs.Add($SCVM)
                                                                Write-Debug -Message ('$UnmigratableVMs: ''{0}''' -f [string]$UnmigratableVMs.Name)
                                                                Write-Debug -Message '$null = $BackingUpVMs.Remove($BackingUpVMDescription)'
                                                                $null = $BackingUpVMs.Remove($BackingUpVMDescription)
                                                                Write-Debug -Message ('$BackingUpVMs.VM: ''{0}''' -f [string]$BackingUpVMs.VM.Name)
                                                            }
                                                        }
                                                    }
                                                    else {
                                                        Write-Debug -Message '$CurrentDateTime = Get-Date'
                                                        $CurrentDateTime = Get-Date
                                                        Write-Debug -Message ('$CurrentDateTime: ''{0}''' -f [string]$CurrentDateTime)
                                                        Write-Debug -Message '$null = $BackingUpVMs.Add(@{VM = $SCVM; DateTime = $CurrentDateTime})'
                                                        $null = $BackingUpVMs.Add(
                                                            @{
                                                                VM       = $SCVM
                                                                DateTime = $CurrentDateTime
                                                            }
                                                        )
                                                        Write-Debug -Message ('$BackingUpVMs.VM: ''{0}''' -f [string]$BackingUpVMs.VM.Name)
                                                    }
                                                }
                                                'NotRunning' {
                                                    Write-Debug -Message ('$Bulletproof: ''{0}''' -f [string]$Bulletproof)
                                                    Write-Debug -Message 'if ($Bulletproof)'
                                                    if ($Bulletproof) {
                                                        Write-Debug -Message 'Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost)'
                                                        Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost)
                                                    }

                                                    Write-Debug -Message ('$SourceSCVMs.Status: ''{0}''' -f [string]$SourceSCVMs.Status)
                                                    Write-Debug -Message '$SourceSCVMsRunning = $SourceSCVMs | Where-Object -FilterScript {$_.Status -in $SCVMStatesRunning}'
                                                    $SourceSCVMsRunning = $SourceSCVMs | Where-Object -FilterScript {$_.Status -in $SCVMStatesRunning}
                                                    Write-Debug -Message ('$SourceSCVMsRunning: ''{0}''' -f [string]$SourceSCVMsRunning.Name)
                                                    Write-Debug -Message '$SourceSCVMsMigrating = $SourceSCVMs | Where-Object -FilterScript {$_.Status -in $SCVMStatesMigrating}'
                                                    $SourceSCVMsMigrating = $SourceSCVMs | Where-Object -FilterScript {$_.Status -in $SCVMStatesMigrating}
                                                    Write-Debug -Message ('$SourceSCVMsMigrating: ''{0}''' -f [string]$SourceSCVMsMigrating.Name)
                                                    Write-Debug -Message 'if (-not ($SourceSCVMsRunning -or $SourceSCVMsMigrating))'
                                                    if (-not ($SourceSCVMsRunning -or $SourceSCVMsMigrating)) {
                                                        # We do not want to move PoweredDown VMs while there's anything in the queue. We also want to migrate them as last as possible.
                                                        Write-Debug -Message '$null = $VMMigrationRetryInfo.Add($SCVM)'
                                                        $null = $VMMigrationRetryInfo.Add($SCVM)
                                                        Write-Debug -Message ('$VMMigrationRetryInfo: ''{0}''' -f [string]$VMMigrationRetryInfo.Name)
                                                        Write-Verbose -Message ('Trying to migrate a powered-down VM {0}' -f $SCVM.Name)
                                                        Write-Debug -Message ('Move-SCPoweredDownVirtualMachine -VM $SCVM -VMHost $DestinationVMHost -Path ''{0}''' -f $Path)
                                                        Move-SCPoweredDownVirtualMachine -VM $SCVM -VMHost $DestinationVMHost -Path $Path
                                                        Write-Debug -Message '$LastVMWasPoweredDown = $true'
                                                        $LastVMWasPoweredDown = $true
                                                        Write-Debug -Message ('$LastVMWasPoweredDown: ''{0}''' -f [string]$LastVMWasPoweredDown)
                                                    }
                                                }
                                                'Failed' {
                                                    Write-Debug -Message '$null = Repair-SCVirtualMachine -VM $SCVM -Dismiss -Force'
                                                    $null = Repair-SCVirtualMachine -VM $SCVM -Dismiss -Force
                                                }
                                                'OK' {
                                                    Write-Debug -Message '$null = $UnmigratableVMs.Add($SCVM)'
                                                    $null = $UnmigratableVMs.Add($SCVM)
                                                    Write-Debug -Message ('$UnmigratableVMs: ''{0}''' -f [string]$UnmigratableVMs.Name)
                                                    Write-Debug -Message ('$BackingUpVMs.VM: ''{0}''' -f [string]$BackingUpVMs.VM.Name)
                                                    Write-Debug -Message 'if ($BackingUpVMs.VM -contains $SCVM)'
                                                    if ($BackingUpVMs.VM -contains $SCVM) {
                                                        Write-Debug -Message '$BackingUpVMDescription = $BackingUpVMs | Where-Object -FilterScript {$_.VM -eq $SCVM}'
                                                        $BackingUpVMDescription = $BackingUpVMs | Where-Object -FilterScript {$_.VM -eq $SCVM}
                                                        Write-Debug -Message ('$BackingUpVMDescription: ''{0}''' -f [string]$BackingUpVMDescription)
                                                        Write-Debug -Message '$null = $BackingUpVMs.Remove($BackingUpVMDescription)'
                                                        $null = $BackingUpVMs.Remove($BackingUpVMDescription)
                                                        Write-Debug -Message ('$BackingUpVMs.VM: ''{0}''' -f [string]$BackingUpVMs.VM.Name)
                                                    }
                                                    Write-Verbose -Message ('VM {0} is unmigratable because of an unsupported status: {1}' -f $SCVM.Name, $SCVirtualMachineLiveMigrationEligibility.Status)
                                                }
                                            }
                                        }
                                    }
                                }
                                else {
                                    Write-Debug -Message ('$Bulletproof: ''{0}''' -f [string]$Bulletproof)
                                    Write-Debug -Message 'if (-not $Bulletproof)'
                                    if (-not $Bulletproof) {
                                        Write-Debug -Message 'Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost)'
                                        Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost)
                                    }
                                }
                            }

                            Write-Debug -Message 'if (-not $LastVMWasPoweredDown)' # No need to wait if the last job was synchronous
                            if (-not $LastVMWasPoweredDown) {
                                Write-Debug -Message ('Start-Sleep -Seconds {0}' -f $Timeout)
                                Start-Sleep -Seconds $Timeout
                            }
                        }

                        Write-Debug -Message ('$SourceSCVMs: ''{0}''' -f [string]$SourceSCVMs.Name)
                        Write-Debug -Message 'while ($SourceSCVMs)'
                    }
                    while ($SourceSCVMs)

                    Write-Debug -Message 'Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost)'
                    Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost) # Make sure our VM objects are fresh

                    Write-Debug -Message ('$UnmigratableVMs: ''{0}''' -f [string]$UnmigratableVMs.Name)
                    Write-Debug -Message 'if ($UnmigratableVMs)'
                    if ($UnmigratableVMs) {
                        foreach ($SCVM in $UnmigratableVMs) {
                            Write-Debug -Message ('$SCVM: ''{0}''' -f $SCVM.Name)
                            Write-Debug -Message ('$SCVM.VMHost: ''{0}''' -f [string]$SCVM.VMHost)
                            Write-Debug -Message 'if ($SCVM.VMHost -eq $DestinationVMHost)'
                            if ($SCVM.VMHost -eq $DestinationVMHost) {
                                Write-Debug -Message '$null = $UnmigratableVMs.Remove($SCVM)'
                                $null = $UnmigratableVMs.Remove($SCVM) # If a VM somehow migrated - we do not care how did it do that.
                                Write-Debug -Message ('$UnmigratableVMs: ''{0}''' -f [string]$UnmigratableVMs.Name)
                                Write-Verbose -Message ('VM {0} is not unmigratable anymore - it migrated somehow' -f $SCVM.Name)
                            }
                        }

                        Write-Debug -Message ('$UnmigratableVMs.Count: {0}' -f $UnmigratableVMs.Count)
                        Write-Debug -Message 'if ($UnmigratableVMs.Count -gt 0)'
                        if ($UnmigratableVMs.Count -gt 0) {
                            Write-Debug -Message ('$UnmigratableVMs: ''{0}''' -f [string]$UnmigratableVMs.Name)
                            Write-Debug -Message '$UnmigratableVMs'
                            $UnmigratableVMs
                        }
                    }
                }
            }
            else {
                $Message = 'Source ({0}, ID: {1}) and destination ({2}, ID: {3}) VMM servers are different' -f $SourceVMHost.ServerConnection.FullyQualifiedDomainName, $SourceVMHost.ServerConnection.ManagedComputer.ID, $DestinationVMHost.ServerConnection.FullyQualifiedDomainName, $DestinationVMHost.ServerConnection.ManagedComputer.ID
                $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.ArgumentException' -ArgumentList $Message), 'ArgumentException', [System.Management.Automation.ErrorCategory]::InvalidArgument, $null)))
            }
        }
        else {
            $Message = 'Source ({0}) and destination ({1}) servers are the same' -f $SourceVMHost, $DestinationVMHost
            $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.ArgumentException' -ArgumentList $Message), 'ArgumentException', [System.Management.Automation.ErrorCategory]::InvalidArgument, $null)))
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