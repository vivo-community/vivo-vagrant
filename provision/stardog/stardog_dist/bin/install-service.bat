@echo off

pushd %~dp0
pushd ..
set STARDOG_INSTALL=%CD%
popd
rem Remaining in %~dp0 for the remainder of the script

IF NOT DEFINED STARDOG_MEMORY set STARDOG_MEMORY=2048
IF NOT DEFINED STARDOG_HOME set STARDOG_HOME=%STARDOG_INSTALL%
IF NOT DEFINED STARDOG_SERVICE_DISPLAY_NAME  set STARDOG_SERVICE_DISPLAY_NAME=Stardog Server
IF NOT DEFINED STARDOG_LOG_PATH set STARDOG_LOG_PATH=%STARDOG_INSTALL%\logs

IF "%PROCESSOR_ARCHITECTURE%"=="AMD64" GOTO :amd64
IF "%PROCESSOR_ARCHITEW6432%"=="AMD64" GOTO :amd64
IF "%PROCESSOR_ARCHITECTURE%"=="IA64" GOTO :ia64
IF "%PROCESSOR_ARCHITEW6432%"=="IA64" GOTO :ia64

echo "Unknown processor architecture %PROCESSOR_ARCHITECTURE%. The supported processor architectures are AMD64 and IA64.
exit /b 1


:amd64
echo AMD64 Architecture detected
copy windows\amd64\stardog-server.exe . >nul
goto :startinstall

:ia64

echo IA64 Architecture detected
copy windows\ia64\stardog-server.exe . >nul
goto :startinstall

:startinstall

echo.
echo The following parameters will be set for the service
echo.
echo Stardog installation directory is %STARDOG_INSTALL%
echo STARDOG_HOME is %STARDOG_HOME%
echo Stardog server will use %STARDOG_MEMORY% MB
echo Server logs will be written to %STARDOG_LOG_PATH%
echo.

echo Installing Service "%STARDOG_SERVICE_DISPLAY_NAME%"
echo.

set CLASSPATH=%STARDOG_INSTALL%\client\api\*;%STARDOG_INSTALL%\client\cli\*;%STARDOG_INSTALL%\client\http\*;%STARDOG_INSTALL%\client\snarl\*;%STARDOG_INSTALL%\server\dbms\*;%STARDOG_INSTALL%\server\http\*;%STARDOG_INSTALL%\server\snarl\* 

stardog-server //IS//Stardog-Server --Classpath=%CLASSPATH% --DisplayName="%STARDOG_SERVICE_DISPLAY_NAME%" --Install=%STARDOG_INSTALL%\bin\Stardog-Server.exe --LogPath=%STARDOG_LOG_PATH% --StdOutput=auto --StdError=auto --StartMode=jvm --StopMode=exe --StartClass=com.complexible.stardog.cli.admin.CLI --StartParams=server;start --StopClass=com.complexible.stardog.cli.admin.CLI --StopImage=%STARDOG_INSTALL%\bin\stop-service.bat --JvmOptions=-Xrs;-Dstardog.install.location=%STARDOG_INSTALL% --JvmMx=%STARDOG_MEMORY% --JvmMs=%STARDOG_MEMORY% ++Environment=STARDOG_HOME=%STARDOG_HOME%


if ERRORLEVEL 1 goto :failure

:success
popd
echo Successfully installed "%STARDOG_SERVICE_DISPLAY_NAME%"
exit /b 0

:failure
popd
echo Failed to install "%STARDOG_SERVICE_DISPLAY_NAME%"
echo Inspect %STARDOG_LOG_PATH% for more details
exit /b 1

