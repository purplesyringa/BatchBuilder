@echo off
setlocal ENABLEDELAYEDEXPANSION

:: First add CALL handler ::
	echo set __callee__=%%2
	echo set __return__=%%~3
	echo if "%%1" == "batchbuilder" (
	echo shift /1
	echo shift /1
	echo shift /1
	echo if defined __return__ (
	echo set %%__return__%%=
	echo )
	echo goto %%__callee__%%
	echo )
	echo set __callee__=
	echo set __return__=

for /F "tokens=1,2,3,4,* eol=" %%a IN ('type %1') do (
	if "%%a" == "import" (
		if "%%b" == "->" (
			call :import_handler "%%d" "%%e" "%%c"
		) else (
			call :import_handler "%%b" "%%c %%d %%e" ""
		)
	) else (
		setlocal DISABLEDELAYEDEXPANSION
		echo %%a %%b %%c %%d %%e
		setlocal ENABLEDELAYEDEXPANSION
	)
)

exit /b


:import_handler
	rem import A
	rem import -> return A
	rem ->
	rem call %origin% :batchbuilder_end_export_A

	:: Check that this was exported ::
		if not exist "%~dp0..\info\exports\%~1" (
			echo Cannot import %~1: not defined anywhere >&2
			exit /b 1
		)

	<"%~dp0..\info\exports\%~1" set /p origin=

	echo call %%~dp0%origin% batchbuilder batchbuilder_export_%~1 %3 %~2

	exit /b