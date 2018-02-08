@echo off
setlocal ENABLEDELAYEDEXPANSION

:: Create dist ::
	rmdir /S /Q dist 2>nul
	mkdir dist

	echo 1 >dist\1
	echo 2 >dist\2
	echo @echo off >dist\settings.cmd

:: Parse INI
	set settings_entry=entry.cmd
	set settings_delete_compiled=yes

	for /F "tokens=1,* delims==" %%a IN (src\build.ini) do (
		set settings_%%a=%%b
	)

	for /F "tokens=1,* delims==" %%a IN ('set settings_') do (
		echo set %%a=%%b >>dist\settings.cmd
	)

:: Compile ::
	rmdir /S /Q compiler\compiled 2>nul
	mkdir compiler\compiled
	mkdir compiler\info
	mkdir compiler\info\exports

	set root=%~dp0src\

	for /R src %%a IN (*) DO (
		set relative=%%a
		set relative=!relative:%root%=!

		call "%~dp0compiler\compile1.cmd" "%%a" "!relative!" >"compiler\compiled\!relative!" 2>compiler\info\log
		if "!ERRORLEVEL!" == "1" (
			echo Compile error in !relative!:
			type compiler\info\log

			rmdir /S /Q compiler\compiled
			rmdir /S /Q compiler\info
			exit /b
		)
	)

	set root=%~dp0compiler\compiled\

	for /R compiler\compiled %%a IN (*) DO (
		set relative=%%a
		set relative=!relative:%root%=!

		move "%%a" "%%a.before_compilation"

		call "%~dp0compiler\compile2.cmd" "%%a.before_compilation" "!relative!" >"compiler\compiled\!relative!" 2>compiler\info\log
		if "!ERRORLEVEL!" == "1" (
			echo Compile error in !relative!:
			type compiler\info\log

			rmdir /S /Q compiler\compiled
			rmdir /S /Q compiler\info
			exit /b
		)

		del "%%a.before_compilation"
	)

:: Create CAB ::
	echo .OPTION EXPLICIT >tmp.ddf
	echo .Set CabinetNameTemplate=data.cab >>tmp.ddf
	echo .Set Cabinet=on >>tmp.ddf
	echo .Set Compress=on >>tmp.ddf
	echo .Set DiskDirectoryTemplate=dist >>tmp.ddf

	set root=%~dp0compiler\compiled\
	for /R compiler\compiled %%a IN (*) DO (
		set relative=%%a
		set relative=!relative:%root%=!

		echo "%%a" >>tmp.ddf
	)


	:: Always add 2 more files because EXPAND works with >1 files only ::
	echo "%~dp0dist\1" >>tmp.ddf
	echo "%~dp0dist\2" >>tmp.ddf

	makecab /F tmp.ddf

	if not "%settings_delete_compiled%" == "no" (
		rmdir /S /Q compiler\compiled
	)
	rmdir /S /Q compiler\info

	del dist\1
	del dist\2
	del tmp.ddf
	del setup.rpt
	del setup.inf

:: Append CAB to bootstrapper ::
	copy dist\settings.cmd+bootstrap.cmd+dist\data.cab /B dist\bootstrap.cmd
	del dist\settings.cmd
	del dist\data.cab