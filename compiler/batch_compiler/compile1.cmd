@echo off
setlocal ENABLEDELAYEDEXPANSION

set exporting=BOGUS

for /F "tokens=1,* eol=" %%a IN ('type %1') do (
	if "%%a" == "export" (
		call :export_handler %1 %2 "%%a" "%%b"
	) else (
		if "%%a" == "return" (
			rem return A
			rem ->
			rem if defined __return__ set %__return__%=A
			rem exit /b

			:: Make sure something is exported at the moment ::
				if "!exporting!" == "BOGUS" (
					echo Return outside export >&2
					exit /b 1
				)

			echo if defined __return__ set "%%__return__%%=%%~b"
			echo exit /b
		) else (
			if "%%a" == "end" (
				if "%%b" == "export" (
					call :end_export_handler %1 %2 "%%a" "%%b"
				) else (
					setlocal DISABLEDELAYEDEXPANSION
					echo %%a %%b
					endlocal
				)
			) else (
				setlocal DISABLEDELAYEDEXPANSION
				echo %%a %%b
				endlocal
			)
		)
	)
)

:: Make sure nothing is exported at the moment ::
	if not "!exporting!" == "BOGUS" (
		echo No "end export" after "export !exporting!" >&2
		exit /b 1
	)

exit /b


:export_handler
	rem export A
	rem ->
	rem goto :batchbuilder_end_export_A
	rem :batchbuilder_export_A

	:: Make sure nothing is exported at the moment ::
		if not "!exporting!" == "BOGUS" (
			echo Export of %~4 inside export of !exporting! >&2
			exit /b 1
		)

		set exporting=%~4

	:: Check that this was not exported yet ::
		if exist "%~dp0..\info\exports\%~4" (
			<%~dp0..\info\exports\%~4 set /p origin=
			echo Second export of %~4: first export in !origin! >&2
			exit /b 1
		)

		echo %~2>"%~dp0..\info\exports\%~4"

	echo goto :batchbuilder_end_export_%~4
	echo :batchbuilder_export_%~4
	type %~dp0before_exported.cmd

	exit /b

:end_export_handler
	rem end export
	rem ->
	rem exit /b
	rem :batchbuilder_end_export_%exporting%

	echo exit /b
	echo :batchbuilder_end_export_!exporting!

	:: Make sure something is exported at the moment ::
		if "!exporting!" == "BOGUS" (
			echo Trying to end no export >&2
			exit /b 1
		)

		set exporting=BOGUS

	exit /b

:return_handler
	rem return A
	rem ->
	rem set %__return__%=A
	rem exit /b

	:: Make sure something is exported at the moment ::
		if "!exporting!" == "BOGUS" (
			echo Return outside export >&2
			exit /b 1
		)

	echo set %%__return__%%=%~4
	echo exit /b

	exit /b