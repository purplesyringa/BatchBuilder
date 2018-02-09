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
		rem import A
		rem import -> return A
		rem ->
		rem call %origin% :batchbuilder_end_export_A

		if "%%b" == "->" (
			set import=%%d
			set to=%%c
			set args=%%e
		) else (
			set import=%%b
			set to=
			set args=%%c %%d %%e
		)

		:: Check that this was exported ::
			if not exist "%~dp0..\info\exports\!import!" (
				echo Cannot import !import!: not defined anywhere >&2
				exit /b 1
			)

		:: Assert that procedure's result isn't saved and function's result is saved ::
			<"%~dp0..\info\exports_has_return\!import!" set /p has_return=
			if "!has_return!" == "yes" (
				if "!to!" == "" (
					echo Warning: The return value of !import! should be probably utilized>&2
				)
			) else (
				if not "!to!" == "" (
					echo Warning: !import! is a procedure, though the return value was saved to !to!>&2
				)
			)

		<"%~dp0..\info\exports\!import!" set /p origin=

		echo call %%^^~dp0!origin! batchbuilder batchbuilder_export_!import! "!to!" !args!
	) else (
		setlocal DISABLEDELAYEDEXPANSION
		echo %%a %%b %%c %%d %%e
		endlocal
	)
)