@echo off
setlocal ENABLEDELAYEDEXPANSION

:: Create dist ::
	rmdir /S /Q dist 2>nul
	mkdir dist

	echo 1 >dist\1
	echo 2 >dist\2

:: Compile ::
	rmdir /S /Q compiler\compiled 2>nul
	mkdir compiler\compiled
	mkdir compiler\info
	mkdir compiler\info\exports
	echo.>compiler\info\import_list

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


	:: Always add 2 more files because EXTRACT works with >1 files only ::
	echo "%~dp0dist\1" >>tmp.ddf
	echo "%~dp0dist\2" >>tmp.ddf

	makecab /F tmp.ddf

	rmdir /S /Q compiler\compiled
	rmdir /S /Q compiler\info

	del dist\1
	del dist\2
	del tmp.ddf
	del setup.rpt
	del setup.inf

:: Append CAB to bootstrapper ::
	copy bootstrap.cmd+dist\data.cab /B dist\bootstrap.cmd
	del dist\data.cab