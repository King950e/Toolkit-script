# Target Path: ...\Toolkit_Files\BackupAD.ps1
param (
    [string]$ErrorLog = "$env:USERPROFILE\Desktop\IT_Toolkit_Logs\Toolkit_Errors.txt"
)

. "$PSScriptRoot\ToolkitCommon.ps1"
$Config = Get-ToolkitConfig
Invoke-LogRotation -LogPath $ErrorLog -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep

# Minimum free space required for a typical AD System State backup (in Bytes)
# 20 GB = 20 * 1024 * 1024 * 1024
$MinRequiredSpace = 21474836480

# 1. Dependency Check: Verify Windows Server Backup features are available
if (-not (Get-Command Start-WBBackup -ErrorAction SilentlyContinue)) {
    try {
        Write-Host "Windows Server Backup feature is missing. Attempting install..." -ForegroundColor Yellow
        Install-WindowsFeature Windows-Server-Backup -IncludeAllSubFeature -ErrorAction Stop
        Write-Host "Feature installed successfully." -ForegroundColor Green
    } catch {
        "[$(Get-Date)] [AD Backup] CRITICAL: Windows Server Backup feature is not installed and failed to auto-install. $_" | Out-File $ErrorLog -Append
        Write-Error "Windows Server Backup toolset is missing on this machine."
        Read-Host "Press Enter to exit"
        Exit
    }
}

# 2. Setup Graphical GUI Components
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "              ACTIVE DIRECTORY SYSTEM STATE BACKUP" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "WARNING: Windows Server Backup cannot save to the local OS drive (C:)." -ForegroundColor Yellow
Write-Host "You must choose a dedicated disk partition or a network share." -ForegroundColor Yellow
Write-Host ""

$BackupTargetDrive = ""
$IsValidTarget = $false

# Loop until a valid destination with enough space is provided
do {
    Write-Host "Choose your input type:" -ForegroundColor White
    Write-Host " [1] Use Graphical Folder Browser Window" -ForegroundColor White
    Write-Host " [2] Type path manually (Best for Network Shares)" -ForegroundColor White
    $Method = Read-Host "Select an option (1 or 2)"

    if ($Method -eq "1") {
        # Launch graphical Folder Browser GUI
        Write-Host "Opening folder browser..." -ForegroundColor Cyan
        $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $FolderBrowser.Description = "Select AD Backup Destination (DO NOT Choose C: Drive)"
        $FolderBrowser.ShowNewFolderButton = $true

        $Result = $FolderBrowser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost=$true}))

        if ($Result -eq [System.Windows.Forms.DialogResult]::OK) {
            $BackupTargetDrive = $FolderBrowser.SelectedPath
        } else {
            Write-Host "Folder selection cancelled by user." -ForegroundColor Yellow
            continue
        }
    } else {
        # Manual text input
        $BackupTargetDrive = Read-Host "Enter target location (e.g., E: or \\Server\Share)"
    }

    # Clean up user strings
    if (-not [string]::IsNullOrWhiteSpace($BackupTargetDrive)) {
        $BackupTargetDrive = $BackupTargetDrive.Trim()
    }

    # Validation Checks
    if ([string]::IsNullOrWhiteSpace($BackupTargetDrive)) {
        Write-Host "Destination path cannot be empty!" -ForegroundColor Red
        continue
    }

    if ($BackupTargetDrive.StartsWith("C:", [System.StringComparison]::OrdinalIgnoreCase)) {
        Write-Host "Invalid destination! You cannot back up to the C: drive." -ForegroundColor Red
        continue
    }

    # 3. Space Check Engine
    try {
        $FreeBytes = 0
        if ($BackupTargetDrive.StartsWith("\\")) {
            # Network Share Space Calculation
            $ScriptBlock = {
                param($Path)
                $Target = Get-Item $Path -ErrorAction Stop
                $Target.Target # Resolves links if necessary
                $Dir = New-Object System.IO.DirectoryInfo($Path)
                # Invoking win32 API via Scripting API to safely inspect UNC volume space
                $FSO = New-Object -ComObject Scripting.FileSystemObject
                return $FSO.GetFolder($Path).FreeSpace
            }
            $FreeBytes = &$ScriptBlock -Path $BackupTargetDrive
        } else {
            # Local Partition Space Calculation
            $DriveLetter = [System.IO.Path]::GetPathRoot($BackupTargetDrive).Replace("\","")
            $Disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$DriveLetter'" -ErrorAction Stop
            $FreeBytes = $Disk.FreeSpace
        }

        # Human-readable formatting calculations
        $FreeGB = [math]::Round($FreeBytes / 1GB, 2)
        $ReqGB = [math]::Round($MinRequiredSpace / 1GB, 2)

        if ($FreeBytes -lt $MinRequiredSpace) {
            Write-Host "CRITICAL ERROR: Insufficient space on target location ($BackupTargetDrive)!" -ForegroundColor Red
            Write-Host "Available: $FreeGB GB | Required: At least $ReqGB GB" -ForegroundColor Red
            Write-Host "Please pick a different storage area." -ForegroundColor Yellow
            Write-Host ""
        } else {
            Write-Host "Space check passed! Destination has $FreeGB GB free space available." -ForegroundColor Green
            $IsValidTarget = $true
        }
    } catch {
        Write-Host "Unable to check directory properties or read free space on: $BackupTargetDrive" -ForegroundColor Red
        Write-Host "Verify the location path string format and administrative permissions." -ForegroundColor Yellow
        "[$(Get-Date)] [AD Backup] Target path unreadable or inaccessible: $BackupTargetDrive" | Out-File $ErrorLog -Append
    }

} while (-not $IsValidTarget)


# 4. Initialize Active Directory System State Backup Policy Execution
$BackupPolicy = New-WBPolicy

try {
    Write-Host "`nInitializing Active Directory System State Backup Policy..." -ForegroundColor Cyan

    # Enable System State (Active Directory Database, Sysvol, Registry)
    Add-WBSystemState $BackupPolicy

    # Establish Target Storage (Check if path is a Network Share or a Local Drive Volume)
    if ($BackupTargetDrive.StartsWith("\\")) {
        Write-Host "Configuring backup destination as Network Share..." -ForegroundColor Cyan
        $BackupTarget = New-WBBackupTarget -NetworkPath $BackupTargetDrive
    } else {
        Write-Host "Configuring backup destination as Drive Volume..." -ForegroundColor Cyan
        # Strips trailing paths to deliver pure root path if needed by system parameters
        $RootDrive = [System.IO.Path]::GetPathRoot($BackupTargetDrive)
        if ($RootDrive.EndsWith("\") -and $RootDrive.Length -gt 3) { $RootDrive = $RootDrive.TrimEnd("\") }
        $BackupTarget = New-WBBackupTarget -VolumePath $RootDrive
    }

    Add-WBBackupTarget -Policy $BackupPolicy -Target $BackupTarget

    Write-Host "Starting System State Backup to target: $BackupTargetDrive..." -ForegroundColor Yellow
    Write-Host "Note: This process can take several minutes to complete." -ForegroundColor Yellow

    # Run the backup job synchronously
    Start-WBBackup -Policy $BackupPolicy -ErrorAction Stop

    Write-Host "Active Directory backup completed successfully!" -ForegroundColor Green
    Write-ToolkitAudit -Action "AD System State Backup" -Target $BackupTargetDrive -Result "Success" -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep

} catch {
    $ErrorMsg = $_.Exception.Message
    "[$(Get-Date)] [AD Backup Suite] Critical backup task failed. Detail: $ErrorMsg" | Out-File $ErrorLog -Append
    Write-ToolkitAudit -Action "AD System State Backup" -Target $BackupTargetDrive -Result "Failed" -Detail $ErrorMsg -MaxBytes $Config.LogRotateMaxBytes -KeepCount $Config.LogRotateKeep

    # Trigger Email Notification Linkage
    if (Test-Path "$PSScriptRoot\SendAlert.ps1") {
        & "$PSScriptRoot\SendAlert.ps1" -ScriptName "Active Directory Nightly Backup" -ErrorMessage $ErrorMsg -ErrorLog $ErrorLog
    }

    Write-Error "The backup engine encountered a failure structure: $ErrorMsg"
}

Read-Host "Press Enter to return to menu..."
