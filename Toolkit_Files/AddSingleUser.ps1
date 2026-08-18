# Target Path: ...\Toolkit_Files\AddSingleUser.ps1
# Provisions a single AD user account.
param (
    [string]$ErrorLog = "$env:USERPROFILE\Desktop\IT_Toolkit_Logs\Toolkit_Errors.txt",
    [string]$UpnSuffix
)

. "$PSScriptRoot\ToolkitCommon.ps1"
$Config = Get-ToolkitConfig
if ([string]::IsNullOrWhiteSpace($UpnSuffix)) { $UpnSuffix = $Config.UpnSuffix }
Invoke-LogRotation -LogPath $ErrorLog -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep

Import-Module ActiveDirectory
$Username  = Read-Host "Enter SamAccountName"
$Firstname = Read-Host "Enter First Name"
$Lastname  = Read-Host "Enter Last Name"
$OU        = Read-Host "Enter Target OU Distinguished Name"
$Password  = Read-Host "Enter Password" -AsSecureString

try {
    New-ADUser -SamAccountName $Username -UserPrincipalName "$Username@$UpnSuffix" -Name "$Firstname $Lastname" -GivenName $Firstname -Surname $Lastname -Enabled $true -Path $OU -AccountPassword $Password -ChangePasswordAtLogon $true -ErrorAction Stop
    Write-Host "Created successfully." -ForegroundColor Green
    Write-ToolkitAudit -Action "Single User Create" -Target $Username -Result "Success" -Detail "OU=$OU" -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep
} catch {
    "[$(Get-Date)] [Single Account Provisioning] Failed to create '$Username'. Detail: $_" | Out-File $ErrorLog -Append
    Write-ToolkitAudit -Action "Single User Create" -Target $Username -Result "Failed" -Detail $_.Exception.Message -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep
    Write-Error "Action execution terminated."
}
Read-Host "Press Enter to return to menu..."
