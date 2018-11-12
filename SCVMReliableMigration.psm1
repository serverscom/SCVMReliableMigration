#Requires -Version 3.0

$ModulePath = $PSScriptRoot

[int]$ModuleWideMigrationTimeout = 60
[int]$ModuleWideMigrationMaxAttempts = 3
[int]$ModuleWideMigrationJobGetTimeout = 10
[int]$ModuleWideMigrationJobGetMaxAttempts = 3
[System.TimeSpan]$ModuleWideBackupThreshold = New-Object -TypeName 'System.TimeSpan' -ArgumentList @(1, 0, 0)

foreach ($FunctionType in @('Private', 'Public')) {
    $Path = Join-Path -Path $ModulePath -ChildPath ('{0}\*.ps1' -f $FunctionType)
    if (Test-Path -Path $Path) {
        Get-ChildItem -Path $Path -Recurse | ForEach-Object -Process {. $_.FullName}
    }
}

$Path = Join-Path -Path $ModulePath -ChildPath 'Config.ps1'
if (Test-Path -Path $Path -PathType Leaf) {
    . $Path
}