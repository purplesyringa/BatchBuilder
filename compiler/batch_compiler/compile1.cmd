@echo off
setlocal ENABLEDELAYEDEXPANSION

set exporting=BOGUS

for /F "tokens=1,* eol=" %%a IN ('type %1') do (
	if "%%a" == "export" (
		call :export_handler %1 %2 "%%a" "%%b"
	) else (
		if "%%a" == "end" (
			if "%%b" == "export" (
				call :end_export_handler %1 %2 "%%a" "%%b"
			) else (
				echo %%a %%b
			)
		) else (
			echo %%a %%b
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