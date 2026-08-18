# Target Path: ...\Toolkit_Files\ResetPassword.ps1
# Active Directory password reset + account status check + unlock, with an audit trail.
param (
    [string]$ErrorLog = "$env:USERPROFILE\Desktop\IT_Toolkit_Logs\Toolkit_Errors.txt",
    [string]$LogDir = "$env:USERPROFILE\Desktop\IT_Toolkit_Logs"
)

. "$PSScriptRoot\ToolkitCommon.ps1"
$Config = Get-ToolkitConfig
Invoke-LogRotation -LogPath $ErrorLog -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep

Import-Module ActiveDirectory -ErrorAction SilentlyContinue

$Username = Read-Host "Enter the AD Username"
$AdUser = Get-ADUser -Identity $Username -Properties LockedOut, Enabled, PasswordExpired, PasswordLastSet -ErrorAction SilentlyContinue

if (-not $AdUser) {
    Write-Host "Error: The username '$Username' does not exist in Active Directory." -ForegroundColor Yellow
    Read-Host "Press Enter to return to menu..."
    exit
}

Write-Host "User '$Username' found!" -ForegroundColor Green
Write-Host "-------------------------------------------------------" -ForegroundColor Cyan
Write-Host "  Enabled:          $($AdUser.Enabled)"
Write-Host "  Locked Out:       $($AdUser.LockedOut)"
Write-Host "  Password Expired: $($AdUser.PasswordExpired)"
Write-Host "  Password Last Set:$($AdUser.PasswordLastSet)"
Write-Host "-------------------------------------------------------" -ForegroundColor Cyan

# Offer to unlock, if currently locked out
if ($AdUser.LockedOut) {
    $UnlockChoice = Read-Host "This account is LOCKED OUT. Unlock it now? (Y/N, default Y)"
    if ([string]::IsNullOrWhiteSpace($UnlockChoice) -or $UnlockChoice -match '^[Yy]') {
        try {
            Unlock-ADAccount -Identity $Username -ErrorAction Stop
            Write-Host "Account unlocked." -ForegroundColor Green
            Write-ToolkitAudit -Action "Account Unlock" -Target $Username -Result "Success" -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep
        } catch {
            "[$(Get-Date)] [AD Account Unlock] Failed to unlock '$Username'. Detail: $_" | Out-File $ErrorLog -Append
            Write-ToolkitAudit -Action "Account Unlock" -Target $Username -Result "Failed" -Detail $_.Exception.Message -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep
            Write-Host "Failed to unlock account: $_" -ForegroundColor Red
        }
    }
}

# Offer to reset the password
$ResetChoice = Read-Host "Reset this user's password now? (Y/N, default Y)"
if (-not ([string]::IsNullOrWhiteSpace($ResetChoice) -or $ResetChoice -match '^[Yy]')) {
    Write-Host "Skipped password reset." -ForegroundColor Yellow
    Read-Host "Press Enter to return to menu..."
    exit
}

$Password = Read-Host "Enter the new password" -AsSecureString

try {
    Set-ADAccountPassword -Identity $Username -NewPassword $Password -Reset $true -ErrorAction Stop
    Set-ADUser -Identity $Username -ChangePasswordAtLogon $true -ErrorAction Stop
    Write-Host "Password successfully reset! User must change it at next logon." -ForegroundColor Green
    Write-ToolkitAudit -Action "Password Reset" -Target $Username -Result "Success" -Detail "ChangePasswordAtLogon=true" -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep
} catch {
    "[$(Get-Date)] [AD Password Reset] Failed to reset password for '$Username'. Detail: $_" | Out-File $ErrorLog -Append
    Write-ToolkitAudit -Action "Password Reset" -Target $Username -Result "Failed" -Detail $_.Exception.Message -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep
    Write-Host "Failed to reset password: $_" -ForegroundColor Red
}

Read-Host "Press Enter to return to menu..."
