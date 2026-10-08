# WinScripts

Набор PowerShell-скриптов для настройки и очистки Windows 11, удаления отдельных встроенных приложений и возврата части системных параметров. Это не единая программа: каждый `.ps1` запускается отдельно и может вносить изменения в службы, реестр, задачи планировщика и установленные приложения.

## Содержание

- [Описание скриптов](#описание-скриптов)
- [Запуск](#запуск)
- [Важные предупреждения](#важные-предупреждения)
- [Текстовые файлы](#текстовые-файлы)
- [Scripts](#scripts)
- [Running scripts](#running-scripts)
- [Important warnings](#important-warnings)
- [Text files](#text-files)

## Описание скриптов

| Файл | Назначение |
| --- | --- |
| `1SD.ps1` | Глубокая очистка Windows 11. Удаляет выбранные встроенные приложения (в том числе Xbox, Bing, Copilot, Clipchamp и OneDrive), отключает множество служб и задач планировщика, меняет параметры реестра и очищает OneDrive текущего пользователя. Перед выполнением просит подтвердить наличие точки восстановления. |
| `2TD.ps1` | Перед запуском просит подтвердить наличие точки восстановления. Изменяет настройки установки OEM-приложений и облачного содержимого, отключает виджеты и синхронизацию OneDrive, удаляет некоторые встроенные приложения, отключает игровые службы и задачи. Также включает пассивный режим Microsoft Defender и добавляет исключения для некоторых папок Kaspersky Lab/NCALayer, если они существуют. |
| `tskrlbk.ps1` | Частично возвращает настройки, затронутые очисткой: сбрасывает ряд политик, включает задачи планировщика и возвращает некоторые службы Xbox в ручной режим. Удалённые UWP-приложения этот скрипт не устанавливает — для них потребуется Microsoft Store. В конце автоматически перезагружает компьютер. |
| `SrvcRlbk.ps1` | Устанавливает режим запуска для набора служб Windows, Xbox, обновлений сторонних программ и телеметрии. Через 10 секунд автоматически перезагружает компьютер. |
| `xbox.ps1` | Удаляет приложение Xbox Gaming App из системного шаблона и профилей пользователей, чистит соответствующие записи автозапуска в профиле Default и перезапускает Проводник. |
| `MS Bing.ps1` | Удаляет пакеты Bing Search, News и Weather из шаблона Windows и профилей пользователей, отключает интеграцию веб-поиска Bing через параметры реестра и перезапускает Проводник. |
| `copilot.ps1` | Удаляет связанные с Copilot пакеты, задаёт системные и пользовательские параметры политики/интерфейса, удаляет определённые задачи планировщика и перезапускает Проводник. |
| `onedrive.ps1` | Меняет шаблон профиля Default, чтобы отключить автозапуск OneDrive и показ Copilot/рекламируемого содержимого для новых пользователей. Для текущего пользователя завершает процессы OneDrive, запускает встроенное удаление (если доступно), удаляет записи автозапуска и остаточные папки профиля. |

## Запуск

Скрипты предназначены для Windows и требуют PowerShell. Запускайте PowerShell **от имени администратора**, предварительно прочитав содержимое выбранного скрипта.

Если политика выполнения блокирует запуск, разрешение можно временно установить только для текущего окна PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

Затем перейдите в папку со скриптами и запустите только нужный файл, например:

```powershell
.\1SD.ps1
```

Для имени файла с пробелом:

```powershell
& ".\MS Bing.ps1"
```

## Важные предупреждения

- Скрипты могут удалять приложения для всех пользователей и из шаблона установки, отключать системные и сторонние службы, планировщик задач и менять машинные/пользовательские параметры реестра.
- `1SD.ps1` — особенно масштабный сценарий. `1SD.ps1` и `2TD.ps1` просят подтвердить наличие точки восстановления, но не создают её. Создайте и проверьте точку восстановления и резервную копию важных данных до запуска.
- `2TD.ps1` переводит Microsoft Defender в пассивный режим и может добавить исключения для каталогов. Это влияет на защиту системы; проверьте, что другой антивирус установлен и работает, прежде чем запускать этот сценарий.
- `tskrlbk.ps1` и `SrvcRlbk.ps1` не гарантируют полного восстановления исходного состояния. В частности, удалённые приложения могут потребовать повторной установки, а у `SrvcRlbk.ps1` параметры служб задаются явно, а не считываются из резервной копии.
- `tskrlbk.ps1` и `SrvcRlbk.ps1` перезагружают компьютер автоматически. Сохраните работу перед запуском.
- Для проверки результата и восстановления отдельных функций изучите команды скриптов заранее. Не запускайте подряд все файлы: некоторые из них выполняют противоположные операции.

## Текстовые файлы

- `howto.txt` содержит краткие инструкции по Execution Policy, но ссылается на `services_rollback.ps1`, которого нет в репозитории, и не приводит саму команду для снятия ограничения. Используйте фактические имена файлов из таблицы выше.
- `новый 1.txt` — текст ошибки PowerShell, а не скрипт. В нём записан сбой команды удаления provisioned-пакета из-за некорректного значения `-ErrorAction` (`SilentlyContinue/`).

---

## Scripts

A collection of PowerShell scripts for configuring and cleaning Windows 11, removing selected built-in apps, and restoring some system settings. This is not a single application: each `.ps1` file is run separately and may modify services, the registry, scheduled tasks, and installed apps.

## Script descriptions

| File | Purpose |
| --- | --- |
| `1SD.ps1` | Deep Windows 11 cleanup. Removes selected built-in apps (including Xbox, Bing, Copilot, Clipchamp, and OneDrive), disables many services and scheduled tasks, changes registry settings, and cleans OneDrive for the current user. Prompts for confirmation that a restore point exists before proceeding. |
| `2TD.ps1` | Prompts for confirmation that a restore point exists before proceeding. Changes OEM-app and cloud-content settings, disables Widgets and OneDrive sync, removes selected built-in apps, and disables gaming services and scheduled tasks. It also enables Microsoft Defender passive mode and adds exclusions for certain Kaspersky Lab/NCALayer folders if they exist. |
| `tskrlbk.ps1` | Partially restores settings affected by cleanup: removes some policy values, enables scheduled tasks, and sets some Xbox services to Manual. It does not reinstall removed UWP apps; those may need to be restored through Microsoft Store. Automatically restarts the computer when finished. |
| `SrvcRlbk.ps1` | Sets startup modes for a collection of Windows, Xbox, third-party updater, and telemetry services. Automatically restarts the computer after 10 seconds. |
| `xbox.ps1` | Removes the Xbox Gaming App from the Windows provisioned image and user profiles, cleans related startup entries in the Default profile, and restarts Explorer. |
| `MS Bing.ps1` | Removes Bing Search, News, and Weather packages from the Windows image and user profiles, disables Bing web-search integration through registry settings, and restarts Explorer. |
| `copilot.ps1` | Removes Copilot-related packages, sets system and per-user policy/UI settings, deletes selected scheduled tasks, and restarts Explorer. |
| `onedrive.ps1` | Edits the Default profile template to disable OneDrive startup and Copilot/promotional content for new users. For the current user, stops OneDrive processes, runs its built-in uninstaller if available, removes startup entries, and deletes remaining profile folders. |

## Running scripts

These scripts are intended for Windows and require PowerShell. Run PowerShell **as Administrator** and review the selected script before executing it.

If the execution policy blocks the script, you can temporarily allow scripts in the current PowerShell window only:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

Then change to the scripts directory and run only the desired file, for example:

```powershell
.\1SD.ps1
```

For a filename containing spaces:

```powershell
& ".\MS Bing.ps1"
```

## Important warnings

- Scripts may remove apps for all users and from the provisioned Windows image, disable Windows or third-party services and scheduled tasks, and change machine-wide or per-user registry settings.
- `1SD.ps1` is especially broad. Both `1SD.ps1` and `2TD.ps1` ask you to confirm that a restore point exists, but neither creates one. Create and verify a restore point and back up important data before running either script.
- `2TD.ps1` puts Microsoft Defender into passive mode and may add folder exclusions. This affects system protection; make sure another antivirus is installed and working before running this script.
- `tskrlbk.ps1` and `SrvcRlbk.ps1` do not guarantee a complete restoration of the original system state. Removed apps may need to be reinstalled, and `SrvcRlbk.ps1` sets explicit service startup modes rather than restoring values from a backup.
- `tskrlbk.ps1` and `SrvcRlbk.ps1` restart the computer automatically. Save your work before running them.
- Review the commands before execution and do not run every file in sequence: some scripts perform opposing operations.

## Text files

- `howto.txt` contains brief Execution Policy instructions, but refers to `services_rollback.ps1`, which is not present in the repository, and does not include the command to change the policy. Use the actual filenames listed above.
- `новый 1.txt` is a PowerShell error message, not a script. It records a provisioned-package removal failure caused by an invalid `-ErrorAction` value (`SilentlyContinue/`).
