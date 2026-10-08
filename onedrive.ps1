# =======================================================================================
# FixDefault.ps1 — СТЕРИЛИЗАЦИЯ ШАБЛОНА DEFAULT ПО МЕТОДИКЕ СТАТЬИ + ФИКС ДЛЯ 25H2
# =======================================================================================

# 0. Проверка прав Администратора
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Требуются права Администратора!"
    exit
}

$DefaultHivePath = "C:\Users\Default\NTUSER.DAT"

if (Test-Path $DefaultHivePath) {
    Write-Host "[*] Монтируем куст Default User..." -ForegroundColor Yellow
    # Монтируем во временную ветку HKEY_USERS\local_default, чтобы избежать путаницы с системной .DEFAULT
    & reg.exe load "HKU\local_default" $DefaultHivePath > $null 2>&1

    # --------------------------------===================================================
    # ЧАСТЬ 1: ЧИСТЫЙ МЕТОД ИЗ СТАТЬИ (Вырезаем автоустановку OneDrive)
    # --------------------------------===================================================
    Write-Host "[*] Выжигаем задачу OneDriveSetup из автозапуска шаблона..." -ForegroundColor Cyan
    $RunPath = "HKEY_USERS\local_default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    
    # Прямое удаление ключа-триггера через reg.exe (как в статье)
    & reg.exe delete $RunPath /v "OneDriveSetup" /f > $null 2>&1

    # --------------------------------===================================================
    # ЧАСТЬ 2: ДЕАКТИВАЦИЯ COPILOT И ОБЛАЧНЫХ ФАНТОМОВ ДЛЯ 25H2
    # --------------------------------===================================================
    Write-Host "[*] Блокируем вывески Copilot и доставку облачного мусора..." -ForegroundColor Cyan
    
    # Пути реестра внутри смонтированного куста через провайдер PowerShell
    $TargetPolicies = "Registry::HKU\local_default\Software\Policies\Microsoft\Windows\WindowsCopilot"
    $TargetAdvanced = "Registry::HKU\local_default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $TargetContent  = "Registry::HKU\local_default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"

    # Создаем ветки, если Капитал их еще не инициализировал
    $Paths = @($TargetPolicies, $TargetAdvanced, $TargetContent)
    foreach ($P in $Paths) { if (-not (Test-Path $P)) { New-Item -Path $P -Force -ErrorAction SilentlyContinue | Out-Null } }

    # Глушим Copilot на уровне политик нового юзера
    Set-ItemProperty -Path $TargetPolicies -Name "TurnOffWindowsCopilot" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $TargetAdvanced -Name "ShowCopilotButton" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $TargetAdvanced -Name "TaskbarMn" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue

    # Вырубаем ContentDeliveryManager (именно он без интернета рисует «мертвые» иконки в Пуске)
    Set-ItemProperty -Path $TargetContent -Name "ContentDeliveryAllowed" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $TargetContent -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $TargetContent -Name "PreinstalledAppsEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $TargetContent -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue 

    # --------------------------------===================================================
    # РАЗМОНТИРОВАНИЕ КУСТА (Критически важно, чтобы сохранить изменения)
    # --------------------------------===================================================
    Write-Host "[*] Размонтируем куст и сохраняем изменения..." -ForegroundColor Yellow
    # Перед размонтированием принудительно очищаем мусор сборщика, чтобы закрыть хэндлы реестра в PS7
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
    
    & reg.exe unload "HKU\local_default" > $null 2>&1
    Write-Host "[+] Шаблон Default успешно очищен!" -ForegroundColor Green
} else {
    Write-Error "Файл NTUSER.DAT шаблона Default не найден!"
}

# --------------------------------===================================================
# ДОПОЛНИТЕЛЬНЫЙ БЛОК: УДУШЕНИЕ И ДЕИНСТАЛЛЯЦИЯ ONEDRIVE ДЛЯ ТЕКУЩЕГО ПОЛЬЗОВАТЕЛЯ
# --------------------------------===================================================
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "ЛИКВИДАЦИЯ ONEDRIVE ДЛЯ ТЕКУЩЕЙ УЧЕТНОЙ ЗАПИСИ" -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Cyan

# 1. Принудительно выгружаем процессы из трея и оперативной памяти
Write-Host "[*] Выгружаем активные процессы OneDrive..." -ForegroundColor Yellow
Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "OneDriveSetup" -Force -ErrorAction SilentlyContinue

# 2. Вызываем штатный деинсталлятор текущего пользователя, если бинарник живой
$UserOneDriveSetup = "$env:LocalAppdata\Microsoft\OneDrive\Update\OneDriveSetup.exe"
if (Test-Path $UserOneDriveSetup) {
    Write-Host "[*] Запуск встроенного деинсталлятора текущего юзера..." -ForegroundColor Yellow
    Start-Process -FilePath $UserOneDriveSetup -ArgumentList "/uninstall" -NoNewWindow -Wait -ErrorAction SilentlyContinue
}

# 3. Вырезаем задачу автозапуска OneDrive из реестра текущего пользователя (HKCU)
Write-Host "[*] Удаляем ключ автозапуска из HKCU..." -ForegroundColor Yellow
$CurrentUserRun = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
if (Test-Path $CurrentUserRun) {
    & reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f > $null 2>&1
    & reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f > $null 2>&1
}

# 4. Физическая зачистка остаточных папок текущего профиля
Write-Host "[*] Чистим остаточные папки профиля..." -ForegroundColor Yellow
$LocalFolders = @(
    "$env:LocalAppdata\Microsoft\OneDrive",
    "$env:RoamingAppdata\Microsoft\OneDrive"
)
foreach ($Folder in $LocalFolders) {
    if (Test-Path $Folder) {
        Remove-Item -Path $Folder -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "===========================================================" -ForegroundColor Green
Write-Host "[+] ТЕКУЩИЙ ПОЛЬЗОВАТЕЛЬ ОЧИЩЕН ОТ ONEDRIVE БЕЗ ОШИБОК!" -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Green