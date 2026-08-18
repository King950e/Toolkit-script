# Target Path: ...\Toolkit_Files\TestAlert.ps1
param (
    [string]$ErrorLog = "$env:USERPROFILE\Desktop\IT_Toolkit_Logs\Toolkit_Errors.txt"
)

. "$PSScriptRoot\ToolkitCommon.ps1"
$Config = Get-ToolkitConfig
Invoke-LogRotation -LogPath $ErrorLog -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep

Write-Host "Simulating an IT Toolkit exception engine test..." -ForegroundColor Yellow
try {
    # Force a divide-by-zero math engine explosion error
    $CrashTest = 1 / 0
} catch {
    $ErrorMsg = $_.Exception.Message
    Write-Host "Caught expected error: $ErrorMsg" -ForegroundColor Red

    # Ship the mock failure directly to the global error file and email dispatcher
    "[$(Get-Date)] [Simulation Engine Test] Failed as expected: $ErrorMsg" | Out-File $ErrorLog -Append
    Write-ToolkitAudit -Action "Alert Engine Test" -Target $env:COMPUTERNAME -Result "Simulated Failure" -Detail $ErrorMsg -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep

    & "$PSScriptRoot\SendAlert.ps1" -ScriptName "Simulation Test Core" -ErrorMessage $ErrorMsg -ErrorLog $ErrorLog
    Write-Host "Alert verification successfully dispatched to SendAlert engine!" -ForegroundColor Green
}
Read-Host "Press Enter to return..."
