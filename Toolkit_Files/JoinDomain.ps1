# Target Path: ...\Toolkit_Files\JoinDomain.ps1
param (
    [string]$ErrorLog = "$env:USERPROFILE\Desktop\IT_Toolkit_Logs\Toolkit_Errors.txt"
)

. "$PSScriptRoot\ToolkitCommon.ps1"
$Config = Get-ToolkitConfig
Invoke-LogRotation -LogPath $ErrorLog -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep

$Domain = Read-Host "Enter Domain Name to Join"

try {
    Add-Computer -DomainName $Domain -Restart -Force -ErrorAction Stop
    Write-ToolkitAudit -Action "Domain Join" -Target $Domain -Result "Success" -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep
} catch {
    "[$(Get-Date)] [Active Directory Domain Join] Remote system target attachment failed. Detail: $_" | Out-File $ErrorLog -Append
    Write-ToolkitAudit -Action "Domain Join" -Target $Domain -Result "Failed" -Detail $_.Exception.Message -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep
    Write-Error "Action execution terminated."
    Read-Host "Press Enter to return to menu..."
}
