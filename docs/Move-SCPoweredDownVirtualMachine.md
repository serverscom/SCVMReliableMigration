---
external help file: SCVMReliableMigration-help.xml
Module Name: SCVMReliableMigration
online version:
schema: 2.0.0
---

# Move-SCPoweredDownVirtualMachine

## SYNOPSIS
Initially an internal function, contains code necessary to process a powered down VM. It might become handy in case you want to migrate just a single powered down VM, w/o worrying about its network settings.

## SYNTAX

```
Move-SCPoweredDownVirtualMachine [-VM] <VM> [-VMHost] <Host> [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION
Initially an internal function, contains code necessary to process a powered down VM. It might become handy in case you want to migrate just a single powered down VM, w/o worrying about its network settings.

## EXAMPLES

### Example 1
```powershell
$VM = Get-SCVirtualMachine -Name 'SRVDC01' -VMMServer SRVVMM01
Move-SCPoweredDownVirtualMachine -VM $VM -DestinationVMHost (Get-SCVMHost -ComputerName SRVHV02 -VMMServer SRVVMM01) -Path 'D:\VirtualMachines'
```

Migrates a virtual machine SRVDC01 to a Hyper-V host SRVHV02, placing them into the "D:\VirtualMachines" folder.

## PARAMETERS

### -VM
A virtual machine object which you would like to migrate.

```yaml
Type: Microsoft.SystemCenter.VirtualMachineManager.VM
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VMHost
A VMHost object of a Hyper-V host where you want to migrate virtual machines.

```yaml
Type: Microsoft.SystemCenter.VirtualMachineManager.Host
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
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
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
