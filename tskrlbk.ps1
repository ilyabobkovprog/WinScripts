# Запрос прав администратора, если скрипт запущен без них
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Write-Host "1. ВОССТАНОВЛЕНИЕ OEM-ФУНКЦИЙ И ОБЛАЧНЫХ СЕРВИСОВ" -ForegroundColor Yellow
Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
$null = New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" -Name "SearchOrderConfig" -Type DWord -Value 1 -Force
$null = Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -ErrorAction SilentlyContinue
$null = Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -ErrorAction SilentlyContinue
$null = Remove-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableSilentInstalledApps" -ErrorAction SilentlyContinue

Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Write-Host "2. ВКЛЮЧЕНИЕ ВИДЖЕТОВ, НОВОСТЕЙ И ONEDRIVE" -ForegroundColor Yellow
Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
$null = Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -ErrorAction SilentlyContinue
$null = Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -ErrorAction SilentlyContinue

Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Write-Host "3. ОТКЛЮЧЕНИЕ ПАССИВНОГО РЕЖИМА ДЕФЕНДЕРА" -ForegroundColor Yellow
Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
$null = Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "PassiveMode" -ErrorAction SilentlyContinue

Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Write-Host "4. ВОССТАНОВЛЕНИЕ УДАЛЕННОГО МУСОРА ИЗ СИСТЕМЫ" -ForegroundColor Yellow
Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Write-Host "Примечание: Удаленные UWP-приложения (Clipchamp и др.) восстанавливаются только через Microsoft Store." -ForegroundColor Gray

Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Write-Host "5. ВОССТАНОВЛЕНИЕ СЛУЖБ XBOX И ИГРОВОГО МОНИТОРИНГА" -ForegroundColor Yellow
Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
$null = Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -ErrorAction SilentlyContinue

@('XblAuthManager', 'XblGameSave', 'XboxNetApiSvc', 'XboxGipSvc') | ForEach-Object {
    Set-Service -Name $_ -StartupType Manual -ErrorAction SilentlyContinue
}

Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Write-Host "6. ВКЛЮЧЕНИЕ ЗАДАЧ В КОРНЕ ПЛАНИРОВЩИКА (UPDATER, WINSAT)" -ForegroundColor Yellow
Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Get-ScheduledTask -TaskPath '\' | Where-Object {$_.TaskName -like '*Update*' -or $_.TaskName -like '*Helper*' -or $_.TaskName -like '*WinSAT*'} | ForEach-Object {Enable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}

Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Write-Host "7. МАССОВОЕ ВОССТАНОВЛЕНИЕ ЗАДАЧ В СИСТЕМНЫХ ПАПКАХ" -ForegroundColor Yellow
Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow

$Paths = @(
    "\Microsoft\Windows\Application Experience\", "\Microsoft\Windows\Customer Experience Improvement Program\", 
    "\Microsoft\Windows\DiskDiagnostic\", "\Microsoft\Windows\Autochk\", "\Microsoft\Windows\Maps\", 
    "\Microsoft\Windows\Power Efficiency Diagnostics\", "\Microsoft\Windows\Bluetooth\", "\Microsoft\Windows\BitLocker\", 
    "\Microsoft\Windows\CloudExperienceHost\", "\Microsoft\Windows\CloudRestore\", "\Microsoft\Windows\Defrag\", 
    "\Microsoft\Windows\Device Setup\", "\Microsoft\Windows\DeviceDirectoryClient\", "\Microsoft\Windows\Diagnosis\", 
    "\Microsoft\Windows\DirectX\", "\Microsoft\Windows\DiskCleanup\", "\Microsoft\Windows\DiskFootprint\", 
    "\Microsoft\Windows\DUSM\", "\Microsoft\Windows\EDP\", "\Microsoft\Windows\File Classification Infrastructure\", 
    "\Microsoft\Windows\FileHistory\", "\Microsoft\Windows\Flighting\", "\Microsoft\Windows\HelloFace\", 
    "\Microsoft\Windows\InstallService\", "\Microsoft\Windows\LanguageComponentInstaller\", "\Microsoft\Windows\LicenseManager\", 
    "\Microsoft\Windows\Live\Roaming\", "\Microsoft\Windows\Location\", "\Microsoft\Windows\Maintenance\", 
    "\Microsoft\Windows\Management\", "\Microsoft\Windows\MobileBroadbandAccounts\", "\Microsoft\Windows\MUI\", 
    "\Microsoft\Windows\NetTrace\", "\Microsoft\Windows\NlaSvc\", "\Microsoft\Windows\OfflineFiles\", 
    "\Microsoft\Windows\PushToInstall\", "\Microsoft\Windows\RecoveryEnvironment\", "\Microsoft\Windows\Registry\", 
    "\Microsoft\Windows\RemoteAssistance\", "\Microsoft\Windows\SettingSync\", "\Microsoft\Windows\SharedPC\", "\Microsoft\Office\",
    "\Microsoft\Windows\SpacePort\", "\Microsoft\Windows\Speech\", "\Microsoft\Windows\TextServicesFramework\", 
    "\Microsoft\Windows\TPM\", "\Microsoft\Windows\UPnP\", "\Microsoft\Windows\User Profile Service\", 
    "\Microsoft\Windows\WaaSMedicCenter\", "\Microsoft\Windows\Wallet\", "\Microsoft\Windows\WCM\", "\Microsoft\Windows\WDI\", 
    "\Microsoft\Windows\WebBlends\", "\Microsoft\Windows\Windows Error Reporting\", "\Microsoft\Windows\Windows Filtering Platform\", 
    "\Microsoft\Windows\Windows Media Sharing\", "\Microsoft\Windows\WorkFolders\"
)

foreach ($Path in $Paths) {
    Get-ScheduledTask -TaskPath $Path -ErrorAction SilentlyContinue | ForEach-Object {Enable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
}

Get-ScheduledTask | Where-Object {$_.TaskName -like '*edgeupdate*'} | ForEach-Object {Enable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\Feedback\Siuf\' -ErrorAction SilentlyContinue | ForEach-Object {Enable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\ExploitGuard\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -eq 'ExploitGuard MDM policy refresh'} | ForEach-Object {Enable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\Input\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -ne 'MsCtfMonitor'} | ForEach-Object {Enable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\PI\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -eq 'SQMTasks'} | ForEach-Object {Enable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\Printing\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -eq 'EduPrintProv'} | ForEach-Object {Enable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\RAS\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -eq 'MobilityManager'} | ForEach-Object {Enable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\Shell\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -eq 'IndexerAutomaticMaintenance'} | ForEach-Object {Enable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\SoftwareProtectionPlatform\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -eq 'SvcRestartTask'} | ForEach-Object {Enable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\SysMain\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -eq 'WsSwapAssessmentTask'} | ForEach-Object {Enable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -eq 'ReportPolicies'} | ForEach-Object {Enable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}
Get-ScheduledTask -TaskPath '\Microsoft\Windows\WindowsUpdate\' -ErrorAction SilentlyContinue | Where-Object {$_.TaskName -eq 'Scheduled Start'} | ForEach-Object {Enable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue}

Write-Host "-----------------------------------------------------------" -ForegroundColor Green
Write-Host "Восстановление завершено успешно! Перезагрузка через 10 секунд..." -ForegroundColor Green
Write-Host "-----------------------------------------------------------" -ForegroundColor Green
Start-Sleep -Seconds 10
Restart-Computer -Force
