# Target Path: ...\Toolkit_Files\ToolkitCommon.ps1
# Shared helpers used by every other script in Toolkit_Files. Dot-source it:
#   . "$PSScriptRoot\ToolkitCommon.ps1"
# Provides: Get-ToolkitConfig, Write-ToolkitAudit, Invoke-LogRotation.

function Get-ToolkitConfig {
    param(
        [string]$ConfigPath = "$PSScriptRoot\ToolkitConfig.json"
    )

    $Defaults = [PSCustomObject]@{
        UpnSuffix         = "xmail.dixietech.edu"
        SmtpServer        = "smtp.gmail.com"
        SmtpPort          = 587
        LogRotateMaxBytes = 5242880   # 5 MB
        LogRotateKeep     = 5
        OffboardOU        = ""        # blank = script will prompt each run
    }

    if (-not (Test-Path $ConfigPath)) {
        $Defaults | ConvertTo-Json | Out-File -FilePath $ConfigPath -Encoding utf8
        return $Defaults
    }

    try {
        $Loaded = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
        # Backfill any keys an older config file might be missing so upgrades don't break.
        foreach ($prop in $Defaults.PSObject.Properties.Name) {
            if (-not ($Loaded.PSObject.Properties.Name -contains $prop)) {
                $Loaded | Add-Member -MemberType NoteProperty -Name $prop -Value $Defaults.$prop
            }
        }
        return $Loaded
    } catch {
        Write-Host "WARNING: ToolkitConfig.json could not be parsed ($_); using built-in defaults." -ForegroundColor Yellow
        return $Defaults
    }
}

function Invoke-LogRotation {
    param(
        [Parameter(Mandatory)] [string]$LogPath,
        [long]$MaxBytes = 5242880,
        [int]$KeepCount = 5
    )

    if (-not (Test-Path $LogPath)) { return }
    $LogFile = Get-Item $LogPath
    if ($LogFile.Length -lt $MaxBytes) { return }

    try {
        $Dir = Split-Path $LogPath -Parent
        $Base = [System.IO.Path]::GetFileNameWithoutExtension($LogPath)
        $Ext = [System.IO.Path]::GetExtension($LogPath)
        $Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $ArchiveName = "$Base`_$Stamp$Ext"

        Rename-Item -Path $LogPath -NewName $ArchiveName -Force

        # Keep only the newest $KeepCount archives for this log.
        Get-ChildItem -Path $Dir -Filter "$Base`_*$Ext" |
            Sort-Object LastWriteTime -Descending |
            Select-Object -Skip $KeepCount |
            Remove-Item -Force -ErrorAction SilentlyContinue
    } catch {
        # Rotation is best-effort (e.g. file locked by another process) — just keep appending.
    }
}

function Write-ToolkitAudit {
    param(
        [Parameter(Mandatory)] [string]$Action,
        [Parameter(Mandatory)] [string]$Target,
        [string]$Result = "Success",
        [string]$Detail = "",
        [string]$AuditLog = "$env:USERPROFILE\Desktop\IT_Toolkit_Logs\Toolkit_Audit.txt",
        [long]$MaxBytes = 5242880,
        [int]$KeepCount = 5
    )

    $LogDir = Split-Path $AuditLog -Parent
    if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
    Invoke-LogRotation -LogPath $AuditLog -MaxBytes $MaxBytes -KeepCount $KeepCount

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Who = "$env:USERNAME@$env:COMPUTERNAME"
    $Line = "[$Timestamp] $Who | Action=$Action | Target=$Target | Result=$Result"
    if ($Detail) { $Line += " | Detail=$Detail" }
    Add-Content -Path $AuditLog -Value $Line
}
