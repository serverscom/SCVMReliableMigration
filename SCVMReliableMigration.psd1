@{
    RootModule        = 'SCVMReliableMigration.psm1'
    ModuleVersion     = '1.2.0'
    GUID              = '71e06da4-4888-4f09-9af0-f92d52cc1cda'
    Author            = 'Kirill Nikolaev'
    CompanyName       = 'Fozzy Inc.'
    Copyright         = '(c) 2018 Fozzy Inc. All rights reserved.'
    PowerShellVersion = '3.0'
    Description       = 'Solves 4 problems which you most certainly bump into, when migrating VMs in a shared-nothing Hyper-V environment managed by System Center Virtual Machine Manager: live-migration limit, Hyper-V Extended Network ACLs don''t migrate, VM network adapter loses connectivity for a powered-down VM, backing up VMs cannot be migrated.'
    RequiredModules   = @(
        'virtualmachinemanager'
    )
    FunctionsToExport = @(
        'Move-SCPoweredDownVirtualMachine'
        'Move-SCVirtualMachineReliably'
    )
    CmdletsToExport   = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags                       = @()
            LicenseUri                 = 'https://github.com/FozzyHosting/SCVMReliableMigration/blob/master/LICENSE'
            ProjectUri                 = 'https://github.com/FozzyHosting/SCVMReliableMigration/'
            ReleaseNotes               = ''
            ExternalModuleDependencies = @(
                'virtualmachinemanager'
            )
        }
    }
}
