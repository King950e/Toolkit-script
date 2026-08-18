# Target Path: ...\Toolkit_Files\AddAdmin.ps1
# Elevates a user to Domain Admin.
param (
    [string]$ErrorLog = "$env:USERPROFILE\Desktop\IT_Toolkit_Logs\Toolkit_Errors.txt"
)

. "$PSScriptRoot\ToolkitCommon.ps1"
$Config = Get-ToolkitConfig
Invoke-LogRotation -LogPath $ErrorLog -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep

Import-Module ActiveDirectory
$User = Read-Host "Enter target username to make Domain Admin"

try {
    Add-ADGroupMember -Identity "Domain Admins" -Members $User -ErrorAction Stop
    Write-Host "Elevated successfully." -ForegroundColor Green
    Write-ToolkitAudit -Action "Domain Admin Elevation" -Target $User -Result "Success" -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep
} catch {
    "[$(Get-Date)] [Admin Privilege Elevation] Failed to elevate '$User'. Detail: $_" | Out-File $ErrorLog -Append
    Write-ToolkitAudit -Action "Domain Admin Elevation" -Target $User -Result "Failed" -Detail $_.Exception.Message -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep
    Write-Error "Action execution terminated."
}
Read-Host "Press Enter to return to menu..."
