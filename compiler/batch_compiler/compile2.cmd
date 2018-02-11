@echo off
setlocal ENABLEDELAYEDEXPANSION

:: First add CALL handler ::
	echo set __callee__=%%2
	echo if "%%1" == "batchbuilder" (
	echo set /a __return_recursion__=%%__return_recursion__%% + 1
	echo )
	echo if "%%1" == "batchbuilder" (
	echo set __return_%%__return_recursion__%%__=%%~3
	echo shift /1
	echo shift /1
	echo shift /1
	echo if defined __return_%%__return_recursion__%%__ (
	echo call set %%%%__return_%%__return_recursion__%%__%%%%=
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
		if "%%a" == "new" (
			rem new -> A B

			if not "%%b" == "->" (
				echo It makes no sense to create an instance of class "%%b" and don't save it to a variable. Use "new -> var Class" syntax instead>&2
				exit /b 1
			)

			echo set %%c=__instance_%%d__
		) else (
			setlocal DISABLEDELAYEDEXPANSION
			echo %%a %%b %%c %%d %%e
			endlocal
		)
	)
)