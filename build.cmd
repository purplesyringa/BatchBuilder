@echo off
setlocal ENABLEDELAYEDEXPANSION

:: Create dist ::
	rmdir /S /Q dist
	mkdir dist

:: Create CAB ::
	echo .OPTION EXPLICIT >tmp.ddf
	echo .Set CabinetNameTemplate=data.cab >>tmp.ddf
	echo .Set Cabinet=on >>tmp.ddf
	echo .Set Compress=on >>tmp.ddf
	echo .Set DiskDirectoryTemplate=dist >>tmp.ddf

	set root=%~dp0src\

	for /R src %%a IN (*) DO (
		set relative=%%a
		set relative=!relative:%root%=!

		echo "%%a" >>tmp.ddf
	)

	makecab /F tmp.ddf

	del tmp.ddf
	del setup.rpt
	del setup.inf

:: Append CAB to bootstrapper ::
	copy bootstrap.cmd+dist\data.cab /B dist\bootstrap.cmd
	del dist\data.cab