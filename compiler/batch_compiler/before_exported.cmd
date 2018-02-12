set "__new_local_storage__=%TEMP%\%RANDOM%%RANDOM%%RANDOM%.tmp"

rem Save prev local
set >%__new_local_storage__%

set "__local_storage__=%__new_local_storage__%"

rem Clean
for /F "tokens=1,* delims==" %%a IN ('set') do (
	if not "%%a" == "__local_storage__" (
		if not "%%a" == "__global_storage__" (
			if not "%%a" == "this" (
				setlocal ENABLEDELAYEDEXPANSION
				set a=%%a
				if not "!a:~0,9!" == "__return_" (
					if not "!a:~0,11!" == "__instance_" (
						endlocal & set %%a=
					) else (
						endlocal
					)
				) else (
					endlocal
				)
			)
		)
	)
)

rem Set global
for /F "tokens=1* delims==" %%a IN ('type %__global_storage__%') do (
	set "%%a=%%b"
)
