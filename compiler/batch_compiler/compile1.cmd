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

			:: If something is returned, notice that ::
				set is_empty=no
				if "%%b" == "" (
					set is_empty=yes
				)
				if "!is_empty!" == "no" (
					echo yes>"%~dp0..\info\exports_has_return\!exporting!"
				)

			type %~dp0after_exported.cmd
			echo if defined __return__ set "%%__return__%%=%%~b"
			echo exit /b
		) else (
			if "%%a" == "global" (
				rem global A=B
				rem ->
				rem set A=B
				rem echo A=B>>%__global_storage__%
				rem echo A=B>>%__local_storage__%

				echo set %%b
				echo echo %%b^>^>%%__global_storage__%%

				if not "!exporting!" == "BOGUS" (
					echo echo %%b^>^>%%__local_storage__%%
				)
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
		echo no>"%~dp0..\info\exports_has_return\%~4"

	echo goto :batchbuilder_end_export_%~4
	echo :batchbuilder_export_%~4
	type %~dp0before_exported.cmd

	exit /b

:end_export_handler
	rem end export
	rem ->
	rem exit /b
	rem :batchbuilder_end_export_%exporting%

	type %~dp0after_exported.cmd
	echo exit /b
	echo :batchbuilder_end_export_!exporting!

	:: Make sure something is exported at the moment ::
		if "!exporting!" == "BOGUS" (
			echo Trying to end no export >&2
			exit /b 1
		)

		set exporting=BOGUS

	exit /b