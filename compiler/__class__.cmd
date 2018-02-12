if "%1" == "new" (
	set __instance_id__=__instance_%RANDOM%%RANDOM%%RANDOM%__
)
if "%1" == "new" (
	set %__instance_id__%=instance
	set %__instance_id__%.__type__=%~3
	call set %__instance_id__%.__origin__=%%__class_%~3_origin__%%

	set "%~2=%__instance_id__%"

	exit /b
)

if not "%1" == "batchbuilder" (
	echo __class__ cannot be called directly.
	exit /b 1
)



rem Get instance ID and method name
set __instance__=%~2
set __instance__=%__instance__:batchbuilder_export_=%

set __callee__=%~3

if not defined %__instance__% (
	echo Instance %__instance__% is not a real instance of any class.
	exit /b 1
)

rem Detect class
call set __class__=%%%__instance__%.__type__%%
call set __origin__=%%%__instance__%.__origin__%%

shift /1
shift /1
shift /1
shift /1

rem Get all arguments to variable
set params=%1

setlocal ENABLEDELAYEDEXPANSION
set id=0
for %%r in (%*) do (
	if !id! gtr 4 (
		set params=!params! %%r
	)
	set /a id=!id! + 1
)
endlocal & set params=%params%

call %~dp0%__origin__% batchbuilder batchbuilder_export_%__class__%$%__callee__% %params%