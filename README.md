# SCVMReliableMigration

This module solves four problems which apply to VM migrations in a shared-nothing Hyper-V infrastructure (Azure-like), managed by SCVMM:

1. Live-migration limit.

    When you try to live-migrate the number of VMs which exceeds the live-migration limit, some of the jobs will wait for several minutes and then fail. While this is not an issue in clustered environments, since memory migration is relatively quick, it becomes important in shared-nothing infrastructures.

2. Hyper-V Extended Network ACLs.

    Native Hyper-V extended access control lists are more flexible then SCVMM wrappers - port access control lists. But when you migrate a VM, SCVMM knows nothing about Hyper-V ACLs assigned to it and, therefore, they might get lost.

3. VM network adapter might lost connectivity to a VM network when you migrate a powered-down machine.

4. It is impossible to migrate a machine which is currently backing up. The module relieves you from the burden of waiting and waits and retries migrations for you.

The module works around those problems by introducing additional checks and correction actions to the migration process. Also, if something happens during a migration, it retries again several times.

## Exported functions
* [Move-SCVirtualMachineReliably](docs/Move-SCVirtualMachineReliably.md)
* [Move-SCPoweredDownVirtualMachine](docs/Move-SCPoweredDownVirtualMachine.md)

## Module-wide variables
There are several variables defined in the .psm1-file, which are used by the module's functions as default values for parameters:

`[int]$ModuleWideMigrationMaxAttempts` - default value for **Move-SCVirtualMachineReliably**'s `-MaxAttempts` parameter

`[int]$ModuleWideMigrationTimeout` - default value for **Move-SCVirtualMachineReliably**'s `-Timeout` parameter

`[int]$ModuleWideMigrationJobGetTimeout` - default value for **Move-SCVirtualMachineReliably**'s `-MigrationJobGetTimeout` parameter

`[int]$ModuleWideMigrationJobGetMaxAttempts` - default value for **Move-SCVirtualMachineReliably**'s `-MigrationJobGetMaxAttempts` parameter

`[System.TimeSpan]$ModuleWideBackupThreshold` - default value for **Move-SCVirtualMachineReliably**'s `-BackupThreshold` parameter

## Loading variables from an external source
All module-wide variables can be redefined with a `Config.ps1` file, located in the module's root folder. Just put variable definitions in there as you would do with any other PowerShell script. You may find an example of a config file `Config-Example.ps1` in the module's root folder.

## Limitations
* Only one-to-one source-destination host mapping is supported.
* Only one virtual network adapter per shutdown VM is supported.