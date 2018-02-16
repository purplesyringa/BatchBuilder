rem Clean
for /F "tokens=1,* delims==" %%a IN ('set') do (
	if not "%%a" == "__local_storage__" (
		if not "%%a" == "__global_storage__" (
			setlocal ENABLEDELAYEDEXPANSION
			set a=%%a
			if not "!a:~0,9!" == "__return_" (
				if not "!a:~0,11!" == "__instance_" (
					if not "!a:~0,8!" == "__class_" (
						endlocal & set %%a=
					) else (
						endlocal
					)
				) else (
					endlocal
				)
			) else (
				endlocal
			)
		)
	)
)

rem Restore prev local
for /F "tokens=1* delims==" %%a IN ('type %__local_storage__%') do (
	if not "%%a" == "__return_recursion__" (
		if not "%%a" == "__return_value__" (
			set "%%a=%%b"
		)
	)
)

if defined __return_%__return_recursion__%__ (
	call set "%%__return_%__return_recursion__%__%%=%%__return_value__%%"
)
set /a "__return_recursion__=%__return_recursion__%-1"
