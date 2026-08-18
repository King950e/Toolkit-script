# Target Path: ...\Toolkit_Files\LeaveDomain.ps1
param (
    [string]$ErrorLog = "$env:USERPROFILE\Desktop\IT_Toolkit_Logs\Toolkit_Errors.txt"
)

. "$PSScriptRoot\ToolkitCommon.ps1"
$Config = Get-ToolkitConfig
Invoke-LogRotation -LogPath $ErrorLog -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep

$Workgroup = Read-Host "Enter target Workgroup name (Default: WORKGROUP)"
if ([string]::IsNullOrEmpty($Workgroup)) { $Workgroup = "WORKGROUP" }

try {
    Remove-Computer -WorkgroupName $Workgroup -Restart -Force -ErrorAction Stop
    Write-ToolkitAudit -Action "Domain Leave" -Target $Workgroup -Result "Success" -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep
} catch {
    "[$(Get-Date)] [Active Directory Domain Leave] Machine dissociation failed. Detail: $_" | Out-File $ErrorLog -Append
    Write-ToolkitAudit -Action "Domain Leave" -Target $Workgroup -Result "Failed" -Detail $_.Exception.Message -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep
    Write-Error "Action execution terminated."
    Read-Host "Press Enter to return to menu..."
}
