@echo off
setlocal ENABLEDELAYEDEXPANSION

pushd %~dp0

:: Create dist ::
	rmdir /S /Q dist 2>nul
	mkdir dist

	echo 1 >dist\1
	echo 2 >dist\2
	echo @echo off >dist\settings.cmd
	echo rem Built by batchbuilder >>dist\settings.cmd

:: Parse INI
	set settings_entry=entry.cmd
	set settings_delete_compiled=yes
	set settings_compile_if=~-4 .cmd,~-4 .bat

	for /F "tokens=1,* delims==" %%a IN (src\build.ini) do (
		set settings_%%a=%%b
	)

	for /F "tokens=1,* delims==" %%a IN ('set settings_') do (
		echo set %%a=%%b >>dist\settings.cmd
	)

	:: Parse compile_if
		set compile_if_count=0

		for %%i in ("%settings_compile_if:,=" "%") do (
			set i=%%~i
			set value=!i:* =!
			for /F "delims=" %%v in ("!value!") do (
				set key=!i: %%v=!
			)

			set /a compile_if_count=!compile_if_count! + 1
			set compile_if_key_!compile_if_count!=!key!
			set compile_if_value_!compile_if_count!=!value!
		)

:: Compile ::
	rmdir /S /Q compiler\compiled 2>nul
	mkdir compiler\compiled
	mkdir compiler\info
	mkdir compiler\info\exports

	set root=%~dp0src\

	for /R src %%a IN (*) DO (
		set ext=%%a

		set isbat=0
		for /L %%i in (1,1,%compile_if_count%) do (
			for /F "delims=" %%k in ("!compile_if_key_%%i!") do (
				if "!ext:%%k!" == "!compile_if_value_%%i!" (
					set isbat=1
				)
			)
		)

		set relative=%%a
		set relative=!relative:%root%=!

		if "!isbat!" == "1" (
			call "compiler\compile1.cmd" "%%a" "!relative!" >"compiler\compiled\!relative!" 2>compiler\info\log
			if "!ERRORLEVEL!" == "1" (
				echo Compile error in !relative!:
				type compiler\info\log

				rmdir /S /Q compiler\compiled
				rmdir /S /Q compiler\info

				popd
				exit /b
			)
		) else (
			copy "%%a" "compiler\compiled\!relative!"
		)
	)

	set root=%~dp0compiler\compiled\

	for /R compiler\compiled %%a IN (*) DO (
		set ext=%%a
		set ext=!ext:~-4!

		set isbat=0
		for /L %%i in (1,1,%compile_if_count%) do (
			for /F "delims=" %%k in ("!compile_if_key_%%i!") do (
				if "!ext:%%k!" == "!compile_if_value_%%i!" (
					set isbat=1
				)
			)
		)

		set relative=%%a
		set relative=!relative:%root%=!

		if "!isbat!" == "1" (
			move "%%a" "%%a.before_compilation"

			call "compiler\compile2.cmd" "%%a.before_compilation" "!relative!" >"compiler\compiled\!relative!" 2>compiler\info\log
			if "!ERRORLEVEL!" == "1" (
				echo Compile error in !relative!:
				type compiler\info\log

				rmdir /S /Q compiler\compiled
				rmdir /S /Q compiler\info

				popd
				exit /b
			)

			del "%%a.before_compilation"
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

popd