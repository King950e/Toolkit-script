# Target Path: ...\Toolkit_Files\OffboardUsers.ps1
# Offboards AD user(s): disables the account, strips group memberships, moves it to a
# holding OU, and stamps a description. Works two ways:
#   - Leave -CSVPath blank / answer blank at the prompt -> offboard a single user interactively.
#   - Supply a CSV (column: Username, optional column: Reason) -> bulk offboard.
# This is the reverse counterpart of AddUsers.ps1 / AddSingleUser.ps1.
param (
    [string]$ErrorLog = "$env:USERPROFILE\Desktop\IT_Toolkit_Logs\Toolkit_Errors.txt",
    [string]$CSVPath,
    [string]$TargetOU
)

. "$PSScriptRoot\ToolkitCommon.ps1"
$Config = Get-ToolkitConfig
Invoke-LogRotation -LogPath $ErrorLog -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep

Import-Module ActiveDirectory

if ([string]::IsNullOrWhiteSpace($TargetOU)) { $TargetOU = $Config.OffboardOU }
if ([string]::IsNullOrWhiteSpace($TargetOU)) {
    $TargetOU = Read-Host "Enter the Distinguished Name of the OU to move offboarded accounts into (e.g. OU=Disabled Users,DC=xmail,DC=dixietech,DC=edu)"
}
if ([string]::IsNullOrWhiteSpace($TargetOU) -or -not (Get-ADOrganizationalUnit -Identity $TargetOU -ErrorAction SilentlyContinue)) {
    Write-Host "Error: '$TargetOU' is not a valid, reachable OU. Aborting — nothing was changed." -ForegroundColor Red
    Read-Host "Press Enter to return to menu..."
    exit
}

function Invoke-OffboardSingleUser {
    param([string]$Username, [string]$Reason)

    $AdUser = Get-ADUser -Identity $Username -Properties MemberOf, DistinguishedName -ErrorAction SilentlyContinue
    if (-not $AdUser) {
        "[$(Get-Date)] [Offboarding] Skipped '$Username' — account not found." | Out-File $ErrorLog -Append
        Write-ToolkitAudit -Action "Offboard User" -Target $Username -Result "Skipped" -Detail "Account not found" -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep
        return [PSCustomObject]@{ Username = $Username; Status = "Skipped"; Detail = "Account not found" }
    }

    try {
        # 1. Disable the account
        Disable-ADAccount -Identity $Username -ErrorAction Stop

        # 2. Strip group memberships (best-effort per group; protected/primary groups are skipped, not fatal)
        $RemovedGroups = @()
        $FailedGroups = @()
        foreach ($GroupDN in $AdUser.MemberOf) {
            try {
                Remove-ADGroupMember -Identity $GroupDN -Members $Username -Confirm:$false -ErrorAction Stop
                $RemovedGroups += $GroupDN
            } catch {
                $FailedGroups += $GroupDN
            }
        }

        # 3. Move to the holding OU
        Move-ADObject -Identity $AdUser.DistinguishedName -TargetPath $TargetOU -ErrorAction Stop

        # 4. Stamp a description with the offboard date/reason
        $Stamp = "Offboarded $(Get-Date -Format 'yyyy-MM-dd') by $env:USERNAME" + $(if ($Reason) { " — $Reason" } else { "" })
        Set-ADUser -Identity $Username -Description $Stamp -ErrorAction SilentlyContinue

        $Detail = "Groups removed: $($RemovedGroups.Count); groups skipped: $($FailedGroups.Count); moved to $TargetOU"
        Write-ToolkitAudit -Action "Offboard User" -Target $Username -Result "Success" -Detail $Detail -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep
        return [PSCustomObject]@{ Username = $Username; Status = "Offboarded"; Detail = $Detail }
    } catch {
        $ErrorMsg = $_.Exception.Message
        "[$(Get-Date)] [Offboarding] Failed for '$Username'. Detail: $ErrorMsg" | Out-File $ErrorLog -Append
        Write-ToolkitAudit -Action "Offboard User" -Target $Username -Result "Failed" -Detail $ErrorMsg -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep
        & "$PSScriptRoot\SendAlert.ps1" -ScriptName "Offboard User ($Username)" -ErrorMessage $ErrorMsg -ErrorLog $ErrorLog
        return [PSCustomObject]@{ Username = $Username; Status = "Failed"; Detail = $ErrorMsg }
    }
}

$Results = @()

if ([string]::IsNullOrWhiteSpace($CSVPath)) {
    $CSVPath = Read-Host "Enter full path to a CSV for bulk offboarding, or leave blank to offboard a single user"
}

if ([string]::IsNullOrWhiteSpace($CSVPath)) {
    # Single-user interactive mode
    $Username = Read-Host "Enter the AD Username to offboard"
    $Reason = Read-Host "Reason (optional, press Enter to skip)"
    Write-Host ""
    Write-Host "About to disable, un-group, and move '$Username' to '$TargetOU'." -ForegroundColor Yellow
    $Confirm = Read-Host "Type YES to continue"
    if ($Confirm -ne "YES") {
        Write-Host "Cancelled — no changes made." -ForegroundColor Yellow
        Read-Host "Press Enter to return to menu..."
        exit
    }
    $Results += Invoke-OffboardSingleUser -Username $Username -Reason $Reason
} else {
    # Bulk CSV mode
    if (-not (Test-Path $CSVPath)) {
        "[$(Get-Date)] [Offboarding Engine] CRITICAL: CSV not found at $CSVPath" | Out-File $ErrorLog -Append
        Write-Error "CSV file was not found at $CSVPath"
        Read-Host "Press Enter to return to menu..."
        exit
    }
    $Rows = Import-Csv -Path $CSVPath
    Write-Host ""
    Write-Host "About to offboard $($Rows.Count) account(s) from '$CSVPath' into '$TargetOU'." -ForegroundColor Yellow
    $Confirm = Read-Host "Type YES to continue"
    if ($Confirm -ne "YES") {
        Write-Host "Cancelled — no changes made." -ForegroundColor Yellow
        Read-Host "Press Enter to return to menu..."
        exit
    }
    foreach ($Row in $Rows) {
        $Results += Invoke-OffboardSingleUser -Username $Row.Username -Reason $Row.Reason
    }
}

# Write a per-run report CSV, same pattern as AddUsers.ps1
$LogDir = Split-Path $ErrorLog -Parent
$ReportPath = Join-Path $LogDir ("Offboard_Report_{0}.csv" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
$Results | Export-Csv -Path $ReportPath -NoTypeInformation

$OffboardedCount = ($Results | Where-Object { $_.Status -eq "Offboarded" }).Count
$SkippedCount = ($Results | Where-Object { $_.Status -eq "Skipped" }).Count
$FailedCount = ($Results | Where-Object { $_.Status -eq "Failed" }).Count

Write-Host ""
Write-Host "Offboarding complete: $OffboardedCount offboarded, $SkippedCount skipped, $FailedCount failed." -ForegroundColor Cyan
Write-Host "Per-user report written to: $ReportPath" -ForegroundColor Cyan
Read-Host "Press Enter to return to menu..."
