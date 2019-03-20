---
external help file: SCVMReliableMigration-help.xml
Module Name: SCVMReliableMigration
online version:
schema: 2.0.0
---

# Move-SCVirtualMachineReliably

## SYNOPSIS
This is a main function in the module. Use it to migrate virtual machines without hassle.

## SYNTAX

### ByHost
```
Move-SCVirtualMachineReliably -SourceVMHost <Host> -DestinationVMHost <Host> -Path <String> [-Timeout <Int32>]
 [-MaxAttempts <Int32>] [-MaxParallelMigrations <Int32>] [-MigrationJobGetTimeout <Int32>] [-MigrationJobGetMaxAttempts <Int32>]
 [-BackupThreshold <TimeSpan>] [-Bulletproof] [-CrashOnUnmigratable] [<CommonParameters>]
```

### ByVM
```
Move-SCVirtualMachineReliably -VM <VM[]> -DestinationVMHost <Host> -Path <String> [-Timeout <Int32>]
 [-MaxAttempts <Int32>] [-MaxParallelMigrations <Int32>] [-MigrationJobGetTimeout <Int32>] [-MigrationJobGetMaxAttempts <Int32>]
 [-BackupThreshold <TimeSpan>] [-Bulletproof] [-CrashOnUnmigratable] [<CommonParameters>]
```

## DESCRIPTION
This is a main function in the module. Use it to migrate virtual machines without hassle.

## EXAMPLES

### Example 1
```powershell
$VMs = Get-SCVirtualMachine -VMHost (Get-SCVMHost -ComputerName SRVHV01 -VMMServer SRVVMM01) | Where-Object -FilterScript {$_.Name -like 'SRVSP*'}
Move-SCVirtualMachineReliably -VM $VMs -DestinationVMHost (Get-SCVMHost -ComputerName SRVHV02 -VMMServer SRVVMM01) -Path 'D:\VirtualMachines'
```

Migrates all virtual machines, which name starts with "SRVSP*", from a Hyper-V host SRVHV01 to SRVHV02, placing them into the "D:\VirtualMachines" folder at SRVHV02.

### Example 2
```powershell
Move-SCVirtualMachineReliably -SourceVMHost (Get-SCVMHost -ComputerName SRVHV01 -VMMServer SRVVMM01) -DestinationVMHost (Get-SCVMHost -ComputerName SRVHV02 -VMMServer SRVVMM01) -Path 'D:\VirtualMachines'
```

Migrates all virtual machines from a Hyper-V host SRVHV01 to SRVHV02, placing them into the "D:\VirtualMachines" folder at SRVHV02.

### Example 3
```powershell
$VMs = Get-SCVirtualMachine -VMHost (Get-SCVMHost -ComputerName SRVHV01 -VMMServer SRVVMM01) | Where-Object -FilterScript {$_.Name -like 'SRVSP*'}
Move-SCVirtualMachineReliably -VM $VMs -DestinationVMHost (Get-SCVMHost -ComputerName SRVHV02 -VMMServer SRVVMM01) -Path 'D:\VirtualMachines' -BackupThreshold (New-Object -TypeName 'System.TimeSpan' -ArgumentList @(2, 0, 0))
```

Migrates all virtual machines, which name starts with "SRVSP*", from a Hyper-V host SRVHV01 to SRVHV02, placing them into the "D:\VirtualMachines" folder at SRVHV02. If any machine is in the backing up state, the function will wait for no more than two hours to let the backup process to finish.

## PARAMETERS

### -VM
A virtual machine objects which you would like to migrate.

```yaml
Type: Microsoft.SystemCenter.VirtualMachineManager.VM[]
Parameter Sets: ByVM
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SourceVMHost
If you want to migrate ALL VMs from a Hyper-V host, you can just specify its VMHost object, instead of passing each VM at the host to the `-VM` parameter.

```yaml
Type: Microsoft.SystemCenter.VirtualMachineManager.Host
Parameter Sets: ByHost
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DestinationVMHost
A VMHost object of a Hyper-V host where you want to migrate virtual machines.

```yaml
Type: Microsoft.SystemCenter.VirtualMachineManager.Host
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
A location on the destination host where virtual machines should be stored.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxAttempts
If a migration of a VM fails, the function will try again. This parameter specifies the maximum number of attempts.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxParallelMigrations
Sets the maximum number of parallel live migrations. If the parameter is not set, the minimum value between LiveMigrationMaximum properties of all affected hypervisors is used. If the parameter is set but exceeds that minimum value, the minimum value is used.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Timeout
When the migration queue is full, the function will wait some time before checking the queue's status again. This parameter specifies how long will it wait.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackupThreshold
If a VM is backing up - you cannot migrate it. In that case, the function will ignore the for some time. This parameters specifies for how long the function will wait for the backup to complete before declaring the VM unmigratable.

```yaml
Type: TimeSpan
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Bulletproof
Enabling this parameter refreshes VM status more frequently, but it is a performance hit.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CrashOnUnmigratable
By default, at the end, the function returns all machines which it was unable to migrate. Enabling this parameter changes the function's behavior to raise an exception as soon as an unmigratable machine is found.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MigrationJobGetMaxAttempts
When an asynchronous migration of a VM starts, it needs some time before appearing in the list of jobs. Before proceeding to the next VM, the function tries to find the migration job it has just created in the list. This parameter specifies the maximum number of such attempts.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MigrationJobGetTimeout
When an asynchronous migration of a VM starts, it needs some time before appearing in the list of jobs. Before proceeding to the next VM, the function tries to find the migration job it has just created in the list. This parameter specifies how long the function will wait between retries (`-MigrationJobGetMaxAttempts` parameter).

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Microsoft.SystemCenter.VirtualMachineManager.VM[]
### Microsoft.SystemCenter.VirtualMachineManager.Host

## OUTPUTS

### Microsoft.SystemCenter.VirtualMachineManager.VM

## NOTES

## RELATED LINKS
