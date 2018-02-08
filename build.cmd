@echo off
setlocal ENABLEDELAYEDEXPANSION

pushd %~dp0

if not exist "src" (
	echo No src directory found. Make sure build.cmd is in the same directory as src.
	echo If you want to create a new project, use create-project.cmd instead.
	exit /b
)

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
	set settings_compile_if=batch ~-4 .cmd,batch ~-4 .bat
	set settings_packed=yes

	for /F "tokens=1,* delims==" %%a IN (src\build.ini) do (
		set settings_%%a=%%b
	)

	for /F "tokens=1,* delims==" %%a IN ('set settings_') do (
		echo set %%a=%%b>>dist\settings.cmd
	)

	:: Parse compile_if
		set compile_if_count=0

		for %%i in ("%settings_compile_if:,=" "%") do (
			set i=%%~i
			for /F "tokens=1* delims= " %%u in ("!i:* =!") do (
				set key=%%u
				set value=%%v
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
			call "compiler\batch_compiler\compile1.cmd" "%%a" "!relative!" >"compiler\compiled\!relative!" 2>compiler\info\log
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

			call "compiler\batch_compiler\compile2.cmd" "%%a.before_compilation" "!relative!" >"compiler\compiled\!relative!" 2>compiler\info\log
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

if "%settings_packed%" == "local" (
	set settings_packed=no
)

if "%settings_packed%" == "no" (
	:: Create bootstrap ::
		copy dist\settings.cmd+compiler\bootstrap_unpacked.cmd /B dist\bootstrap.cmd

	:: Save scripts :
		robocopy compiler\compiled dist\contents /E
) else (
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

		del tmp.ddf
		del setup.rpt
		del setup.inf

	:: Append CAB to bootstrapper ::
		copy dist\settings.cmd+compiler\bootstrap.cmd+dist\data.cab /B dist\bootstrap.cmd
		del dist\data.cab
)

if not "%settings_delete_compiled%" == "no" (
	rmdir /S /Q compiler\compiled
)

rmdir /S /Q compiler\info
del dist\1
del dist\2
del dist\settings.cmd

popd