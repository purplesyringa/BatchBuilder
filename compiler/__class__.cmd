if "%1" == "new" (
	set __instance_id__=__instance_%RANDOM%%RANDOM%%RANDOM%__
)
if "%1" == "new" (
	set %__instance_id__%.__type__=%~3
	call set %__instance_id__%.__origin__=%%__class_%~3_origin__%%

	set "%~2=%__instance_id__%"

	exit /b
)

if not "%1" == "batchbuilder" (
	echo __class__ cannot be called directly.
	exit /b 1
)