@echo off
chcp 65001 >nul 2>nul
setlocal ENABLEDELAYEDEXPANSION

set browser=%*

:: Get process name ::

	if "%browser%" == "Internet Explorer" (
		set processname=iexplore.exe
	)
	if "%browser%" == "Google Chrome" (
		set processname=chrome.exe
	)
	if "%browser%" == "Mozilla Firefox" (
		set processname=firefox.exe
	)
	if "%browser%" == "Opera" (
		set processname=opera.exe
	)

:: Get full path to executable ::
	wmic process where name="%processname%" get CommandLine >%~dp0tmp

	set process=%processname%
	for /f "skip=1 tokens=*" %%i in ('type "%~dp0tmp"') do (
		set process=%%i
		goto break
	)
	:break

	: Trim right
	for /l %%a in (1,1,5000) do if "!process:~-1!"==" " set process=!process:~0,-1!

	set replaceafter=%process:~1%
	set replaceafter=%replaceafter:*"=%
	if "%replaceafter%" == "" (
		set replaceafter=%RANDOM%
	)
	set process=!process:%replaceafter%=!


:: Close browser ::

	taskkill /im %processname% >nul 2>nul

sleep 4

:: Launch ::
	wscript "%~dp0box.vbs" "Браузер %browser% обновлен. Запустить сейчас?" "%browser%"
	if "%ERRORLEVEL%" == "1" (
		start "" !process!
	)