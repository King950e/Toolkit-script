# Target Path: ...\Toolkit_Files\ConfigureEmail.ps1
$ConfigPath = "$PSScriptRoot\MailConfig.xml"
$AdminEmailPath = "$PSScriptRoot\MailConfig.AdminEmail.txt"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "              IT TOOLKIT - ALERT EMAIL CONFIGURATION" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "IMPORTANT: run this script under the SAME Windows account that will" -ForegroundColor Yellow
Write-Host "actually send the alerts. The credential below is encrypted for the" -ForegroundColor Yellow
Write-Host "account running THIS script right now and cannot be read by a" -ForegroundColor Yellow
Write-Host "different account (including the SYSTEM account a scheduled task" -ForegroundColor Yellow
Write-Host "normally runs as). If you schedule the nightly AD backup to run as" -ForegroundColor Yellow
Write-Host "SYSTEM, either re-run this script once as SYSTEM (e.g. via" -ForegroundColor Yellow
Write-Host "'schtasks /run' or PsExec -s) or schedule the backup task under the" -ForegroundColor Yellow
Write-Host "same account you use here." -ForegroundColor Yellow
Write-Host ""

# Prompt securely via Windows standard credentials UI box
$Credential = Get-Credential -UserName "SMTP_User_Or_Email" -Message "Enter SMTP Email Username and Password/App Password"

if (-not $Credential) {
    Write-Host "Cancelled — no credential was entered. Nothing was saved." -ForegroundColor Red
    Read-Host "Press Enter to return..."
    exit
}

$AdminEmail = Read-Host "Enter the destination email address that should receive alerts"
if ([string]::IsNullOrWhiteSpace($AdminEmail)) {
    Write-Host "No destination address entered. Nothing was saved." -ForegroundColor Red
    Read-Host "Press Enter to return..."
    exit
}

# Securely serialize the credential object using machine-level account keys
$Credential | Export-Clixml -Path $ConfigPath
$AdminEmail.Trim() | Out-File -FilePath $AdminEmailPath -Encoding utf8 -NoNewline

Write-Host "Email engine configuration saved successfully!" -ForegroundColor Green
Write-Host "Alerts will be sent to: $AdminEmail" -ForegroundColor Green
Read-Host "Press Enter to return..."
