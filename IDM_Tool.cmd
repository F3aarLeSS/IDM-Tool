@echo off
setlocal DisableDelayedExpansion
title IDM Tool
color 0A

set "PATH=%SystemRoot%\System32;%SystemRoot%\System32\wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0\"
if exist "%SystemRoot%\Sysnative\reg.exe" set "PATH=%SystemRoot%\Sysnative;%PATH%"

set "_cmdf=%~f0"
for %%# in (%*) do if /i "%%#"=="r1" set r1=1
if exist %SystemRoot%\Sysnative\cmd.exe if not defined r1 (
    setlocal EnableDelayedExpansion
    start %SystemRoot%\Sysnative\cmd.exe /c ""!_cmdf!" %* r1"
    exit /b
)

fltmc 1>nul 2>nul || (
    echo.
    echo   Run this script as Administrator.
    echo   Right-click ^> Run as administrator
    echo.
    pause
    exit /b
)

for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PROCESSOR_ARCHITECTURE 2^>nul') do set arch=%%b
if /i not "%arch%"=="x86" set arch=x64

if "%arch%"=="x86" (
    set "CLSID=HKCU\Software\Classes\CLSID"
    set "HKLM_KEY=HKLM\Software\Internet Download Manager"
) else (
    set "CLSID=HKCU\Software\Classes\Wow6432Node\CLSID"
    set "HKLM_KEY=HKLM\SOFTWARE\Wow6432Node\Internet Download Manager"
)

set "IDMan="
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\DownloadManager" /v ExePath 2^>nul') do set "IDMan=%%b"
if not defined IDMan (
    if "%arch%"=="x64" set "IDMan=%ProgramFiles(x86)%\Internet Download Manager\IDMan.exe"
    if "%arch%"=="x86" set "IDMan=%ProgramFiles%\Internet Download Manager\IDMan.exe"
)

if not exist %SystemRoot%\Temp md %SystemRoot%\Temp
set psc=powershell.exe

set "idmInstalled=0"
if exist "%IDMan%" set "idmInstalled=1"

set "idmver=Unknown"
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\DownloadManager" /v idmvers 2^>nul') do set "idmver=%%b"

:Menu
cls
echo.
echo   +------------------------------------------------------+
echo   ^|                                                      ^|
echo   ^|            I D M   T O O L                           ^|
echo   ^|                                                      ^|
echo   +------------------------------------------------------+
echo.
echo   IDM Version : %idmver%
echo   Architecture: %arch%
echo.
echo   +------------------------------------------------------+
echo   ^|                                                      ^|
echo   ^|   [1]  Freeze Trial                                  ^|
echo   ^|        Lock 30-day trial forever                     ^|
echo   ^|                                                      ^|
echo   ^|   [2]  Reset Activation ^& Trial                      ^|
echo   ^|        Get fresh 30-day trial                        ^|
echo   ^|                                                      ^|
echo   ^|   [3]  Download IDM                                  ^|
echo   ^|        Open official download page                   ^|
echo   ^|                                                      ^|
echo   ^|   [0]  Exit                                          ^|
echo   ^|                                                      ^|
echo   +------------------------------------------------------+
echo.
set /p "choice=  Choose: "

if "%choice%"=="0" exit /b
if "%choice%"=="1" goto Freeze
if "%choice%"=="2" goto Reset
if "%choice%"=="3" goto Download
goto Menu

:: ====================== Download ======================
:Download
start https://www.internetdownloadmanager.com/download.html
echo.
echo   Opening browser...
timeout /t 2 >nul
goto Menu

:: ====================== Freeze ======================
:Freeze
cls
echo.
echo   +------------------------------------------------------+
echo   ^|  FREEZE TRIAL                                        ^|
echo   +------------------------------------------------------+
echo.
echo   Locks your 30-day trial permanently.
echo   Requires internet connection.
echo   IDM updates can be installed directly after.
echo.

if "%idmInstalled%"=="0" (
    echo   [!] IDM not installed. Download it first.
    echo.
    pause
    goto Menu
)

echo   IDM found: %IDMan%
set /p "go=  Continue? [Y/N]: "
if /i not "%go%"=="Y" goto Menu

echo.
echo   --- Step 1/5: Closing IDM ---
tasklist /fi "imagename eq idman.exe" 2>nul | findstr /i "idman.exe" >nul 2>&1
if %errorlevel%==0 (
    taskkill /f /im idman.exe >nul 2>&1
    echo   Done.
) else (
    echo   IDM not running.
)

echo.
echo   --- Step 2/5: Registry backup ---
set "_t="
for /f %%a in ('%psc% "(Get-Date).ToString('yyyyMMdd-HHmmssfff')"') do set "_t=%%a"
reg export "%CLSID%" "%SystemRoot%\Temp\_Bak_%_t%.reg" >nul 2>&1
echo   Saved: %SystemRoot%\Temp\_Bak_%_t%.reg

echo.
echo   --- Step 3/5: Cleaning registry ---
reg delete "HKCU\Software\DownloadManager" /v "FName" /f >nul 2>&1
reg delete "HKCU\Software\DownloadManager" /v "LName" /f >nul 2>&1
reg delete "HKCU\Software\DownloadManager" /v "Email" /f >nul 2>&1
reg delete "HKCU\Software\DownloadManager" /v "Serial" /f >nul 2>&1
reg delete "HKCU\Software\DownloadManager" /v "scansk" /f >nul 2>&1
reg delete "HKCU\Software\DownloadManager" /v "tvfrdt" /f >nul 2>&1
reg delete "HKCU\Software\DownloadManager" /v "radxcnt" /f >nul 2>&1
reg delete "HKCU\Software\DownloadManager" /v "LstCheck" /f >nul 2>&1
reg delete "HKCU\Software\DownloadManager" /v "ptrk_scdt" /f >nul 2>&1
reg delete "HKCU\Software\DownloadManager" /v "LastCheckQU" /f >nul 2>&1
reg delete "%HKLM_KEY%" /f >nul 2>&1
echo   Done.

echo.
echo   --- Step 4/5: Adding driver key ---
reg add "%HKLM_KEY%" /v "AdvIntDriverEnabled2" /t REG_DWORD /d "1" /f >nul 2>&1
echo   Done.

echo.
echo   --- Step 5/5: Locking CLSID keys ---
%psc% -NoProfile -Command "$sid = ([System.Security.Principal.NTAccount](Get-WmiObject Win32_ComputerSystem).UserName).Translate([System.Security.Principal.SecurityIdentifier]).Value; $HKCUsync = $null; $lockKey = 1; $deleteKey = $null; $toggle = 1; $f=[io.file]::ReadAllText('%~f0') -split ':regscan\:.*';iex ($f[1])"

echo.
echo   --- Triggering test downloads ---
set "tmpf=%SystemRoot%\Temp\temp.png"
if exist "%tmpf%" del /f /q "%tmpf%" >nul 2>&1
start "" /B "%IDMan%" /n /d "https://www.internetdownloadmanager.com/images/idm_box_min.png" /p "%SystemRoot%\Temp" /f temp.png
call :WaitFile

if exist "%tmpf%" del /f /q "%tmpf%" >nul 2>&1
start "" /B "%IDMan%" /n /d "https://www.internetdownloadmanager.com/pictures/idm_about.png" /p "%SystemRoot%\Temp" /f temp.png
call :WaitFile

timeout /t 3 >nul 2>&1
taskkill /f /im idman.exe >nul 2>&1
if exist "%tmpf%" del /f /q "%tmpf%" >nul 2>&1

echo.
echo   +------------------------------------------------------+
echo   ^|  DONE - Trial frozen for lifetime                    ^|
echo   +------------------------------------------------------+
echo.
pause
goto Menu

:: ====================== Reset ======================
:Reset
cls
echo.
echo   +------------------------------------------------------+
echo   ^|  RESET ACTIVATION ^& TRIAL                            ^|
echo   +------------------------------------------------------+
echo.
echo   Clears all activation and trial data.
echo   Gives you a fresh 30-day trial.
echo   Fixes fake serial key errors.
echo.

if "%idmInstalled%"=="0" (
    echo   [!] IDM not installed.
    echo.
    pause
    goto Menu
)

echo   IDM found: %IDMan%
set /p "go=  Continue? [Y/N]: "
if /i not "%go%"=="Y" goto Menu

echo.
echo   --- Step 1/4: Closing IDM ---
tasklist /fi "imagename eq idman.exe" 2>nul | findstr /i "idman.exe" >nul 2>&1
if %errorlevel%==0 (
    taskkill /f /im idman.exe >nul 2>&1
    echo   Done.
) else (
    echo   IDM not running.
)

echo.
echo   --- Step 2/4: Registry backup ---
set "_t="
for /f %%a in ('%psc% "(Get-Date).ToString('yyyyMMdd-HHmmssfff')"') do set "_t=%%a"
reg export "%CLSID%" "%SystemRoot%\Temp\_Bak_%_t%.reg" >nul 2>&1
echo   Saved: %SystemRoot%\Temp\_Bak_%_t%.reg

echo.
echo   --- Step 3/4: Cleaning registry ---
reg delete "HKCU\Software\DownloadManager" /v "FName" /f >nul 2>&1
reg delete "HKCU\Software\DownloadManager" /v "LName" /f >nul 2>&1
reg delete "HKCU\Software\DownloadManager" /v "Email" /f >nul 2>&1
reg delete "HKCU\Software\DownloadManager" /v "Serial" /f >nul 2>&1
reg delete "HKCU\Software\DownloadManager" /v "scansk" /f >nul 2>&1
reg delete "HKCU\Software\DownloadManager" /v "tvfrdt" /f >nul 2>&1
reg delete "HKCU\Software\DownloadManager" /v "radxcnt" /f >nul 2>&1
reg delete "HKCU\Software\DownloadManager" /v "LstCheck" /f >nul 2>&1
reg delete "HKCU\Software\DownloadManager" /v "ptrk_scdt" /f >nul 2>&1
reg delete "HKCU\Software\DownloadManager" /v "LastCheckQU" /f >nul 2>&1
reg delete "%HKLM_KEY%" /f >nul 2>&1
echo   Done.

echo.
echo   --- Step 4/4: Deleting CLSID keys ---
%psc% -NoProfile -Command "$sid = ([System.Security.Principal.NTAccount](Get-WmiObject Win32_ComputerSystem).UserName).Translate([System.Security.Principal.SecurityIdentifier]).Value; $HKCUsync = $null; $lockKey = $null; $deleteKey = 1; $f=[io.file]::ReadAllText('%~f0') -split ':regscan\:.*';iex ($f[1])"

echo.
echo   +------------------------------------------------------+
echo   ^|  DONE - Restart IDM for fresh 30-day trial           ^|
echo   +------------------------------------------------------+
echo.
pause
goto Menu

:: ====================== Wait ======================
:WaitFile
set /a "_at=0"
:WaitLoop
timeout /t 1 >nul
set /a "_at+=1"
if exist "%tmpf%" exit /b
if %_at% LSS 20 goto WaitLoop
exit /b

:: ====================== PowerShell CLSID Scanner ======================
:regscan:
$finalValues = @()

$arch = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment').PROCESSOR_ARCHITECTURE
if ($arch -eq "x86") {
  $regPaths = @("HKCU:\Software\Classes\CLSID", "Registry::HKEY_USERS\$sid\Software\Classes\CLSID")
} else {
  $regPaths = @("HKCU:\Software\Classes\WOW6432Node\CLSID", "Registry::HKEY_USERS\$sid\Software\Classes\Wow6432Node\CLSID")
}

foreach ($regPath in $regPaths) {
    if (($regPath -match "HKEY_USERS") -and ($HKCUsync -ne $null)) { continue }

    Write-Host "`n  Searching $regPath"

    $subKeys = Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue -ErrorVariable lockedKeys | Where-Object { $_.PSChildName -match '^\{[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}\}$' }

    foreach ($lockedKey in $lockedKeys) {
        $leafValue = Split-Path -Path $lockedKey.TargetObject -Leaf
        $finalValues += $leafValue
        Write-Output "  Locked: $leafValue"
    }

    if ($subKeys -eq $null) { continue }

    $exclude = "LocalServer32", "InProcServer32", "InProcHandler32"
    $filteredKeys = $subKeys | Where-Object { !($_.GetSubKeyNames() | Where-Object { $exclude -contains $_ }) }

    foreach ($key in $filteredKeys) {
        $fp = $key.PSPath
        $kv = Get-ItemProperty -Path $fp -ErrorAction SilentlyContinue
        $dv = $kv.PSObject.Properties | Where-Object { $_.Name -eq '(default)' } | Select-Object -ExpandProperty Value

        if (($dv -match "^\d+$") -and ($key.SubKeyCount -eq 0)) { $finalValues += $key.PSChildName; Write-Output "  Found: $($key.PSChildName) (digit default)"; continue }
        if (($dv -match "\+|=") -and ($key.SubKeyCount -eq 0)) { $finalValues += $key.PSChildName; Write-Output "  Found: $($key.PSChildName) (symbol default)"; continue }

        $vv = Get-ItemProperty -Path "$fp\Version" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty '(default)' -ErrorAction SilentlyContinue
        if (($vv -match "^\d+$") -and ($key.SubKeyCount -eq 1)) { $finalValues += $key.PSChildName; Write-Output "  Found: $($key.PSChildName) (digit version)"; continue }

        $kv.PSObject.Properties | ForEach-Object {
            if ($_.Name -match "MData|Model|scansk|Therad") { $finalValues += $key.PSChildName; Write-Output "  Found: $($key.PSChildName) (IDM marker)" }
        }
        if (($key.ValueCount -eq 0) -and ($key.SubKeyCount -eq 0)) { $finalValues += $key.PSChildName; Write-Output "  Found: $($key.PSChildName) (empty)" }
    }
}

$finalValues = @($finalValues | Select-Object -Unique)

if ($finalValues.Count -eq 0) { Write-Host "`n  No IDM keys found."; Exit }
Write-Host "`n  Found $($finalValues.Count) key(s)."

if (($finalValues.Count -gt 20) -and ($toggle -ne $null)) {
    $lockKey = $null; $deleteKey = 1
    Write-Host "  Too many keys - switching to delete mode."
}

function Take-Permissions {
    param($rootKey, $regKey)
    $ab = [AppDomain]::CurrentDomain.DefineDynamicAssembly(4, 1)
    $mb = $ab.DefineDynamicModule(2, $False)
    $tb = $mb.DefineType(0)
    $tb.DefinePInvokeMethod('RtlAdjustPrivilege', 'ntdll.dll', 'Public, Static', 1, [int], @([int], [bool], [bool], [bool].MakeByRefType()), 1, 3) | Out-Null
    9,17,18 | ForEach-Object { $tb.CreateType()::RtlAdjustPrivilege($_, $true, $false, [ref]$false) | Out-Null }

    $SID = New-Object System.Security.Principal.SecurityIdentifier('S-1-5-32-544')
    $Admin = New-Object System.Security.Principal.NTAccount(($SID.Translate([System.Security.Principal.NTAccount])).Value)
    $everyone = New-Object System.Security.Principal.SecurityIdentifier('S-1-1-0')
    $none = New-Object System.Security.Principal.SecurityIdentifier('S-1-0-0')

    $key = [Microsoft.Win32.Registry]::$rootKey.OpenSubKey($regKey, 'ReadWriteSubTree', 'TakeOwnership')
    $acl = New-Object System.Security.AccessControl.RegistrySecurity
    $acl.SetOwner($Admin); $key.SetAccessControl($acl)
    $key = $key.OpenSubKey('', 'ReadWriteSubTree', 'ChangePermissions')
    $rule = New-Object System.Security.AccessControl.RegistryAccessRule($everyone, 'FullControl', 'ContainerInherit', 'None', 'Allow')
    $acl.ResetAccessRule($rule); $key.SetAccessControl($acl)

    if ($lockKey -ne $null) {
        $acl2 = New-Object System.Security.AccessControl.RegistrySecurity
        $acl2.SetOwner($none); $key.SetAccessControl($acl2)
        $key = $key.OpenSubKey('', 'ReadWriteSubTree', 'ChangePermissions')
        $rule2 = New-Object System.Security.AccessControl.RegistryAccessRule($everyone, 'FullControl', 'Deny')
        $acl2.ResetAccessRule($rule2); $key.SetAccessControl($acl2)
    }
}

foreach ($regPath in $regPaths) {
    if (($regPath -match "HKEY_USERS") -and ($HKCUsync -ne $null)) { continue }
    foreach ($fv in $finalValues) {
        $fullPath = Join-Path -Path $regPath -ChildPath $fv
        $rootKey = if ($fullPath -match 'HKCU:') { 'CurrentUser' } else { 'Users' }
        $regKey = $fullPath.Substring($fullPath.IndexOf("\") + 1)

        if ($lockKey -ne $null) {
            if (-not (Test-Path $fullPath -ErrorAction SilentlyContinue)) { New-Item $fullPath -Force -ErrorAction SilentlyContinue | Out-Null }
            Take-Permissions $rootKey $regKey
            try { Remove-Item $fullPath -Force -Recurse -ErrorAction Stop }
            catch { Write-Host "  Locked: $fullPath" }
        }
        if ($deleteKey -ne $null) {
            if (Test-Path $fullPath) {
                Remove-Item $fullPath -Force -Recurse -ErrorAction SilentlyContinue
                if (Test-Path $fullPath) {
                    Take-Permissions $rootKey $regKey
                    try { Remove-Item $fullPath -Force -Recurse -ErrorAction Stop; Write-Host "  Deleted: $fullPath" }
                    catch { Write-Host "  Failed: $fullPath" }
                } else { Write-Host "  Deleted: $fullPath" }
            }
        }
    }
}
:regscan:
