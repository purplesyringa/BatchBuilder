rem Clean
for /F "tokens=1,* delims==" %%a IN ('set') do (
	if not "%%a" == "__local_storage__" (
		if not "%%a" == "__global_storage__" (
			set %%a=
		)
	)
)

rem Restore prev local
for /F "tokens=* delims==" %%a IN ('type %__local_storage__%') do (
	set "%%a"
)
