<#
.SYNOPSIS
    IDM Tool - Manage Internet Download Manager trial period

.DESCRIPTION
    Freeze your 30-day trial forever or reset it for a fresh start.

.NOTES
    Run as Administrator required
    https://github.com/F3aarLeSS/IDM-Tool

.EXAMPLE
    # Run directly (as Administrator)
    .\IDM_Tool.ps1

    # Run via IEX (as Administrator)
    iex (irm https://raw.githubusercontent.com/F3aarLeSS/IDM-Tool/main/IDM_Tool.ps1)
#>

#Requires -RunAsAdministrator
#Requires -Version 5.1

$ErrorActionPreference = 'SilentlyContinue'

# ==================== FUNCTIONS ====================

function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  +------------------------------------------------------+" -ForegroundColor Green
    Write-Host "  |                                                      |" -ForegroundColor Green
    Write-Host "  |            I D M   T O O L   v1.0                    |" -ForegroundColor Green
    Write-Host "  |                                                      |" -ForegroundColor Green
    Write-Host "  +------------------------------------------------------+" -ForegroundColor Green
    Write-Host ""
}

function Write-MenuOption {
    param([string]$Key, [string]$Title, [string]$Desc)
    Write-Host "  |   [$Key]  $Title" -ForegroundColor Green -NoNewline
    $padding = 52 - $Title.Length - $Key.Length - 6
    Write-Host (" " * $padding) -NoNewline
    Write-Host "|" -ForegroundColor Green
    Write-Host "  |        $Desc" -ForegroundColor DarkGray -NoNewline
    $padding = 52 - $Desc.Length - 8
    Write-Host (" " * $padding) -NoNewline
    Write-Host "|" -ForegroundColor Green
    Write-Host "  |                                                      |" -ForegroundColor Green
}

function Write-BoxLine {
    param([string]$Text)
    Write-Host "  |  $Text" -ForegroundColor Yellow -NoNewline
    $padding = 52 - $Text.Length - 5
    Write-Host (" " * $padding) -NoNewline
    Write-Host "|" -ForegroundColor Yellow
}

function Write-BoxTop {
    Write-Host "  +------------------------------------------------------+" -ForegroundColor Yellow
}

function Write-BoxBottom {
    Write-Host "  +------------------------------------------------------+" -ForegroundColor Yellow
}

function Test-Admin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-IDMPath {
    # Try registry first
    $exepath = Get-ItemProperty -Path "HKCU:\Software\DownloadManager" -Name "ExePath" -ErrorAction SilentlyContinue
    if ($exepath -and (Test-Path $exepath.ExePath)) {
        return $exepath.ExePath
    }

    # Try default paths
    if ([Environment]::Is64BitOperatingSystem) {
        $paths = @(
            "${env:ProgramFiles(x86)}\Internet Download Manager\IDMan.exe",
            "$env:ProgramFiles\Internet Download Manager\IDMan.exe"
        )
    } else {
        $paths = @(
            "$env:ProgramFiles\Internet Download Manager\IDMan.exe"
        )
    }

    foreach ($path in $paths) {
        if (Test-Path $path) { return $path }
    }

    return $null
}

function Get-IDMVersion {
    $ver = Get-ItemProperty -Path "HKCU:\Software\DownloadManager" -Name "idmvers" -ErrorAction SilentlyContinue
    if ($ver) { return $ver.idmvers }
    return "Unknown"
}

function Get-IDMArch {
    $arch = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment').PROCESSOR_ARCHITECTURE
    if ($arch -eq "x86") { return "x86" }
    return "x64"
}

function Get-RegistryPaths {
    param([string]$Arch)

    if ($Arch -eq "x86") {
        return @{
            CLSID = "HKCU:\Software\Classes\CLSID"
            HKLM = "HKLM:\Software\Internet Download Manager"
        }
    } else {
        return @{
            CLSID = "HKCU:\Software\Classes\Wow6432Node\CLSID"
            HKLM = "HKLM:\SOFTWARE\Wow6432Node\Internet Download Manager"
        }
    }
}

function Stop-IDM {
    $process = Get-Process -Name "idman" -ErrorAction SilentlyContinue
    if ($process) {
        Stop-Process -Name "idman" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        Write-Host "  Done." -ForegroundColor Gray
    } else {
        Write-Host "  IDM not running." -ForegroundColor Gray
    }
}

function Remove-IDMRegistry {
    param([hashtable]$Paths)

    $values = @("FName", "LName", "Email", "Serial", "scansk", "tvfrdt", "radxcnt", "LstCheck", "ptrk_scdt", "LastCheckQU")

    foreach ($value in $values) {
        Remove-ItemProperty -Path "HKCU:\Software\DownloadManager" -Name $value -Force -ErrorAction SilentlyContinue
    }

    Remove-Item -Path $Paths.HKLM -Recurse -Force -ErrorAction SilentlyContinue
}

function New-RegistryBackup {
    param([string]$CLSIDPath)

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmssfff"
    $backupPath = "$env:SystemRoot\Temp\_Backup_CLSID_$timestamp.reg"

    try {
        & reg export $CLSIDPath.Replace("HKCU:", "HKCU\") $backupPath /y 2>$null
        return $backupPath
    } catch {
        return $null
    }
}

function Add-DriverKey {
    param([string]$HKLMPath)

    $regPath = $HKLMPath.Replace("HKLM:\", "HKLM\")
    & reg add $regPath /v "AdvIntDriverEnabled2" /t REG_DWORD /d "1" /f 2>$null
}

function Invoke-CLSIDScan {
    param(
        [string]$Mode,  # "lock" or "delete"
        [string]$Arch,
        [string]$SID
    )

    $regPaths = @()
    if ($Arch -eq "x86") {
        $regPaths += "HKCU:\Software\Classes\CLSID"
        if ($SID) { $regPaths += "Registry::HKEY_USERS\$SID\Software\Classes\CLSID" }
    } else {
        $regPaths += "HKCU:\Software\Classes\WOW6432Node\CLSID"
        if ($SID) { $regPaths += "Registry::HKEY_USERS\$SID\Software\Classes\Wow6432Node\CLSID" }
    }

    $finalValues = @()

    foreach ($regPath in $regPaths) {
        if ($regPath -match "HKEY_USERS" -and -not $SID) { continue }

        Write-Host "`n  Searching $regPath" -ForegroundColor Cyan

        try {
            $subKeys = Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue -ErrorVariable lockedKeys |
                Where-Object { $_.PSChildName -match '^\{[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}\}$' }
        } catch {
            $subKeys = $null
        }

        foreach ($lockedKey in $lockedKeys) {
            $leafValue = Split-Path -Path $lockedKey.TargetObject -Leaf
            $finalValues += $leafValue
            Write-Host "  Locked: $leafValue" -ForegroundColor Yellow
        }

        if (-not $subKeys) { continue }

        $exclude = @("LocalServer32", "InProcServer32", "InProcHandler32")
        $filteredKeys = $subKeys | Where-Object {
            $subNames = $_.GetSubKeyNames()
            -not ($exclude | Where-Object { $subNames -contains $_ })
        }

        foreach ($key in $filteredKeys) {
            $fp = $key.PSPath
            $kv = Get-ItemProperty -Path $fp -ErrorAction SilentlyContinue
            $dv = $kv.PSObject.Properties | Where-Object { $_.Name -eq '(default)' } | Select-Object -ExpandProperty Value

            if ($dv -match "^\d+$" -and $key.SubKeyCount -eq 0) {
                $finalValues += $key.PSChildName
                Write-Host "  Found: $($key.PSChildName) (digit default)" -ForegroundColor Gray
                continue
            }
            if ($dv -match "\+|=" -and $key.SubKeyCount -eq 0) {
                $finalValues += $key.PSChildName
                Write-Host "  Found: $($key.PSChildName) (symbol default)" -ForegroundColor Gray
                continue
            }

            $vv = Get-ItemProperty -Path "$fp\Version" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty '(default)' -ErrorAction SilentlyContinue
            if ($vv -match "^\d+$" -and $key.SubKeyCount -eq 1) {
                $finalValues += $key.PSChildName
                Write-Host "  Found: $($key.PSChildName) (digit version)" -ForegroundColor Gray
                continue
            }

            $kv.PSObject.Properties | ForEach-Object {
                if ($_.Name -match "MData|Model|scansk|Therad") {
                    $finalValues += $key.PSChildName
                    Write-Host "  Found: $($key.PSChildName) (IDM marker)" -ForegroundColor Gray
                }
            }
            if ($key.ValueCount -eq 0 -and $key.SubKeyCount -eq 0) {
                $finalValues += $key.PSChildName
                Write-Host "  Found: $($key.PSChildName) (empty)" -ForegroundColor Gray
            }
        }
    }

    $finalValues = $finalValues | Select-Object -Unique

    if ($finalValues.Count -eq 0) {
        Write-Host "`n  No IDM keys found." -ForegroundColor Yellow
        return
    }

    Write-Host "`n  Found $($finalValues.Count) key(s)." -ForegroundColor Cyan

    if ($finalValues.Count -gt 20 -and $Mode -eq "lock") {
        $Mode = "delete"
        Write-Host "  Too many keys - switching to delete mode." -ForegroundColor Yellow
    }

    foreach ($regPath in $regPaths) {
        if ($regPath -match "HKEY_USERS" -and -not $SID) { continue }

        foreach ($fv in $finalValues) {
            $fullPath = Join-Path -Path $regPath -ChildPath $fv

            if ($Mode -eq "lock") {
                if (-not (Test-Path $fullPath -ErrorAction SilentlyContinue)) {
                    New-Item $fullPath -Force -ErrorAction SilentlyContinue | Out-Null
                }
                try {
                    $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($fullPath.Replace("HKCU:\", ""), 'ReadWriteSubTree', 'TakeOwnership')
                    if ($key) {
                        $acl = New-Object System.Security.AccessControl.RegistrySecurity
                        $everyone = New-Object System.Security.Principal.SecurityIdentifier('S-1-1-0')
                        $none = New-Object System.Security.Principal.SecurityIdentifier('S-1-0-0')
                        $acl.SetOwner($none)
                        $key.SetAccessControl($acl)
                        $rule = New-Object System.Security.AccessControl.RegistryAccessRule($everyone, 'FullControl', 'Deny')
                        $acl.ResetAccessRule($rule)
                        $key.SetAccessControl($acl)
                        Write-Host "  Locked: $fullPath" -ForegroundColor Green
                    }
                } catch {
                    Write-Host "  Locked: $fullPath" -ForegroundColor Green
                }
            }

            if ($Mode -eq "delete") {
                if (Test-Path $fullPath) {
                    try {
                        Remove-Item $fullPath -Force -Recurse -ErrorAction Stop
                        Write-Host "  Deleted: $fullPath" -ForegroundColor Green
                    } catch {
                        Write-Host "  Failed: $fullPath" -ForegroundColor Red
                    }
                }
            }
        }
    }
}

function Invoke-TestDownloads {
    param([string]$IDManPath)

    $tmpf = "$env:SystemRoot\Temp\temp.png"
    $links = @(
        "https://www.internetdownloadmanager.com/images/idm_box_min.png",
        "https://www.internetdownloadmanager.com/pictures/idm_about.png"
    )

    foreach ($link in $links) {
        if (Test-Path $tmpf) { Remove-Item $tmpf -Force -ErrorAction SilentlyContinue }
        Start-Process -FilePath $IDManPath -ArgumentList "/n", "/d `"$link`"", "/p `"$env:SystemRoot\Temp`"", "/f temp.png" -NoNewWindow -ErrorAction SilentlyContinue

        $attempts = 0
        while ($attempts -lt 20) {
            Start-Sleep -Seconds 1
            $attempts++
            if (Test-Path $tmpf) { break }
        }
    }

    Start-Sleep -Seconds 3
    Stop-Process -Name "idman" -Force -ErrorAction SilentlyContinue
    if (Test-Path $tmpf) { Remove-Item $tmpf -Force -ErrorAction SilentlyContinue }
}

function Invoke-FreezeTrial {
    Clear-Host
    Write-BoxTop
    Write-BoxLine "FREEZE TRIAL"
    Write-BoxBottom
    Write-Host ""
    Write-Host "  Locks your 30-day trial permanently." -ForegroundColor White
    Write-Host "  Requires internet connection." -ForegroundColor White
    Write-Host "  IDM updates can be installed directly after." -ForegroundColor White
    Write-Host ""

    $idmPath = Get-IDMPath
    if (-not $idmPath) {
        Write-Host "  [!] IDM not installed. Download it first." -ForegroundColor Red
        Write-Host ""
        pause
        return
    }

    Write-Host "  IDM found: $idmPath" -ForegroundColor Gray
    $confirm = Read-Host "  Continue? [Y/N]"
    if ($confirm -ne "Y") { return }

    Write-Host ""
    Write-Host "  --- Step 1/5: Closing IDM ---" -ForegroundColor Cyan
    Stop-IDM

    Write-Host ""
    Write-Host "  --- Step 2/5: Registry backup ---" -ForegroundColor Cyan
    $arch = Get-IDMArch
    $paths = Get-RegistryPaths -Arch $arch
    $backupPath = New-RegistryBackup -CLSIDPath $paths.CLSID
    if ($backupPath) {
        Write-Host "  Saved: $backupPath" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "  --- Step 3/5: Cleaning registry ---" -ForegroundColor Cyan
    Remove-IDMRegistry -Paths $paths
    Write-Host "  Done." -ForegroundColor Gray

    Write-Host ""
    Write-Host "  --- Step 4/5: Adding driver key ---" -ForegroundColor Cyan
    Add-DriverKey -HKLMPath $paths.HKLM
    Write-Host "  Done." -ForegroundColor Gray

    Write-Host ""
    Write-Host "  --- Step 5/5: Locking CLSID keys ---" -ForegroundColor Cyan
    $sid = ([System.Security.Principal.NTAccount](Get-WmiObject Win32_ComputerSystem).UserName).Translate([System.Security.Principal.SecurityIdentifier]).Value
    Invoke-CLSIDScan -Mode "lock" -Arch $arch -SID $sid

    Write-Host ""
    Write-Host "  --- Triggering test downloads ---" -ForegroundColor Cyan
    Invoke-TestDownloads -IDManPath $idmPath

    Write-Host ""
    Write-BoxTop
    Write-BoxLine "DONE - Trial frozen for lifetime"
    Write-BoxBottom
    Write-Host ""
    pause
}

function Invoke-ResetTrial {
    Clear-Host
    Write-BoxTop
    Write-BoxLine "RESET ACTIVATION & TRIAL"
    Write-BoxBottom
    Write-Host ""
    Write-Host "  Clears all activation and trial data." -ForegroundColor White
    Write-Host "  Gives you a fresh 30-day trial." -ForegroundColor White
    Write-Host "  Fixes fake serial key errors." -ForegroundColor White
    Write-Host ""

    $idmPath = Get-IDMPath
    if (-not $idmPath) {
        Write-Host "  [!] IDM not installed." -ForegroundColor Red
        Write-Host ""
        pause
        return
    }

    Write-Host "  IDM found: $idmPath" -ForegroundColor Gray
    $confirm = Read-Host "  Continue? [Y/N]"
    if ($confirm -ne "Y") { return }

    Write-Host ""
    Write-Host "  --- Step 1/4: Closing IDM ---" -ForegroundColor Cyan
    Stop-IDM

    Write-Host ""
    Write-Host "  --- Step 2/4: Registry backup ---" -ForegroundColor Cyan
    $arch = Get-IDMArch
    $paths = Get-RegistryPaths -Arch $arch
    $backupPath = New-RegistryBackup -CLSIDPath $paths.CLSID
    if ($backupPath) {
        Write-Host "  Saved: $backupPath" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "  --- Step 3/4: Cleaning registry ---" -ForegroundColor Cyan
    Remove-IDMRegistry -Paths $paths
    Write-Host "  Done." -ForegroundColor Gray

    Write-Host ""
    Write-Host "  --- Step 4/4: Deleting CLSID keys ---" -ForegroundColor Cyan
    $sid = ([System.Security.Principal.NTAccount](Get-WmiObject Win32_ComputerSystem).UserName).Translate([System.Security.Principal.SecurityIdentifier]).Value
    Invoke-CLSIDScan -Mode "delete" -Arch $arch -SID $sid

    Write-Host ""
    Write-Host "  --- Adding driver key ---" -ForegroundColor Cyan
    Add-DriverKey -HKLMPath $paths.HKLM

    Write-Host ""
    Write-BoxTop
    Write-BoxLine "DONE - Restart IDM for fresh 30-day trial"
    Write-BoxBottom
    Write-Host ""
    pause
}

function Invoke-DownloadIDM {
    Start-Process "https://www.internetdownloadmanager.com/download.html"
    Write-Host ""
    Write-Host "  Opening browser..." -ForegroundColor Gray
    Start-Sleep -Seconds 2
}

# ==================== MAIN ====================

# Check admin
if (-not (Test-Admin)) {
    Write-Host ""
    Write-Host "  Run this script as Administrator." -ForegroundColor Red
    Write-Host "  Right-click PowerShell > Run as administrator" -ForegroundColor Red
    Write-Host ""
    pause
    exit 1
}

# Get system info
$arch = Get-IDMArch
$idmPath = Get-IDMPath
$idmVer = Get-IDMVersion

# Main menu loop
while ($true) {
    Write-Header

    Write-Host "  IDM Version : $idmVer" -ForegroundColor Gray
    Write-Host "  Architecture: $arch" -ForegroundColor Gray
    Write-Host ""

    Write-Host "  +------------------------------------------------------+" -ForegroundColor Green
    Write-Host "  |                                                      |" -ForegroundColor Green
    Write-MenuOption -Key "1" -Title "Freeze Trial" -Desc "Lock 30-day trial forever"
    Write-MenuOption -Key "2" -Title "Reset Activation & Trial" -Desc "Get fresh 30-day trial"
    Write-MenuOption -Key "3" -Title "Download IDM" -Desc "Open official download page"
    Write-MenuOption -Key "0" -Title "Exit" -Desc ""
    Write-Host "  +------------------------------------------------------+" -ForegroundColor Green
    Write-Host ""

    $choice = Read-Host "  Choose"

    switch ($choice) {
        "0" { exit 0 }
        "1" { Invoke-FreezeTrial }
        "2" { Invoke-ResetTrial }
        "3" { Invoke-DownloadIDM }
    }
}
