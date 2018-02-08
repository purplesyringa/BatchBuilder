@echo off
setlocal ENABLEDELAYEDEXPANSION

:: First add CALL handler ::
	echo set __callee__=%%2
	echo if "%%1" == "batchbuilder" (
	echo shift /1
	echo shift /1
	echo goto %%__callee__%%
	echo )
	echo set __callee__=

for /F "tokens=1,2,* eol=" %%a IN ('type %1') do (
	echo %%a %%b %%c >&2
	if "%%a" == "import" (
		call :import_handler %1 %2 "%%a" "%%b" "%%c"
	) else (
		echo %%a %%b %%c
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

	echo call %%~dp0%origin% batchbuilder batchbuilder_export_%~4 %~5

	exit /b