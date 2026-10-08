if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Admin rights required!"
    exit
}

Write-Host "=== OPERATION: PURGE XBOX GAMING APP INCUBATOR ===" -ForegroundColor Cyan

$TargetPackage = "Microsoft.GamingApp"

# 1. Вырезаем мастер-пакет из шаблонов развертывания (чтобы новым юзерам ничего не создавалось)
Write-Host "[*] Step 1: Removing master package from deployment provisioned templates..." -ForegroundColor Yellow
Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq $TargetPackage -or $_.PackageName -like "*$TargetPackage*"} | ForEach-Object {
    Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
    Write-Host "    [+] Provisioned template for GamingApp destroyed." -ForegroundColor Green
}

# 2. Принудительно вычищаем пакет у абсолютно всех пользователей на машине
Write-Host "[*] Step 2: Removing package from all active user profiles..." -ForegroundColor Yellow
Get-AppxPackage -Name "*$TargetPackage*" -AllUsers -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue
    Write-Host "    [+] Package $($_.PackageFullName) purged from profiles." -ForegroundColor Green
}

# 3. Чистим остаточные триггеры в Default User (на случай, если там висит задача проверки)
Write-Host "[*] Step 3: Cleaning Default User registry..." -ForegroundColor Yellow
$DefaultHivePath = "C:\Users\Default\NTUSER.DAT"
if (Test-Path $DefaultHivePath) {
    & reg.exe load "HKU\local_default" $DefaultHivePath > $null 2>&1
    
    $RunPath = "HKEY_USERS\local_default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    & reg.exe delete $RunPath /v "XboxPcTray" /f > $null 2>&1
    & reg.exe delete $RunPath /v "XboxApp" /f > $null 2>&1
    
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
    & reg.exe unload "HKU\local_default" > $null 2>&1
    Write-Host "    [+] Default User hive checked and cleaned." -ForegroundColor Green
}

# 4. Перезапуск интерфейса оболочки
Write-Host "[*] Step 4: Resetting active Explorer sessions..." -ForegroundColor Yellow
Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "SystemSettings" -Force -ErrorAction SilentlyContinue
Start-Process "explorer.exe" -ErrorAction SilentlyContinue

Write-Host "===========================================================" -ForegroundColor Green
Write-Host "SUCCESS: XBOX GAMING APP COMPLETELY WIPED FROM THE MACHINE!" -ForegroundColor Green
Write-Host "Create a new local user to verify." -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Green
