echo.>%~dp0..\compiled\__class_list__.cmd

for %%c in (%~dp0..\info\classes\*) do (
	<%%c set /p origin=

	echo set "__class_%%~xnc_origin__=!origin!" >>%~dp0..\compiled\__class_list__.cmd
)