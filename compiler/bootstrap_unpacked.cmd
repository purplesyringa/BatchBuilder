if "%settings_temp%" == "no" (
	set tmp=%~dp0\session_%RANDOM%%RANDOM%%RANDOM%
) else (
	set tmp=%TEMP%\%RANDOM%%RANDOM%%RANDOM%
)
mkdir %tmp% >nul 2>nul

robocopy "%~dp0contents" "%tmp%\contents" /E >nul 2>nul

"%tmp%\contents\%settings_entry%"