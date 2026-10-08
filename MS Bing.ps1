if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Требуются права Администратора!"
    exit
}

Write-Host "=== ОПЕРАЦИЯ: АННИГИЛЯЦИЯ ПАКЕТОВ MICROSOFT BING ===" -ForegroundColor Cyan

# Массив всех поисковых и новостных инкубаторов Bing в Windows 11
$BingPackages = @(
    "Microsoft.BingSearch",
    "Microsoft.BingNews",
    "Microsoft.BingWeather"
)

foreach ($App in $BingPackages) {
    # 1. Вырезаем мастер-пакет из шаблонов развертывания (чтобы не ставилось новым юзерам)
    Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq $App -or $_.PackageName -like "*$App*"} | ForEach-Object {
        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
        Write-Host "    [+] Системный шаблон $App полностью уничтожен." -ForegroundColor Green
    }
    
    # 2. Принудительно вырезаем пакет у всех существующих пользователей машины
    Get-AppxPackage -Name "*$App*" -AllUsers -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue
        Write-Host "    [+] Пакет $($_.PackageFullName) вычищен из профилей." -ForegroundColor Green
    }
}

# 3. Контрольный выстрел: отключаем интеграцию Bing в локальном поиске Windows через реестр
Write-Host "[*] Блокируем интеграцию веб-поиска Bing в Проводнике и Пуске..." -ForegroundColor Yellow
$SearchPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
if (-not (Test-Path $SearchPath)) { New-Item -Path $SearchPath -Force -ErrorAction SilentlyContinue | Out-Null }
Set-ItemProperty -Path $SearchPath -Name "AllowCortana" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $SearchPath -Name "ConnectedSearchUseWeb" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue

# Перезапускаем интерфейс оболочки
Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "SystemSettings" -Force -ErrorAction SilentlyContinue
Start-Process "explorer.exe" -ErrorAction SilentlyContinue

Write-Host "===========================================================" -ForegroundColor Green
Write-Host "ПАКЕТЫ BING УСПЕШНО ВЫРЕЗАНЫ ИЗ СИСТЕМЫ И РЕЕСТРА!" -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Green
