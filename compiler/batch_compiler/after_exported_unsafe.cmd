rem Save return value
call echo %%__return_value__%% >"%__local_storage__%"

endlocal & set __local_storage__=%__local_storage__%

if defined __return_%__return_recursion__%__ (
	<%__local_storage__% set /p __return_value__=
	call set "%%__return_%__return_recursion__%__%%=%%__return_value__%%"
)
set /a "__return_recursion__=%__return_recursion__%-1"
