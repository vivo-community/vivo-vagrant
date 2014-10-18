@echo off

set JAVA=java

if exist "%JAVA_HOME%\bin\java.exe" set JAVA="%JAVA_HOME%\bin\java"

if "%STARDOG_JAVA_ARGS%"=="" set STARDOG_JAVA_ARGS=-Xmx2g -Xms2g

pushd %~dp0
pushd ..
set HOMEDIR=%CD%
IF NOT DEFINED STARDOG_HOME set STARDOG_HOME=%CD%
popd
popd
set SLF4J_JARS=

setlocal enableDelayedExpansion
FOR %%F IN ("%HOMEDIR%\server\dbms\slf4j*jar") DO set SLF4J_JARS=!SLF4J_JARS!;%%F
setlocal disableDelayedExpansion

set CLASSPATH=%HOMEDIR%\client\api\*;%HOMEDIR%\client\cli\*;%HOMEDIR%\client\http\*;%HOMEDIR%\client\snarl\*;%HOMEDIR%\client\pack\*;%SLF4J_JARS%

%JAVA% %STARDOG_JAVA_ARGS% -XX:SoftRefLRUPolicyMSPerMB=1 -XX:+UseParallelOldGC -XX:+UseCompressedOops -server -classpath "%CLASSPATH%" com.complexible.stardog.cli.CLI %*

