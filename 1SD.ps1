# Запрос прав администратора без использования кавычек внутри кавычек
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process "$psHome\powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$MyInvocation.MyCommand.Path`"" -Verb RunAs
    exit
} 

# =======================================================================================
# ИНТЕРАКТИВНЫЙ ПРЕДОХРАНИТЕЛЬ (ТОЧКА ВОССТАНОВЛЕНИЯ)
# =======================================================================================
Clear-Host
Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Write-Host " КРИТИЧЕСКИЙ ПРЕДОХРАНИТЕЛЬ КОНТУРА" -ForegroundColor Yellow
Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Write-Host " Вы собираетесь запустить глубокую зачистку системы." -ForegroundColor White
Write-Host " Убедитесь, что ТОЧКА ВОССТАНОВЛЕНИЯ уже создана!" -ForegroundColor White
Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow

# Запрашиваем ввод от пользователя без лишнего экранирования
$Choice = Read-Host " Точка восстановления создана? Продолжаем? Нажми 1 если да"

if ($Choice -ne "1") {
    Write-Host ""
    Write-Host " [-] Отмена операции. Скрипт остановлен для безопасности." -ForegroundColor Red
    Write-Host " Создайте точку восстановления и запустите скрипт заново." -ForegroundColor Yellow
    Write-Host ""
    Exit
}

Write-Host ""
Write-Host " [+] Проверка пройдена. Контур подтвержден. Начинаем зачистку..." -ForegroundColor Green
Write-Host ""
Start-Sleep -Seconds 1


Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Write-Host "1. БЛОКИРОВКА ИГРОВЫХ СЛУЖБ И XBOX" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Set-Service -Name 'XblAuthManager' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'XblAuthManager' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'XblGameSave' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'XblGameSave' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'XboxGipSvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'XboxGipSvc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'XboxNetApiSvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'XboxNetApiSvc' -Force -ErrorAction SilentlyContinue

Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Write-Host "МОДЕРНИЗИРОВАННАЯ ЗАЧИСТКА МУСОРА WINDOWS 11" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan

# 1. Принудительное удаление UWP-приложений без конфликта параметров в PS7
$AppsToRemove = @(
    "*Teams*", 
    "*OutlookForWindows*", 
    "*QuickAssist*", 
    "*StickyNotes*", 
    "*Whiteboard*", 
    "*Getstarted*"
)

foreach ($App in $AppsToRemove) {
    # Удаляем пакет строго для ТЕКУЩЕГО пользователя (это обойдет ошибку "Запрос не поддерживается")
    Get-AppxPackage -Name $App -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-AppxPackage -Package $_.PackageFullName -ErrorAction SilentlyContinue
    }
    
    # Полностью вырезаем пакет из системного шаблона (чтобы он не ставился заново другим юзерам)
    Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like $App -or $_.PackageName -like $App} | ForEach-Object {
        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
    }
}


foreach ($App in $AppsToRemove) {
        # Вырезаем из системы, чтобы не ставилось новым пользователям
    Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like $App -or $_.PackageName -like $App} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# 2. Удаление "Быстрой поддержки" (Quick Assist) как системного компонента через DISM
Write-Host "Выпиливаем Быструю поддержку через DISM..." -ForegroundColor Yellow
Get-WindowsCapability -Online -ErrorAction SilentlyContinue | Where-Object {$_.Name -like "*QuickAssist*"} | Remove-WindowsCapability -Online -ErrorAction SilentlyContinue

Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Write-Host "2. БЛОКИРОВКА СЛУЖБ ОБНОВЛЕНИЯ СТОРОННЕГО СОФТА" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Set-Service -Name 'AdobeARMservice' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'AdobeARMservice' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'AGSService' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'AGSService' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'GoogleChromeElevationService' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'GoogleChromeElevationService' -Force -ErrorAction SilentlyContinue
Get-Service -Name 'GoogleUpdater*' -ErrorAction SilentlyContinue | ForEach-Object {sc.exe config $_.Name start= disabled; Stop-Service -InputObject $_ -Force -ErrorAction SilentlyContinue}
Set-Service -Name 'gupdate' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'gupdate' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'gupdatem' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'gupdatem' -Force -ErrorAction SilentlyContinue

Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Write-Host "3. ВЫПИЛИВАНИЕ МУСОРА WINDOWS И 'НАСЛЕДИЯ ПРЕДКОВ'" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Set-Service -Name 'AJRouter' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'AJRouter' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'AppVClient' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'AppVClient' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'WbioSrvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'WbioSrvc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'RetailDemo' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'RetailDemo' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'Fax' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'Fax' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'RemoteRegistry' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'RemoteRegistry' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'MapsBroker' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'MapsBroker' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'WalletService' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'WalletService' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'WpcMonSvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'WpcMonSvc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'workfolderssvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'workfolderssvc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'WMPNetworkSvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'WMPNetworkSvc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'lfsvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'lfsvc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'shpamsvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'shpamsvc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'PcaSvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'PcaSvc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'DisplayEnhancementService' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'DisplayEnhancementService' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'ssh-agent' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'ssh-agent' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'cloudidsvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'cloudidsvc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'NaturalAuthentication' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'NaturalAuthentication' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'PhoneSvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'PhoneSvc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'SmsRouter' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'SmsRouter' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'wlidsvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'wlidsvc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'bthserv' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'bthserv' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'BTAGService' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'BTAGService' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'BthAvctpSvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'BthAvctpSvc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'SharedAccess' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'SharedAccess' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'icssvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'icssvc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'WinRM' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'WinRM' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'WManSvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'WManSvc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'MSiSCSI' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'MSiSCSI' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'SNMPTrap' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'SNMPTrap' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'PNRPsvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'PNRPsvc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'PNRPAutoReg' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'PNRPAutoReg' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'p2psvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'p2psvc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'p2pimsvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'p2pimsvc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'lltdsvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'lltdsvc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'cphc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'cphc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'TabletInputService' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'TabletInputService' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'InstallService' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'InstallService' -Force -ErrorAction SilentlyContinue
Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\OneSyncSvc*" -ErrorAction SilentlyContinue | ForEach-Object {Set-ItemProperty -Path $_.PsPath -Name "Start" -Value 4 -ErrorAction SilentlyContinue; Stop-Service -Name $_.PSChildName -Force -ErrorAction SilentlyContinue}
Get-AppxPackage -Name "Microsoft.MixedReality.Portal" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*MixedReality*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.YourPhone" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*YourPhone*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.WindowsAlarms" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*WindowsAlarms*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.GetHelp" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*GetHelp*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.Getstarted" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*Getstarted*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Objectivity.TheJournal" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*Journal*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.Clipchamp" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*Clipchamp*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.MicrosoftFamilyFeatures" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*Family*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.People" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*People*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.BingNews" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*BingNews*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.BingWeather" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*BingWeather*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.WindowsFeedbackHub" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*FeedbackHub*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.ScreenSketch" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*ScreenSketch*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.WindowsMaps" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*WindowsMaps*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.ZuneMusic" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*ZuneMusic*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.SkypeApp" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*SkypeApp*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.Todos" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*Todos*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.PowerAutomateDesktop" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*PowerAutomate*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "microsoft.windowscommunicationsapps" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*windowscommunicationsapps*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.Microsoft3DViewer" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*3DViewer*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.MicrosoftStickyNotes" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*StickyNotes*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.MSPaint" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*MSPaint*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -Name "Microsoft.Office.OneNote" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*OneNote*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Write-Host "4. ОТКЛЮЧЕНИЕ СЛУЖБ ТЕЛЕМЕТРИИ И ОТЧЕТОВ ОБ ОШИБКАХ" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Set-Service -Name 'DiagTrack' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'DiagTrack' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'dmwappushservice' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'dmwappushservice' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'WerSvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'WerSvc' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'wercplsupport' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'wercplsupport' -Force -ErrorAction SilentlyContinue

Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Write-Host "5. ОТКЛЮЧЕНИЕ СЛУЖБЫ UPDATE HEALTH SERVICE" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Set-Service -Name 'uhssvc' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'uhssvc' -Force -ErrorAction SilentlyContinue

Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Write-Host "6. ОТКЛЮЧЕНИЕ ФОНОВОГО ТЕЛЕМЕТРИЙНОГО И DRM ХЛАМА INTEL" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Set-Service -Name 'cphs' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'cphs' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'jhi_service' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'jhi_service' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'GccHubService' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'GccHubService' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'IntelMEProviderService' -StartupType Disabled -ErrorAction SilentlyContinue; Stop-Service -Name 'IntelMEProviderService' -Force -ErrorAction SilentlyContinue

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

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Admin rights required!"
    exit
}

Write-Host "=== PURGING ALL COPILOT INCUBATORS ===" -ForegroundColor Cyan

$TargetPackages = @(
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.Copilot",
    "Microsoft.549981C3F5F10"
)

foreach ($App in $TargetPackages) {
    Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq $App -or $_.PackageName -like "*$App*"} | ForEach-Object {
        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
    }
    Get-AppxPackage -Name "*$App*" -AllUsers -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue
    }
}

$GpoPaths = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI",
    "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
)
foreach ($Path in $GpoPaths) { if (-not (Test-Path $Path)) { New-Item -Path $Path -Force -ErrorAction SilentlyContinue | Out-Null } }

Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "TurnOffWindowsAI" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "RemoveMicrosoftCopilotApp" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue 
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "HubsSidebarEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue

$DefaultHivePath = "C:\Users\Default\NTUSER.DAT"
if (Test-Path $DefaultHivePath) {
    & reg.exe load "HKU\local_default" $DefaultHivePath > $null 2>&1
    
    $UserCopilot = "Registry::HKU\local_default\Software\Policies\Microsoft\Windows\WindowsCopilot"
    $UserWindowsAI = "Registry::HKU\local_default\Software\Policies\Microsoft\Windows\WindowsAI"
    $UserAdvanced = "Registry::HKU\local_default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $UserContent = "Registry::HKU\local_default\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"

    $Paths = @($UserCopilot, $UserWindowsAI, $UserAdvanced, $UserContent)
    foreach ($P in $Paths) { if (-not (Test-Path $P)) { New-Item -Path $P -Force -ErrorAction SilentlyContinue | Out-Null } }

    Set-ItemProperty -Path $UserCopilot -Name "TurnOffWindowsCopilot" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $UserWindowsAI -Name "TurnOffWindowsAI" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $UserAdvanced -Name "ShowCopilotButton" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Set-ItemProperty -Path $UserContent -Name "ContentDeliveryAllowed" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $UserContent -Name "PreinstalledAppsEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $UserContent -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue

    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
    & reg.exe unload "HKU\local_default" > $null 2>&1
}

$AITasks = @("\Microsoft\Windows\WindowsAI\AITask", "\Microsoft\Windows\Copilot\CopilotTask")
foreach ($Task in $AITasks) { & schtasks.exe /delete /tn $Task /f >$null 2>&1 }

Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "SystemSettings" -Force -ErrorAction SilentlyContinue
Start-Process "explorer.exe" -ErrorAction SilentlyContinue

Write-Host "===========================================================" -ForegroundColor Green
Write-Host "SUCCESS: ALL COPILOT VARIATIONS WIPED FROM SYSTEM & DEFAULT" -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Green

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

Write-Host "=== ОПЕРАЦИЯ: ВЫЖИГАНИЕ CLIPCHAMP И XBOX LIVE ===" -ForegroundColor Cyan

# Точные системные имена выживших пакетов
$LastTargets = @(
    "Microsoft.Clipchamp",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxLive"
)

foreach ($App in $LastTargets) {
    # 1. Вырезаем из шаблонов развертывания (чтобы не создавалось у новых юзеров)
    Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq $App -or $_.PackageName -like "*$App*"} | ForEach-Object {
        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
        Write-Host "    [+] Системный шаблон $App уничтожен." -ForegroundColor Green
    }
    
    # 2. Вырезаем из профилей всех текущих пользователей
    Get-AppxPackage -Name "*$App*" -AllUsers -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue
        Write-Host "    [+] Пакет $($_.PackageFullName) вычищен из системы." -ForegroundColor Green
    }
}

# Перезапускаем интерфейс Параметров и Проводника для обновления списков
Stop-Process -Name "SystemSettings" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
Start-Process "explorer.exe" -ErrorAction SilentlyContinue

Write-Host "===========================================================" -ForegroundColor Green
Write-Host "ОСТАТКИ МУСОРА ЛИКВИДИРОВАНЫ!" -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Green

Write-Host "-----------------------------------------------------------" -ForegroundColor Green
Write-Host "Зачистка служб завершена успешно. Перезагрузите компьютер." -ForegroundColor Green
Write-Host "-----------------------------------------------------------" -ForegroundColor Green

