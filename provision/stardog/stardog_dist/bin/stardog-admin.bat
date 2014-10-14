@echo off

set JAVA=java

if exist "%JAVA_HOME%\bin\java.exe" set JAVA="%JAVA_HOME%\bin\java"

if "%STARDOG_JAVA_ARGS%"=="" set STARDOG_JAVA_ARGS=-Xmx2g -Xms2g -Dfile.encoding=UTF-8

pushd %~dp0
pushd ..
set HOMEDIR=%CD%
IF NOT DEFINED STARDOG_HOME set STARDOG_HOME=%CD%
popd
popd

set CLASSPATH=%HOMEDIR%\client\api\*;%HOMEDIR%\client\cli\*;%HOMEDIR%\client\http\*;%HOMEDIR%\client\snarl\*;%HOMEDIR%\server\dbms\*;%HOMEDIR%\server\http\*;%HOMEDIR%\server\snarl\*;%HOMEDIR%\client\pack\*;%HOMEDIR%\server\pack\*

%JAVA% %STARDOG_JAVA_ARGS% -Dstardog.install.location="%HOMEDIR%" -XX:SoftRefLRUPolicyMSPerMB=1 -XX:+UseParallelOldGC -XX:+UseCompressedOops -server -classpath "%CLASSPATH%" com.complexible.stardog.cli.admin.CLI %*

