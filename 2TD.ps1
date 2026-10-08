# Запрос прав администратора, если скрипт запущен без них
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
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
Write-Host "1. БЛОКИРОВКА АВТОУСТАНОВКИ OEM И ОБЛАЧНОГО МУСОРА" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
$null = New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" -Name "SearchOrderConfig" -Type DWord -Value 0 -Force
$null = New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -Type DWord -Value 1 -Force
$null = New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1 -Force
$null = New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableSilentInstalledApps" -Type DWord -Value 1 -Force

Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Write-Host "2. ОТКЛЮЧЕНИЕ ВИДЖЕТОВ, НОВОСТЕЙ И ONEDRIVE" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
$null = New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Type DWord -Value 0 -Force
$null = New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1 -Force

Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Write-Host "3. ОПТИМИЗАЦИЯ ДЕФЕНДЕРА ПОД УСТАНОВКУ КАСПЕРСКОГО" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
$null = New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "PassiveMode" -Type DWord -Value 1 -Force

Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Write-Host "ДОПОЛНЕНИЕ 3: ДОБАВЛЕНИЕ ИСКЛЮЧЕНИЙ В MICROSOFT DEFENDER" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan

# Массив путей, которые Defender обязан игнорировать при фоновых проверках
$DefenderExclusions = @(
    "$env:ProgramFiles\Kaspersky Lab",
    "$env:ProgramFiles(x86)\Kaspersky Lab",
    "$env:ProgramData\Kaspersky Lab",
    "$env:ProgramData\NCALayer",
    "$env:AppData\NCALayer"
)

foreach ($Path in $DefenderExclusions) {
    if (Test-Path $Path) {
        # Используем встроенный командлет для добавления папок в белый список
        Add-MpPreference -ExclusionPath $Path -ErrorAction SilentlyContinue
    }
}


Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Write-Host "4. ПОЛНОЕ УДАЛЕНИЕ СУЩЕСТВУЮЩЕГО МУСОРА ИЗ СИСТЕМЫ" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
$Apps = @('Clipchamp', 'Journal', 'Family', 'Lenovo', '549971C3265D', 'Xbox')
foreach ($App in $Apps) {
    Get-AppxPackage "*$App*" -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*$App*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Write-Host "5. ОТКЛЮЧЕНИЕ СЛУЖБ XBOX И ИГРОВОГО МОНИТОРИНГА" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
$null = New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0 -Force

@('XblAuthManager', 'XblGameSave', 'XboxNetApiSvc', 'XboxGipSvc') | ForEach-Object {
    Set-Service -Name $_ -StartupType Disabled -ErrorAction SilentlyContinue
}

Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Write-Host "6. ОТКЛЮЧЕНИЕ ЗАДАЧ В КОРНЕ ПЛАНИРОВЩИКА (UPDATER, WINSAT)" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Get-ScheduledTask -TaskPath '\' | Where-Object {$_.TaskName -like '*Update*' -or $_.TaskName -like '*Helper*' -or $_.TaskName -like '*WinSAT*'} | ForEach-Object {Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}

Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Write-Host "7. МАССОВАЯ ЗАЧИСТКА СИСТЕМНЫХ ПАПОК (ОТ А ДО Я)" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan

$Paths = @(
    "\Microsoft\Windows\Application Experience\", 
	"\Microsoft\Windows\Customer Experience Improvement Program\", 
    "\Microsoft\Windows\DiskDiagnostic\", 
	"\Microsoft\Windows\Autochk\", "\Microsoft\Windows\Maps\", 
    "\Microsoft\Windows\Power Efficiency Diagnostics\", 
	"\Microsoft\Windows\Bluetooth\", 
	"\Microsoft\Windows\BitLocker\", 
    "\Microsoft\Windows\CloudExperienceHost\", 
	"\Microsoft\Windows\CloudRestore\", 
	"\Microsoft\Windows\Defrag\", 
    "\Microsoft\Windows\Diagnosis\", 
    "\Microsoft\Windows\DirectX\", 
	"\Microsoft\Windows\DiskCleanup\", 
	"\Microsoft\Windows\DiskFootprint\", 
    "\Microsoft\Windows\DUSM\", 
	"\Microsoft\Windows\EDP\", 
	"\Microsoft\Windows\File Classification Infrastructure\", 
    "\Microsoft\Windows\FileHistory\", 
	"\Microsoft\Windows\Flighting\", 
	"\Microsoft\Windows\HelloFace\", 
    "\Microsoft\Windows\InstallService\", 
	"\Microsoft\Windows\LanguageComponentInstaller\", 
	"\Microsoft\Windows\LicenseManager\", 
    "\Microsoft\Windows\Live\Roaming\", 
	"\Microsoft\Windows\Location\", 
	"\Microsoft\Windows\Maintenance\", 
    "\Microsoft\Windows\Management\", 
	"\Microsoft\Windows\MobileBroadbandAccounts\", 
	"\Microsoft\Windows\MUI\", 
    "\Microsoft\Windows\NetTrace\", 
	"\Microsoft\Windows\NlaSvc\", 
	"\Microsoft\Windows\OfflineFiles\", 
    "\Microsoft\Windows\PushToInstall\", 
	"\Microsoft\Windows\RecoveryEnvironment\", 
	"\Microsoft\Windows\Registry\", 
    "\Microsoft\Windows\RemoteAssistance\", 
	"\Microsoft\Windows\SettingSync\", 
	"\Microsoft\Windows\SharedPC\", 
	"\Microsoft\Office\",
    "\Microsoft\Windows\SpacePort\", 
	"\Microsoft\Windows\Speech\",  
    "\Microsoft\Windows\TPM\", 
	"\Microsoft\Windows\UPnP\", 
	"\Microsoft\Windows\User Profile Service\", 
    "\Microsoft\Windows\WaaSMedicCenter\", 
	"\Microsoft\Windows\Wallet\", 
	"\Microsoft\Windows\WCM\", 
	"\Microsoft\Windows\WDI\", 
    "\Microsoft\Windows\WebBlends\", 
	"\Microsoft\Windows\Windows Error Reporting\", 
	"\Microsoft\Windows\Windows Filtering Platform\", 
    "\Microsoft\Windows\Windows Media Sharing\", 
	"\Microsoft\Windows\WorkFolders\"
)

foreach ($Path in $Paths) {
    Get-ScheduledTask -TaskPath $Path -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -ne 'HiveUploadTask'} | ForEach-Object {Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
}

Get-ScheduledTask | Where-Object {$_.TaskName -like '*edgeupdate*'} | ForEach-Object {Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\Feedback\Siuf\' -ErrorAction SilentlyContinue | ForEach-Object {Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\ExploitGuard\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -eq 'ExploitGuard MDM policy refresh'} | ForEach-Object {Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\Input\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -ne 'MsCtfMonitor'} | ForEach-Object {Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\PI\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -eq 'SQMTasks'} | ForEach-Object {Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\Printing\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -eq 'EduPrintProv'} | ForEach-Object {Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\RAS\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -eq 'MobilityManager'} | ForEach-Object {Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\Shell\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -eq 'IndexerAutomaticMaintenance'} | ForEach-Object {Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\SoftwareProtectionPlatform\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -eq 'SvcRestartTask'} | ForEach-Object {Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\SysMain\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -eq 'WsSwapAssessmentTask'} | ForEach-Object {Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -eq 'ReportPolicies'} | ForEach-Object {Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\WindowsUpdate\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -eq 'Scheduled Start'} | ForEach-Object {Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}

Write-Host "-----------------------------------------------------------" -ForegroundColor Green
Write-Host "Зачистка завершена успешно. Перезагрузите компьютер." -ForegroundColor Green
Write-Host "-----------------------------------------------------------" -ForegroundColor Green
