rem Save global
set __global_storage__=%TEMP%\%RANDOM%%RANDOM%%RANDOM%.tmp
set >%__global_storage__%

set __return_recursion__=0


if "%settings_packed%" == "local" (
	"%~dp0contents\%settings_entry%"
	exit /b
)

set tmp=%TEMP%\%RANDOM%%RANDOM%%RANDOM%
mkdir %tmp% >nul 2>nul
robocopy "%~dp0contents" "%tmp%\contents" /E >nul 2>nul
"%tmp%\contents\%settings_entry%"