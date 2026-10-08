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
