@echo off
setlocal ENABLEDELAYEDEXPANSION

set __directive_safe_recursion__=export
call :unset_directives all

set exporting=BOGUS

for /F "tokens=1,* eol=" %%a IN ('type %1') do (
	if "%%a" == "export" (
		call :check_directives "%%a %%b" raw export
		if not "!ERRORLEVEL!" == "0" (
			exit /b !ERRORLEVEL!
		)

		call :unset_directives export

		call :export_handler %1 %2 "%%a" "%%b"
	) else (
		if "%%a" == "return" (
			rem return A
			rem ->
			rem if defined __return__ echo "%__return__%=A" >>%__local_storage__%
			rem exit /b

			call :check_directives "%%a %%b" raw
			if not "!ERRORLEVEL!" == "0" (
				exit /b !ERRORLEVEL!
			)

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

			echo set __return_value__=%%~b
			type %~dp0after_exported.cmd
			echo exit /b
		) else (
			if "%%a" == "global" (
				rem global A=B
				rem ->
				rem set A=B
				rem echo A=B>>%__global_storage__%
				rem echo A=B>>%__local_storage__%

				call :check_directives "%%a %%b" raw
				if not "!ERRORLEVEL!" == "0" (
					exit /b !ERRORLEVEL!
				)

				echo set %%b
				echo echo %%b^>^>%%__global_storage__%%

				if not "!exporting!" == "BOGUS" (
					echo echo %%b^>^>%%__local_storage__%%
				)
			) else (
				if "%%a" == "@directive" (
					rem @directive DIR1 DIR2
					for %%d in (%%b) do (
						set directive=%%d
						set value=yes
						if "!directive:~0,1!" == "-" (
							set directive=!directive:~1!
							set value=
						)

						if defined __directive_!directive!__ (
							set __active_directive_!directive!__=!value!
						) else (
							echo Directive @!directive! does not exist >&2
							exit /b 1
						)
					)
				) else (
					set is_end_export=no
					if "%%a" == "end" if "%%b" == "export" (
						set is_end_export=yes
					)
					if "!is_end_export!" == "yes" (
						call :check_directives "%%a %%b" raw
						if not "!ERRORLEVEL!" == "0" (
							exit /b !ERRORLEVEL!
						)

						call :end_export_handler %1 %2 "%%a" "%%b"
					) else (
						call :check_directives "%%a %%b" raw
						if not "!ERRORLEVEL!" == "0" (
							exit /b !ERRORLEVEL!
						)

						setlocal DISABLEDELAYEDEXPANSION
						echo %%a %%b
						endlocal
					)
				)
			)
		)
	)
)

call :check_directives "EOF" raw

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

:check_directives
	for /F "tokens=1,* delims==" %%f in ('set __active_directive 2^>nul') do (
		set name=%%f
		set name=!name:__active_directive_=!
		set name=!name:~0,-2!

		for %%n in (!name!) do (
			if not "!__directive_%%n__!" == "%~2" (
				if not "!__directive_%%n__!" == "%~3" (
					if not "!__directive_%%n__!" == "%~4" (
						if not "!__directive_%%n__!" == "%~5" (
							if not "!__directive_%%n__!" == "%~6" (
								echo Hanging directive @%%n: was used before "%~1", though was expected before "!__directive_%%n__!" >&2
								exit /b 1
							)
						)
					)
				)
			)
		)
	)

	exit /b

:unset_directives
	for /F "tokens=1,* delims==" %%f in ('set __active_directive 2^>nul') do (
		set name=%%f
		set name=!name:__active_directive_=!
		set name=!name:~0,-2!

		for %%n in (!name!) do (
			if "!__directive_%%n__!" == "%~1" (
				set %%f=
			)
			if "%~1" == "all" (
				set %%f=
			)
		)
	)

	exit /b