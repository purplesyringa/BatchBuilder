set "__local_storage__=%TEMP%\%RANDOM%%RANDOM%%RANDOM%.tmp"

rem Save prev local
set >%__local_storage__%

rem Clean
for /F "tokens=1,* delims==" %%a IN ('set') do (
	if not "%%a" == "__local_storage__" (
		if not "%%a" == "__global_storage__" (
			if not "%%a" == "__return__" (
				if not "%%a" == "%__return__%" (
					set %%a=
				)
			)
		)
	)
)

rem Set global
for /F "tokens=* delims==" %%a IN ('type %__global_storage__%') do (
	set "%%a"
)
