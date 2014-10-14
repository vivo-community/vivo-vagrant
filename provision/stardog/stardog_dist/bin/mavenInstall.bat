@echo off

pushd %~dp0
cd ..
set DISTDIR=%cd%
popd

set TMPDIRECTORY="%temp%\D%date:~10,4%%date:~4,2%%date:~7,2%%time:~0,2%%time:~3,2%%time:~6,2%%time:~9,2%"
mkdir %TMPDIRECTORY%

for %%X in (unzip.exe) do (set FOUND=%%~$PATH:X)
if not defined FOUND (
  echo %~n0 requires unzip, but unzip is not found - aborting.
  exit /b 1
)

for %%X in (
client\api\cp-common-openrdf-2.0.5.jar
client\api\cp-common-utils-3.1.3.jar
client\api\data-exporter-1.0.0.jar
client\api\jsonld-java-0.5.0.jar
client\api\openrdf-sesame-2.7.12.jar
client\api\protocols-api-client-2.2.1.jar
client\api\protocols-api-shared-2.2.1.jar
client\api\stardog-common-rdf-2.2.1.jar
client\api\stardog-common-utils-2.2.1.jar
client\api\stardog-icv-core-api-2.2.1.jar
client\api\stardog-openrdf-utils-2.2.1.jar
client\api\stardog-protocols-spec-client-2.2.1.jar
client\api\stardog-protocols-spec-shared-2.2.1.jar
client\api\stardog-reasoning-api-2.2.1.jar
client\api\stardog-reasoning-shared-2.2.1.jar
client\api\stardog-search-api-2.2.1.jar
client\api\stardog-shared-2.2.1.jar
client\api\stardog-snarl-api-2.2.1.jar
client\empire\empire-0.8.6.jar
client\empire\stardog-empire-2.2.1.jar
client\http\stardog-http-client-2.2.1.jar
client\http\stardog-http-shared-2.2.1.jar
client\http\stardog-icv-http-client-2.2.1.jar
client\http\stardog-reasoning-http-client-2.2.1.jar
client\http\stardog-search-http-client-2.2.1.jar
client\jena\stardog-jena-2.2.1.jar
client\sesame\stardog-sesame-2.2.1.jar
client\snarl\bigpacket-client-2.2.1.jar
client\snarl\bigpacket-shared-2.2.1.jar
client\snarl\cp-common-protobuf-1.2.jar
client\snarl\stardog-icv-api-2.2.1.jar
client\snarl\stardog-icv-shared-2.2.1.jar
client\snarl\stardog-icv-snarl-client-2.2.1.jar
client\snarl\stardog-icv-snarl-shared-2.2.1.jar
client\snarl\stardog-reasoning-protocol-shared-2.2.1.jar
client\snarl\stardog-reasoning-snarl-client-2.2.1.jar
client\snarl\stardog-reasoning-snarl-shared-2.2.1.jar
client\snarl\stardog-search-snarl-client-2.2.1.jar
client\snarl\stardog-snarl-client-2.2.1.jar
client\snarl\stardog-snarl-shared-2.2.1.jar
client\snarl\stardog-watchdog-protocol-shared-2.2.1.jar
client\snarl\stardog-watchdog-snarl-client-2.2.1.jar
client\snarl\stardog-watchdog-snarl-shared-2.2.1.jar
) do (
  call unzip %DISTDIR%\%%X META-INF\maven\* -d %TMPDIRECTORY%
  for /f "tokens=* USEBACKQ" %%Y in (`dir %TMPDIRECTORY%\pom.xml /b /s`) do (
    call mvn install:install-file -Dfile=%DISTDIR%\%%X -DpomFile=%%Y
  )
  rmdir %TMPDIRECTORY%\META-INF /s /q
)

rmdir %TMPDIRECTORY% /s /q
