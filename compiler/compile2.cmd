@echo off
setlocal ENABLEDELAYEDEXPANSION

:: First add CALL handler ::
	echo if "%%1" == "batchbuilder" (
	echo goto %%2
	echo )

for /F "tokens=1,* eol=" %%a IN ('type %1') do (
	if "%%a" == "import" (
		call :import_handler %1 %2 "%%a" "%%b"
	) else (
		call :raw_handler %1 %2 "%%a" "%%b"
	)
)

exit /b


:import_handler
	rem import A
	rem ->
	rem call %origin% :batchbuilder_end_export_A

	:: Check that this was exported ::
		if not exist "%~dp0info\exports\%~4" (
			echo Cannot import %~4: not defined anywhere >&2
			exit /b 1
		)

	<"%~dp0info\exports\%~4" set /p origin=

	echo call %%~dp0%origin% batchbuilder batchbuilder_export_%~4

	exit /b

:raw_handler
	rem Bypass

	echo %~3 %~4

	exit /b