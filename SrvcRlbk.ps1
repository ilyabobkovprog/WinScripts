# Запрос прав администратора без использования кавычек внутри кавычек
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process "$psHome\powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
} 

Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Write-Host "1. ВОССТАНОВЛЕНИЕ ИГРОВЫХ СЛУЖБ И XBOX" -ForegroundColor Yellow
Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Set-Service -Name 'XblAuthManager' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'XblGameSave' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'XboxGipSvc' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'XboxNetApiSvc' -StartupType Manual -ErrorAction SilentlyContinue

Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Write-Host "2. ВОССТАНОВЛЕНИЕ СЛУЖБ ОБНОВЛЕНИЯ СТОРОННЕГО СОФТА" -ForegroundColor Yellow
Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Set-Service -Name 'AdobeARMservice' -StartupType Automatic -ErrorAction SilentlyContinue
Set-Service -Name 'AGSService' -StartupType Automatic -ErrorAction SilentlyContinue
Set-Service -Name 'GoogleChromeElevationService' -StartupType Manual -ErrorAction SilentlyContinue
Get-Service -Name 'GoogleUpdater*' -ErrorAction SilentlyContinue | ForEach-Object {sc.exe config $_.Name start= auto}
Set-Service -Name 'gupdate' -StartupType Automatic -ErrorAction SilentlyContinue
Set-Service -Name 'gupdatem' -StartupType Manual -ErrorAction SilentlyContinue

Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Write-Host "3. ВОССТАНОВЛЕНИЕ СИСТЕМНЫХ СЛУЖБ WINDOWS" -ForegroundColor Yellow
Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Set-Service -Name 'AJRouter' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'AppVClient' -StartupType Disabled -ErrorAction SilentlyContinue
Set-Service -Name 'WbioSrvc' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'RetailDemo' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'Fax' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'RemoteRegistry' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'MapsBroker' -StartupType AutomaticDelayStart -ErrorAction SilentlyContinue
Set-Service -Name 'WalletService' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'WpcMonSvc' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'workfolderssvc' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'WMPNetworkSvc' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'lfsvc' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'shpamsvc' -StartupType Disabled -ErrorAction SilentlyContinue
Set-Service -Name 'PcaSvc' -StartupType Automatic -ErrorAction SilentlyContinue
Set-Service -Name 'DisplayEnhancementService' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'ssh-agent' -StartupType Disabled -ErrorAction SilentlyContinue
Set-Service -Name 'cloudidsvc' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'NaturalAuthentication' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'PhoneSvc' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'SmsRouter' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'wlidsvc' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'CDPSvc' -StartupType Automatic -ErrorAction SilentlyContinue
Set-Service -Name 'bthserv' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'BTAGService' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'BthAvctpSvc' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'SharedAccess' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'icssvc' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'WinRM' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'WManSvc' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'MSiSCSI' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'SNMPTrap' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'PNRPsvc' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'PNRPAutoReg' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'p2psvc' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'p2pimsvc' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'lltdsvc' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'cphc' -StartupType Manual -ErrorAction SilentlyContinue
Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\OneSyncSvc*" -ErrorAction SilentlyContinue | ForEach-Object {Set-ItemProperty -Path $_.PsPath -Name "Start" -Value 2 -ErrorAction SilentlyContinue}
Set-Service -Name 'camsvc' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'TabletInputService' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'InstallService' -StartupType Manual -ErrorAction SilentlyContinue

Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Write-Host "4. ВОССТАНОВЛЕНИЕ ТЕЛЕМЕТРИИ И ОТЧЕТОВ ОБ ОШИБКАХ" -ForegroundColor Yellow
Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Set-Service -Name 'DiagTrack' -StartupType Automatic -ErrorAction SilentlyContinue
Set-Service -Name 'dmwappushservice' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'WerSvc' -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name 'wercplsupport' -StartupType Manual -ErrorAction SilentlyContinue

Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Write-Host "5. ВОССТАНОВЛЕНИЕ СЛУЖБЫ UPDATE HEALTH SERVICE" -ForegroundColor Yellow
Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow
Set-Service -Name 'uhssvc' -StartupType Manual -ErrorAction SilentlyContinue

Write-Host "-----------------------------------------------------------" -ForegroundColor Green
Write-Host "Восстановление служб завершено успешно! Перезагрузка через 10 сек..." -ForegroundColor Green
Write-Host "-----------------------------------------------------------" -ForegroundColor Green
Start-Sleep -Seconds 10
Restart-Computer -Force
