@echo off

set STARDOG_JAVA_ARGS=-Xmx512m

pushd ..

call bin\stardog-admin server stop

:lockfileloop

if exist system.lock (
  goto :lockfileloop
)

popd