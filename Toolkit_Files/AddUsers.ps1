# Target Path: ...\Toolkit_Files\AddUsers.ps1
# Bulk-provisions AD users from a CSV (columns: Username, Firstname, Lastname, OU, Password).
param (
    [string]$ErrorLog = "$env:USERPROFILE\Desktop\IT_Toolkit_Logs\Toolkit_Errors.txt",
    [string]$CSVPath,
    [string]$UpnSuffix
)

. "$PSScriptRoot\ToolkitCommon.ps1"
$Config = Get-ToolkitConfig
if ([string]::IsNullOrWhiteSpace($UpnSuffix)) { $UpnSuffix = $Config.UpnSuffix }
Invoke-LogRotation -LogPath $ErrorLog -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep

Import-Module ActiveDirectory

if ([string]::IsNullOrWhiteSpace($CSVPath)) {
    $CSVPath = Read-Host "Enter full path to the import CSV (Username,Firstname,Lastname,OU,Password)"
}

if (-not (Test-Path $CSVPath)) {
    "[$(Get-Date)] [Bulk Import Engine] CRITICAL: CSV not found at $CSVPath" | Out-File $ErrorLog -Append
    Write-Error "CSV target layout file was not located at $CSVPath"
    Read-Host "Press Enter to return to menu..."
    exit
}

Write-Host "SECURITY NOTE: this CSV contains plaintext passwords. Once the import finishes," -ForegroundColor Yellow
Write-Host "delete or securely archive '$CSVPath' — do not leave it sitting on the desktop." -ForegroundColor Yellow
Write-Host ""

$Users = Import-Csv -Path $CSVPath
$Created = 0
$Skipped = 0
$Failed  = 0
$Results = @()   # per-user report rows, exported to CSV at the end

foreach ($User in $Users) {
    $Username = $User.Username
    try {
        if (Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue) {
            "[$(Get-Date)] [Bulk Import] Skipped '$Username' — account already exists." | Out-File $ErrorLog -Append
            Write-ToolkitAudit -Action "Bulk User Create" -Target $Username -Result "Skipped" -Detail "Already exists" -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep
            $Results += [PSCustomObject]@{ Username = $Username; Status = "Skipped"; Detail = "Account already exists"; Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss" }
            $Skipped++
            continue
        }

        $SecurePassword = ConvertTo-SecureString $User.Password -AsPlainText -Force
        New-ADUser -SamAccountName $Username -UserPrincipalName "$Username@$UpnSuffix" -Name "$($User.Firstname) $($User.Lastname)" -GivenName $User.Firstname -Surname $User.Lastname -Enabled $true -Path $User.OU -AccountPassword $SecurePassword -ChangePasswordAtLogon $true -ErrorAction Stop
        Write-ToolkitAudit -Action "Bulk User Create" -Target $Username -Result "Success" -Detail "OU=$($User.OU)" -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep
        $Results += [PSCustomObject]@{ Username = $Username; Status = "Created"; Detail = "OU=$($User.OU)"; Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss" }
        $Created++
    } catch {
        $ErrorMsg = $_.Exception.Message
        "[$(Get-Date)] [Bulk Import Account Processing] Failed for '$Username'. Detail: $ErrorMsg" | Out-File $ErrorLog -Append
        Write-ToolkitAudit -Action "Bulk User Create" -Target $Username -Result "Failed" -Detail $ErrorMsg -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep
        $Results += [PSCustomObject]@{ Username = $Username; Status = "Failed"; Detail = $ErrorMsg; Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss" }
        $Failed++

        # Trigger Email Notification Linkage
        & "$PSScriptRoot\SendAlert.ps1" -ScriptName "Bulk CSV User Import ($Username)" -ErrorMessage $ErrorMsg -ErrorLog $ErrorLog
    }
}

# Write a per-run report CSV alongside the log directory so there's a paper trail per import.
$LogDir = Split-Path $ErrorLog -Parent
$ReportPath = Join-Path $LogDir ("Import_Report_{0}.csv" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
$Results | Export-Csv -Path $ReportPath -NoTypeInformation

Write-Host ""
Write-Host "Import complete: $Created created, $Skipped skipped (already existed), $Failed failed." -ForegroundColor Cyan
Write-Host "Per-user report written to: $ReportPath" -ForegroundColor Cyan
"[$(Get-Date)] [Bulk Import Engine] Run complete: $Created created, $Skipped skipped, $Failed failed. Source: $CSVPath. Report: $ReportPath" | Out-File $ErrorLog -Append
Read-Host "Press Enter to return to menu..."
