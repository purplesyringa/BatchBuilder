rem Save global
set __global_storage__=%TEMP%\%RANDOM%%RANDOM%%RANDOM%.tmp
set >%__global_storage__%

set __passed_global_storage__=%TEMP%\%RANDOM%%RANDOM%%RANDOM%.tmp
echo.>%__passed_global_storage__%

set __return_recursion__=0


echo.splitBy="#" >"%~dp0bootstrap.vbs"
echo.Dim data >>"%~dp0bootstrap.vbs"

echo.Dim oFSO: Set oFSO = CreateObject("Scripting.FileSystemObject") >>"%~dp0bootstrap.vbs"
echo.Dim oFile: Set oFile = oFSO.GetFile(WScript.Arguments.Item(0)) >>"%~dp0bootstrap.vbs"
echo.With oFile.OpenAsTextStream() >>"%~dp0bootstrap.vbs"
echo.	data = .Read(oFile.Size) >>"%~dp0bootstrap.vbs"
echo.	.Close >>"%~dp0bootstrap.vbs"
echo.End With >>"%~dp0bootstrap.vbs"

echo.data = Right(data, Len(data) - InStr(data, splitBy)) >>"%~dp0bootstrap.vbs"
echo.data = Right(data, Len(data) - InStr(data, splitBy)) >>"%~dp0bootstrap.vbs"

echo.Set oFile = oFSO.GetFile(WScript.Arguments.Item(1)) >>"%~dp0bootstrap.vbs"
echo.With oFile.OpenAsTextStream(2, -2) >>"%~dp0bootstrap.vbs"
echo.	.Write(data) >>"%~dp0bootstrap.vbs"
echo.	.Close >>"%~dp0bootstrap.vbs"
echo.End With >>"%~dp0bootstrap.vbs"


set tmp=%TEMP%\%RANDOM%%RANDOM%%RANDOM%
mkdir %tmp% >nul 2>nul

echo.>"%tmp%\cab.cab"
cscript //Nologo "%~dp0bootstrap.vbs" "%0" "%tmp%\cab.cab"
del "%~dp0bootstrap.vbs"

expand "%tmp%\cab.cab" -F:* "%tmp%" >nul 2>nul
"%tmp%\%settings_entry%"

exit /b
#