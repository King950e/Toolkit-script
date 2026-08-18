@echo off

@REM **by:Pcantu
@echo made by Pcantu 06/1/2026
title IT Toolkit Master Suite (Universal Error Catching)
color 0A

:: Initialize Central Error Log Directory and File
set "LogDir=%USERPROFILE%\Desktop\IT_Toolkit_Logs"
if not exist "%LogDir%" mkdir "%LogDir%"
set "ErrorLog=%LogDir%\Toolkit_Errors.txt"

:: Set up Portable Internal Resource Folder Location Check
set "ScriptDir=%~dp0Toolkit_Files"
if not exist "%ScriptDir%" mkdir "%ScriptDir%"

:menu
cls
echo ======================================================
echo            IT TOOLKIT MASTER SUITE v3.1
echo ======================================================
echo  [--- BASIC ENDPOINT UTILITIES ---]
echo  1. Advance Network Toolkit      2. Windows Security Toolkit
echo  6. Windows Health Check         11. PC Performance Booster
echo  12. Laptop Battery Test         13. RAM Info Tool
echo ------------------------------------------------------
echo  [--- ACTIVE DIRECTORY / ENTERPRISE ---]
echo  3. Active Directory Sub-Menu    5. AD Bulk Multi-Add Users
echo  7. Elevate Domain Admin Account 8. Create AD User Account
echo  9. Join Workstation to Domain   10. Dissociate/Leave Domain
echo  14. AD System State Backup      27. Offboard/Disable AD User(s)
echo ------------------------------------------------------
echo  [--- ADVANCED DEPLOYMENT / LOGISTICS ---]
echo  4. Storage/Sanitize Disk        20. Clear Event Logs
echo  21. Select Apps to Install (Winget) 22. Backup System Drivers
echo  23. Run Hardware Asset Audit    24. Targeted Volume Backup
echo ------------------------------------------------------
echo  [--- DIAGNOSTIC DATA AND MAINTENANCE ---]
echo  15. Configure Alert Mail Engine 16. View Active Error Traces
echo  17. Flush Error Log History     18. Live Net Dashboard
echo  19. Live Security Fail Records  25. Send Test Alert Email
echo  28. EXIT MASTER SUITE
echo ======================================================

set "choice="
set /p choice="Enter Option (1-28): "

if "%choice%"=="1" goto Advance_Network_Toolkit
if "%choice%"=="2" goto Windows_Security_Toolkit
if "%choice%"=="3" goto Active_Directory_Toolkit
if "%choice%"=="4" goto Storage_Toolkit
if "%choice%"=="5" goto AD_Multi_Add_Users
if "%choice%"=="6" goto Windows_Health_Check_Toolkit
if "%choice%"=="7" goto Add_New_Admin_to_The_AD
if "%choice%"=="8" goto Add_Users_to_The_AD
if "%choice%"=="9" goto Join_Domain
if "%choice%"=="10" goto Leave_Domain
if "%choice%"=="11" goto PC_Performance_Booster
if "%choice%"=="12" goto Laptop_Battery_Test
if "%choice%"=="13" goto RAM_Info_Tool
if "%choice%"=="14" goto AD_Backup
if "%choice%"=="15" goto Setup_Email
if "%choice%"=="16" goto View_Error_Log
if "%choice%"=="17" if exist "%ErrorLog%" (del /q "%ErrorLog%" & echo Log cleared! & pause & goto menu) else (echo No log found to wipe. & pause & goto menu)
if "%choice%"=="18" goto Live_Network_Dashboard
if "%choice%"=="19" goto Live_Security_Dashboard
if "%choice%"=="20" goto Purge_Logs
if "%choice%"=="21" goto Winget_Deploy
if "%choice%"=="22" goto Driver_Export
if "%choice%"=="23" goto Asset_Audit
if "%choice%"=="24" goto Targeted_Backup
if "%choice%"=="25" goto Send_Test_Alert
if "%choice%"=="27" goto Offboard_Users
if "%choice%"=="28" goto exit

echo Invalid choice, try again.
pause
goto menu

:Advance_Network_Toolkit
cls
echo ======================================================================
echo                       ADVANCED NETWORK TOOLKIT
echo ======================================================================
echo  [--- CORE PROTOCOL INTERACTION ---]
echo   1. Show Full IP Configuration       2. Ping Google
echo   3. Flush DNS Cache                  4. Release IP Address
echo   5. Renew IP Address                 6. Reset Winsock Layer
echo   7. Reset TCP/IP Stack              12. Speed Test Ping (10 Packets)
echo   27. View All Active Connections     35. Show Wi-Fi Profiles
echo  ----------------------------------------------------------------------
echo  [--- CONTROL CONSOLS AND MANAGEMENT CPLs ---]
echo   8. Open Network Connections         9. Open WiFi Settings
echo   10. Open Device Manager             11. Launch Network Troubleshooter
echo   14. View Network Shared Folders     15. Internet Properties (Security)
echo   20. System Configuration (MSConfig) 21. Registry Editor (Regedit)
echo   22. Disk Manager Console            24. Programs and Features cpl
echo   25. Local Users and Groups          26. Remote Desktop Connection
echo   30. System Properties Panel
echo  ----------------------------------------------------------------------
echo  [--- DIAGNOSTICS AND DISK MAINTENANCE ---]
echo   16. DISM Check Health Component     17. DISM Scan Health Component
echo   18. DISM Restore Health Component   19. Run System File Checker (SFC)
echo   31. Disk Cleanup Utility
echo  ----------------------------------------------------------------------
echo  [--- UTILITIES AND POWER STATE CONTROLS ---]
echo   13. Restart Windows Explorer        23. Open App Data Folder
echo   28. Clean Volatile Temp Files       29. List All Installed Programs
echo   32. Launch Windows Task Manager     33. Shutdown Computer NOW
echo   34. Star Wars ASCII Stream (FUN)    36. GO BACK TO MAIN MENU
echo ======================================================================
echo.

set "net_choice="
set /p net_choice="Enter Option (1-36): "

if "%net_choice%"=="1" (ipconfig /all 2>>"%ErrorLog%" & pause & goto Advance_Network_Toolkit)
if "%net_choice%"=="2" (ping google.com 2>>"%ErrorLog%" & pause & goto Advance_Network_Toolkit)
if "%net_choice%"=="3" (ipconfig /flushdns 2>>"%ErrorLog%" & pause & goto Advance_Network_Toolkit)
if "%net_choice%"=="4" (ipconfig /release 2>>"%ErrorLog%" & pause & goto Advance_Network_Toolkit)
if "%net_choice%"=="5" (ipconfig /renew 2>>"%ErrorLog%" & pause & goto Advance_Network_Toolkit)
if "%net_choice%"=="6" (netsh winsock reset 2>>"%ErrorLog%" & pause & goto Advance_Network_Toolkit)
if "%net_choice%"=="7" (netsh int ip reset 2>>"%ErrorLog%" & pause & goto Advance_Network_Toolkit)
if "%net_choice%"=="8" (start "" ncpa.cpl & goto Advance_Network_Toolkit)
if "%net_choice%"=="9" (start "" ms-settings:network-wifi & goto Advance_Network_Toolkit)
if "%net_choice%"=="10" (start "" devmgmt.msc & goto Advance_Network_Toolkit)
if "%net_choice%"=="11" (start "" msdt.exe /id NetworkDiagnosticsNetworkAdapter & goto Advance_Network_Toolkit)
if "%net_choice%"=="12" (ping 8.8.8.8 -n 10 & pause & goto Advance_Network_Toolkit)
if "%net_choice%"=="13" (taskkill /f /im explorer.exe 2>>"%ErrorLog%" & start explorer.exe & goto Advance_Network_Toolkit)
if "%net_choice%"=="14" (start "" shrpubw & goto Advance_Network_Toolkit)
if "%net_choice%"=="15" (start "" inetcpl.cpl & goto Advance_Network_Toolkit)
if "%net_choice%"=="16" (DISM /Online /Cleanup-image /CheckHealth 2>>"%ErrorLog%" & pause & goto Advance_Network_Toolkit)
if "%net_choice%"=="17" (DISM /Online /Cleanup-image /ScanHealth 2>>"%ErrorLog%" & pause & goto Advance_Network_Toolkit)
if "%net_choice%"=="18" (DISM /Online /Cleanup-image /RestoreHealth 2>>"%ErrorLog%" & pause & goto Advance_Network_Toolkit)
if "%net_choice%"=="19" (sfc /scannow 2>>"%ErrorLog%" & pause & goto Advance_Network_Toolkit)
if "%net_choice%"=="20" (start "" msconfig & goto Advance_Network_Toolkit)
if "%net_choice%"=="21" (start "" regedit & goto Advance_Network_Toolkit)
if "%net_choice%"=="22" (start "" diskmgmt.msc & goto Advance_Network_Toolkit)
if "%net_choice%"=="23" (start "" "%appdata%" & goto Advance_Network_Toolkit)
if "%net_choice%"=="24" (start "" appwiz.cpl & goto Advance_Network_Toolkit)
if "%net_choice%"=="25" (start "" lusrmgr.msc & goto Advance_Network_Toolkit)
if "%net_choice%"=="26" (start "" mstsc & goto Advance_Network_Toolkit)
if "%net_choice%"=="27" (netstat -an 2>>"%ErrorLog%" & pause & goto Advance_Network_Toolkit)
if "%net_choice%"=="28" (del /q /f /s "%TEMP%\*" 2>>"%ErrorLog%" & echo Temp files purged. & pause & goto Advance_Network_Toolkit)
if "%net_choice%"=="29" (powershell -NoProfile -Command "Get-CimInstance Win32_Product | Select-Object Name, Version" 2>>"%ErrorLog%" & pause & goto Advance_Network_Toolkit)
if "%net_choice%"=="30" (start "" sysdm.cpl & goto Advance_Network_Toolkit)
if "%net_choice%"=="31" (start "" cleanmgr & goto Advance_Network_Toolkit)
if "%net_choice%"=="32" (start "" taskmgr & goto Advance_Network_Toolkit)
if "%net_choice%"=="33" (shutdown /s /t 0)
if "%net_choice%"=="34" (curl ASCII.live/can-you-hear-me & pause & goto Advance_Network_Toolkit)
if "%net_choice%"=="35" (netsh wlan show profiles 2>>"%ErrorLog%" & pause & goto Advance_Network_Toolkit)
if "%net_choice%"=="36" goto menu

echo Invalid choice, try again.
pause
goto Advance_Network_Toolkit

:Windows_Security_Toolkit
cls
echo ======================================================================
echo                       WINDOWS SECURITY TOOLKIT
echo ======================================================================
echo   1. Open Windows Defender            2. Open Firewall Settings
echo   3. Open TPM Management              4. Open System Protection
echo   5. Run Quick Defender Scan          6. Manage User Accounts (Netplwiz)
echo   7. Advanced Firewall (WF.msc)       8. Local Security Policy (Secpol)
echo   9. Windows Security Center          10. Malicious Software Removal (MRT)
echo  ----------------------------------------------------------------------
echo  [--- LIVE AUDITING AND AGENT COMMANDS ---]
echo  11. View Firewall Profiles Status   12. Block All Incoming Connections
echo  13. Turn Windows Firewall ON (All)  14. Open Performance Event Viewer
echo  15. Launch Registry (Regedit)       16. Local Users and Groups Management
echo  17. Open Reliability Monitor       18. GO BACK TO MAIN MENU
echo ======================================================================
echo.

set "sec_choice="
set /p sec_choice="Enter Option (1-18): "

if "%sec_choice%"=="1" (start "" windowsdefender: & goto Windows_Security_Toolkit)
if "%sec_choice%"=="2" (start "" ms-settings:windowsdefender & goto Windows_Security_Toolkit)
if "%sec_choice%"=="3" (start "" tpm.msc & goto Windows_Security_Toolkit)
if "%sec_choice%"=="4" (start "" systempropertiesprotection & goto Windows_Security_Toolkit)
if "%sec_choice%"=="5" (start "" mpcmdrun.exe -Scan -ScanType 1 2>>"%ErrorLog%" & echo Scan started in background. & pause & goto Windows_Security_Toolkit)
if "%sec_choice%"=="6" (start "" netplwiz & goto Windows_Security_Toolkit)
if "%sec_choice%"=="7" (start "" wf.msc & goto Windows_Security_Toolkit)
if "%sec_choice%"=="8" (start "" secpol.msc & goto Windows_Security_Toolkit)
if "%sec_choice%"=="9" (start "" wscui.cpl & goto Windows_Security_Toolkit)
if "%sec_choice%"=="10" (start "" mrt & goto Windows_Security_Toolkit)
if "%sec_choice%"=="11" (netsh advfirewall show allprofiles state & pause & goto Windows_Security_Toolkit)
if "%sec_choice%"=="12" (netsh advfirewall set allprofiles firewallpolicy blockinbound,allowoutbound 2>>"%ErrorLog%" & echo Incoming traffic restricted. & pause & goto Windows_Security_Toolkit)
if "%sec_choice%"=="13" (netsh advfirewall set allprofiles state on 2>>"%ErrorLog%" & echo All firewalls enabled. & pause & goto Windows_Security_Toolkit)
if "%sec_choice%"=="14" (start "" eventvwr.msc & goto Windows_Security_Toolkit)
if "%sec_choice%"=="15" (start "" regedit & goto Windows_Security_Toolkit)
if "%sec_choice%"=="16" (start "" lusrmgr.msc & goto Windows_Security_Toolkit)
if "%sec_choice%"=="17" (start "" perfmon /rel & goto Windows_Security_Toolkit)
if "%sec_choice%"=="18" goto menu

pause
goto Windows_Security_Toolkit

:Active_Directory_Toolkit
cls
echo.
echo ===============================
echo   ACTIVE DIRECTORY TOOLKIT
echo ===============================
echo.
echo 1. Force Group Policy Update (Gpupdate)
echo 2. Active Directory Users and Computers
echo 3. Active Directory Admin Center
echo 4. Sites and Services
echo 5. Domains and Trusts
echo 6. Reset a User Password
echo 7. Go Back to Main Menu
echo ====================================
echo.

set "ad_choice="
set /p ad_choice="Enter Option (1-7): "

if "%ad_choice%"=="1" gpupdate /force 2>>"%ErrorLog%"
if "%ad_choice%"=="2" dsa.msc
if "%ad_choice%"=="3" dsac.exe
if "%ad_choice%"=="4" dssite.msc
if "%ad_choice%"=="5" domain.msc
if "%ad_choice%"=="6" goto AD_Reset_Password
if "%ad_choice%"=="7" goto menu

pause
goto Active_Directory_Toolkit


:AD_Reset_Password
cls
echo ======================================================
echo       ACTIVE DIRECTORY PASSWORD RESET WITH AUDITING
echo ======================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%ScriptDir%\ResetPassword.ps1" -ErrorLog "%ErrorLog%" -LogDir "%LogDir%" 2>>"%ErrorLog%"
echo.
pause
goto Active_Directory_Toolkit


:Storage_Toolkit
setlocal Enabledelayedexpansion
cls
echo.
echo ===============================
echo   STORAGE SANITIZE TOOLKIT
echo ===============================
echo.
echo WARNING: Option 1 completely formats target flash media to ExFAT!
echo.
echo 1. Standard Quick Sanitize Drive (ExFAT Primary)
echo 2. Launch GUI Disk Manager
echo 3. Go Back to Main Menu
echo ===============================
echo.
set "st_choice="
set /p st_choice="Enter Option (1-3): "

if "%st_choice%"=="1" (
    echo.
    echo Detecting connected physical storage arrays...
    echo --------------------------------------------------
    (echo list disk) > "%TEMP%\list_dp.txt"
    diskpart /s "%TEMP%\list_dp.txt"
    del /q "%TEMP%\list_dp.txt"
    echo.
    set "TargetDiskNum="
    set /p TargetDiskNum="ENTER DISK NUMBER TO WIPE COMPLETELY (e.g., 1 or 2): "

    if not defined TargetDiskNum (
        echo Error: Input validation empty. Action canceled.
        pause & endlocal & goto Storage_Toolkit
    )

    :: Safety check: refuse to touch the disk Windows itself is booted from
    set "OSDiskNum="
    for /f "usebackq delims=" %%N in (`powershell -NoProfile -Command "(Get-Partition -DriveLetter $env:SystemDrive.Substring(0,1)).DiskNumber" 2^>nul`) do set "OSDiskNum=%%N"

    if defined OSDiskNum (
        if "!TargetDiskNum!"=="!OSDiskNum!" (
            echo.
            echo [BLOCKED] Disk !TargetDiskNum! is the Windows system disk. Refusing to wipe it.
            pause & endlocal & goto Storage_Toolkit
        )
    ) else (
        echo.
        echo [WARNING] Could not automatically verify which disk is the system disk.
        echo Double-check "list disk" above very carefully before continuing.
    )

    echo.
    echo Wiping Target Disk !TargetDiskNum! in 5 seconds... Press CTRL+C to Abort!
    timeout /t 5

    (echo select disk !TargetDiskNum! & echo attributes disk clear readonly & echo clean & echo create partition primary & echo format fs=exfat quick & echo assign) > "%TEMP%\dp.txt"
    diskpart /s "%TEMP%\dp.txt" 2>>"%ErrorLog%"
    del /q "%TEMP%\dp.txt"
    echo.
    echo Formatting sequence completed successfully.
    pause
)
if "%st_choice%"=="2" start diskmgmt.msc
if "%st_choice%"=="3" (endlocal & goto menu)
endlocal & goto Storage_Toolkit


:AD_Multi_Add_Users
cls
echo.
echo --- Running Active Directory Bulk CSV Multi-Add Users ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%ScriptDir%\AddUsers.ps1" -ErrorLog "%ErrorLog%"
pause
goto menu

:Windows_Health_Check_Toolkit
cls
echo Running Core OS Validation Layer...
echo [1/4] Checking component health...
DISM /Online /Cleanup-Image /CheckHealth 2>>"%ErrorLog%"
echo [2/4] Scanning components...
DISM /Online /Cleanup-Image /ScanHealth 2>>"%ErrorLog%"
echo [3/4] Restoring component store...
DISM /Online /Cleanup-Image /RestoreHealth 2>>"%ErrorLog%"
echo [4/4] Verifying system file integrity...
sfc /scannow 2>>"%ErrorLog%"
pause & goto menu

:Add_New_Admin_to_The_AD
cls
echo.
echo --- Launching Domain Admin Account Elevation ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%ScriptDir%\AddAdmin.ps1" -ErrorLog "%ErrorLog%"
pause
goto menu

:Add_Users_to_The_AD
cls
echo.
echo --- Launching Single AD Account Provisioning ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%ScriptDir%\AddSingleUser.ps1" -ErrorLog "%ErrorLog%"
pause
goto menu

:Join_Domain
cls
echo.
echo --- Launching Join Domain Utility ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%ScriptDir%\JoinDomain.ps1" -ErrorLog "%ErrorLog%"
pause
goto menu

:Leave_Domain
cls
echo.
echo --- Launching Machine Dissociation / Leave Domain Utility ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%ScriptDir%\LeaveDomain.ps1" -ErrorLog "%ErrorLog%"
pause
goto menu

:Offboard_Users
cls
echo.
echo --- Launching AD User Offboarding Utility ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%ScriptDir%\OffboardUsers.ps1" -ErrorLog "%ErrorLog%"
pause
goto menu

:PC_Performance_Booster
cls
echo [TUNE] Initiating System Volatile Disk Optimizations...
powershell -NoProfile -Command "Disable-ScheduledTask -TaskName 'Consolidator' -TaskPath '\Microsoft\Windows\Customer Experience Improvement Program'" 2>>"%ErrorLog%"
del /f /s /q "%systemroot%\Prefetch\*" 2>>"%ErrorLog%"
echo Performance optimizations applied successfully.
pause & goto menu

:Laptop_Battery_Test
cls
echo Generating system battery diagnostic report...
powercfg /batteryreport /output "%LogDir%\BatteryReport.html" 2>>"%ErrorLog%"
start "" "%LogDir%\BatteryReport.html"
pause
goto menu

:RAM_Info_Tool
cls
echo Fetching physical motherboard hardware telemetry...
echo.
powershell -NoProfile -Command "Get-CimInstance Win32_PhysicalMemory | Select-Object Manufacturer, PartNumber, @{Name='Size(GB)';Expression={$_.Capacity/1GB}}, Speed"
echo.
pause & goto menu


:AD_Backup
cls
echo ======================================================
echo          ACTIVE DIRECTORY BACKUP / RECOVERY PANEL
echo ======================================================
echo 1. Run System State Backup Now
echo 2. Schedule Automated Nightly Backup (12:00 AM)
echo 3. EMERGENCY: Boot This Server into Safe Mode / DSRM
echo 4. EMERGENCY: Remove Safe Mode / Return to Normal Boot
echo 5. Go Back to Main Menu
echo ======================================================
echo.

set "bk_choice="
set /p bk_choice="Enter Option (1-5): "

if "%bk_choice%"=="1" (
    cls
    powershell -NoProfile -ExecutionPolicy Bypass -File "%ScriptDir%\BackupAD.ps1" -ErrorLog "%ErrorLog%"
    goto AD_Backup
)

if "%bk_choice%"=="2" (
    cls
    echo Creating Automated Windows Scheduled Task...
    echo NOTE: this task runs as SYSTEM. Failure-alert emails only work if you ran
    echo "Configure Alert Mail Engine" (option 15) once AS SYSTEM too - a normal
    echo interactive login cannot decrypt SYSTEM's saved mail credential, or vice versa.
    schtasks /create /tn "IT_Toolkit_AD_Nightly_Backup" /tr "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \""%ScriptDir%\BackupAD.ps1"\"" -ErrorLog \""%ErrorLog%"\"" /sc daily /st 00:00 /ru "SYSTEM" /rl HIGHEST /f 2>>"%ErrorLog%"
    if %errorlevel% equ 0 (
        echo.
        echo [SUCCESS] Nightly backup task successfully scheduled at 12:00 AM!
    ) else (
        echo.
        echo [ERROR] Failed to schedule task. Check your error log file for details.
    )
    pause
    goto AD_Backup
)

if "%bk_choice%"=="3" (
    cls
    echo ======================================================
    echo  WARNING: CRITICAL SYSTEM STATE CHANGE REQUESTED
    echo ======================================================
    echo This flag forces the bootloader into Safe Mode / DSRM.
    echo The server will restart automatically once confirmed.
    echo.
    echo Ensure you know your Local DSRM Administrator password!
    echo ======================================================
    set "DsrmConfirm="
    set /p DsrmConfirm="Type YES (all caps) to force this server into DSRM: "
    if /I not "%DsrmConfirm%"=="YES" (
        echo Cancelled - no changes made.
        pause & goto AD_Backup
    )

    echo Restarting into DSRM in 10 seconds... Press CTRL+C to Abort!
    bcdedit /set {current} safeboot dsrepair 2>>"%ErrorLog%"

    echo [%date% %time%] SYSTEM CRITICAL: Server forced into DSRM by Toolkit. >> "%ErrorLog%"
    shutdown /r /t 10 /c "IT Toolkit Suite: Active Directory Database Repair Boot Enforced"
    exit
)

if "%bk_choice%"=="4" (
    cls
    echo Clearing Safe Mode boot flags...
    bcdedit /deletevalue {current} safeboot 2>>"%ErrorLog%"
    echo.
    echo System boot profile restored to normal.
    echo If you are currently in DSRM, restart the server now to load normally.
    pause
    goto AD_Backup
)

if "%bk_choice%"=="5" goto menu
goto AD_Backup

:Setup_Email
cls
echo.
echo --- Launching Email Configuration Interface ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%ScriptDir%\ConfigureEmail.ps1"
goto menu

:Send_Test_Alert
cls
echo.
echo --- Launching Alert Engine Test ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%ScriptDir%\TestAlert.ps1" -ErrorLog "%ErrorLog%"
goto menu

:View_Error_Log
cls
if exist "%ErrorLog%" (
    start notepad "%ErrorLog%"
) else (
    echo [OK] No system errors recorded yet.
    pause
)
goto menu

:Live_Network_Dashboard
setlocal Enabledelayedexpansion
cls
echo =======================================================================
echo          LIVE NETWORK DASHBOARD
echo =======================================================================
echo.

echo [1] IP CONFIGURATION:
echo -----------------------------------------------------------------------
ipconfig | findstr /R /C:"IPv4 Address" /C:"Subnet Mask" /C:"Default Gateway"
echo.

echo [2] ACTIVE CONNECTIONS (ESTABLISHED):
echo -----------------------------------------------------------------------
netstat -no | findstr "ESTABLISHED" | findstr /V "127.0.0.1" | cmd /q /c "for /l %%i in (1,1,5) do (set /p line=& if not defined line (exit) else (call echo %%line%%))"
echo.

echo [3] PING STATUS (Gateway / DNS):
echo -----------------------------------------------------------------------
ping 1.1.1.1 -n 1 | findstr /I "Reply Minimum"
echo.

echo [4] WIRELESS INTERFACE SIGNAL STRENGTH
echo -----------------------------------------------------------------------
netsh wlan show interfaces | findstr /c:"Signal" >nul
if !errorlevel!==0 (
    for /f "tokens=2 delims=:" %%A in ('netsh wlan show interfaces ^| findstr /c:" SSID" /c:" Signal"') do (
        echo      Wireless Metric:%%A
    )
) else (
    echo      Wireless Metric      : Ethernet Connection Active (No WLAN Interface in use)
)

echo =======================================================================
echo [M] Main Menu    [R] Refresh Now    (Auto-refreshes in 5 seconds...)
echo =======================================================================
choice /c mr /t 5 /d r /n > nul
if %errorlevel%==1 (endlocal & goto menu)
if %errorlevel%==2 (endlocal & goto Live_Network_Dashboard)
endlocal & goto menu

:Live_Security_Dashboard
setlocal Enabledelayedexpansion
cls
echo =======================================================================
echo          LIVE SECURITY DASHBOARD
echo =======================================================================
echo.

echo FIREWALL STATUS:
echo -----------------------------------------------------------------------
netsh advfirewall show allprofiles state | findstr /I "State"
echo.

echo REMOTE ACCESS PORTS IN USE (RDP/SSH/SMB/FTP):
echo -----------------------------------------------------------------------
netstat -ano | findstr /R /C:":3389 " /C:":22 " /C:":445 " /C:":21 "
if errorlevel 1 echo No active default remote management ports detected.
echo.

echo SUSPICIOUS OR UNKNOWN OUTBOUND CONNECTIONS:
echo -----------------------------------------------------------------------
netstat -no | findstr "ESTABLISHED" | findstr /V "127.0.0.1" | cmd /q /c "for /l %%i in (1,1,5) do (set /p line=& if not defined line (exit) else (call echo %%line%%))"
echo.

echo RECENT SYSTEM ERRORS (Last 3 System Logs):
echo -----------------------------------------------------------------------
wevtutil qe System "/q:*[System[(Level=2)]]" /c:3 /rd:true /f:text | findstr /I /C:"Event ID:" /C:"Date:" /C:"Provider:" /C:"Description:"
if errorlevel 1 (
    echo Run as Administrator to view Live System Error Logs.
    goto SKIP_LOGGING
)

:: BACKGROUND LOGGING PROCESS
set "CURR_ID="
set "CURR_DATE="
for /f "tokens=1,2,*" %%A in ('wevtutil qe System "/q:*[System[(Level=2)]]" /c:1 /rd:true /f:text ^| findstr /I /C:"Event ID:" /C:"Date:"') do (
    if /I "%%A %%B"=="Event ID:" set "CURR_ID=%%C"
    if /I "%%A"=="Date:" set "CURR_DATE=%%B %%C"
)

if "!CURR_ID!"=="!LAST_LOG_ID!" (
    if "!CURR_DATE!"=="!LAST_LOG_DATE!" goto SKIP_LOGGING
)

if defined CURR_ID (
    echo -------------------------------------------------- >> "%LogDir%\system_errors_log.txt"
    echo NEW ERROR DETECTED ON %date% AT %time% >> "%LogDir%\system_errors_log.txt"
    wevtutil qe System "/q:*[System[(Level=2)]]" /c:1 /rd:true /f:text | findstr /I /C:"Event ID:" /C:"Date:" /C:"Provider:" /C:"Description:" >> "%LogDir%\system_errors_log.txt"

    set "LAST_LOG_ID=!CURR_ID!"
    set "LAST_LOG_DATE=!CURR_DATE!"
)

:SKIP_LOGGING
echo.
echo =======================================================================
echo Log File: %LogDir%\system_errors_log.txt (Updates in background)
echo [M] Main Menu    [R] Refresh Now    (Auto-refreshes in 5 seconds...)
echo =======================================================================
choice /c mr /t 5 /d r /n > nul
if %errorlevel%==1 (endlocal & goto menu)
if %errorlevel%==2 (
    endlocal
    set "LAST_LOG_ID=%LAST_LOG_ID%"
    set "LAST_LOG_DATE=%LAST_LOG_DATE%"
    goto Live_Security_Dashboard
)
endlocal & goto menu


:Winget_Deploy
cls
echo ======================================================
echo             WINGET APPLICATION INSTALLER
echo ======================================================
echo 1. Install Google Chrome
echo 2. Install Mozilla Firefox
echo 3. Install Notepad++
echo 4. Install Visual Studio Code
echo 5. Install 7-Zip Utility
echo 6. Install Git SCM Engine
echo 7. Install Sysinternals Suite
echo 8. Go Back to Main Menu
echo ======================================================
echo.
set "app_choice="
set /p app_choice="Select App to Deploy (1-8): "

set "AppID="
if "%app_choice%"=="1" set "AppID=Google.Chrome"
if "%app_choice%"=="2" set "AppID=Mozilla.Firefox"
if "%app_choice%"=="3" set "AppID=Notepad++.Notepad++"
if "%app_choice%"=="4" set "AppID=Microsoft.VisualStudioCode"
if "%app_choice%"=="5" set "AppID=7zip.7zip"
if "%app_choice%"=="6" set "AppID=Git.Git"
if "%app_choice%"=="7" set "AppID=Microsoft.SysinternalsSuite"
if "%app_choice%"=="8" goto menu

if "%AppID%"=="" (
    echo Invalid entry. Please pick a number from 1 to 8.
    pause & goto Winget_Deploy
)
echo [INSTALLING] Executing silent deployment for target %AppID%...
winget install --id %AppID% -e --silent --accept-package-agreements --accept-source-agreements 2>>"%ErrorLog%"
if %errorLevel% equ 0 (
    echo Installation successful!
) else (
    echo Deployment failed. Check error trace logs.
)
pause
goto Winget_Deploy

:Purge_Logs
cls
echo ======================================================
echo                CLEAR WINDOWS EVENT LOGS
echo ======================================================
echo WARNING: This clears Application, System, and Security
echo event logs. This action cannot be undone.
echo ======================================================
set "PurgeConfirm="
set /p PurgeConfirm="Type YES (all caps) to clear all Windows event logs: "
if /I not "%PurgeConfirm%"=="YES" (
    echo Cancelled - no logs were cleared.
    pause & goto menu
)
for /f "tokens=*" %%L in ('wevtutil el') do (
    wevtutil cl "%%L" 2>>"%ErrorLog%"
)
echo.
echo Event logs cleared.
pause & goto menu

:Driver_Export
cls
echo Exporting system driver packages to logs directory...
mkdir "%LogDir%\Driver_Backup" 2>nul
dism /online /export-driver /destination:"%LogDir%\Driver_Backup" 2>>"%ErrorLog%"
echo Device driver configurations backed up safely.
pause & goto menu

:Asset_Audit
cls
echo Building localized asset report...
(
echo ================= ASSET AUDIT REPORT =================
echo Computer Name: %COMPUTERNAME%
echo Timestamp:     %DATE% %TIME%
echo ======================================================
powershell -NoProfile -Command "Get-CimInstance Win32_Bios | Select-Object Manufacturer, SerialNumber, SMBIOSBIOSVersion"
powershell -NoProfile -Command "Get-CimInstance Win32_ComputerSystem | Select-Object Model, TotalPhysicalMemory"
) > "%LogDir%\Asset_Audit_%COMPUTERNAME%.txt"
echo Report compiled successfully to: %LogDir%\Asset_Audit_%COMPUTERNAME%.txt
echo.
type "%LogDir%\Asset_Audit_%COMPUTERNAME%.txt"
pause & goto menu

:Targeted_Backup
cls
echo ======================================================
echo             DYNAMIC STORAGE BACKUP ENGINE
echo ======================================================
echo.
echo Detecting currently mounted storage partitions...
powershell -NoProfile -Command "Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DriveType -eq 2 -or $_.DriveType -eq 3} | Select-Object DeviceID, VolumeName, @{Name='Free(GB)';Expression={'{0:N2}' -f ($_.FreeSpace/1GB)}}, @{Name='Size(GB)';Expression={'{0:N2}' -f ($_.Size/1GB)}}"
echo.

set "TargetDrive="
set /p TargetDrive="Enter the Target Drive Letter to save backup (e.g., E or F): "

:: Sanitize user text input to extract precisely the first letter character
set "TargetDrive=%TargetDrive:~0,1%"

:: Validation check to ensure the target partition directory handles successfully
if not exist "%TargetDrive%:\" (
    echo [ERROR] Selected volume %TargetDrive%: does not exist or is unallocated. >> "%ErrorLog%"
    echo Error: Target partition not accessible. Returning to system menu.
    pause & goto menu
)

echo.
echo Preparing high-speed mirror backup to %TargetDrive%:\IT_Toolkit_Backup ...
echo Syncing critical local profile structural datasets...
echo.

robocopy "%USERPROFILE%\Desktop" "%TargetDrive%:\IT_Toolkit_Backup\Desktop" /E /Z /ZB /R:3 /W:5 /MT:16 /XJ 2>>"%ErrorLog%"
robocopy "%USERPROFILE%\Documents" "%TargetDrive%:\IT_Toolkit_Backup\Documents" /E /Z /ZB /R:3 /W:5 /MT:16 /XJ 2>>"%ErrorLog%"
robocopy "%USERPROFILE%\Downloads" "%TargetDrive%:\IT_Toolkit_Backup\Downloads" /E /Z /ZB /R:3 /W:5 /MT:16 /XJ 2>>"%ErrorLog%"
robocopy "%USERPROFILE%\Pictures" "%TargetDrive%:\IT_Toolkit_Backup\Pictures" /E /Z /ZB /R:3 /W:5 /MT:16 /XJ 2>>"%ErrorLog%"
echo.
echo ======================================================
echo Multi-threaded data sync finished! Verify data blocks.
echo ======================================================
pause & goto menu

:exit
cls
echo IT Toolkit Master Suite execution terminated cleanly.
echo.
exit /b
