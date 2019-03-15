@{
    RootModule        = 'SCVMReliableMigration.psm1'
    ModuleVersion     = '1.1.0'
    GUID              = '71e06da4-4888-4f09-9af0-f92d52cc1cda'
    Author            = 'Kirill Nikolaev'
    CompanyName       = 'Fozzy Inc.'
    Copyright         = '(c) 2018 Fozzy Inc. All rights reserved.'
    PowerShellVersion = '3.0'
    RequiredModules   = @(
        'virtualmachinemanager'
    )
    FunctionsToExport = @(
        'Move-SCPoweredDownVirtualMachine'
        'Move-SCVirtualMachineReliably'
    )
    CmdletsToExport   = @()
    AliasesToExport   = @()
}