setlocal
set HERE=%~dp0
set PAKET=%HERE%tools/paket.exe
rem set FULLBUILD=%HERE%packages/full-build/tools/fullbuild.exe
set FULLBUILD=fullbuild.exe --verbose

set PATH=%PATH%;%HERE%packages\NUnit.ConsoleRunner\tools
set PATH=%PATH%;%HERE%packages\Paket\tools
set PATH=%PATH%;%HERE%packages\full-build\tools

set LOCALFBREPO=%HERE%local\full-build
set LOCALCSREPO=%HERE%local\cassandra-sharp
set LOCALCSCREPO=%HERE%local\cassandra-sharp-contrib
set LOCALBIN=%HERE%local\bin
set QAFOLDER=%HERE%qa-init

taskkill /im tgitcache.exe
rmdir /s /q %QAFOLDER%

%FULLBUILD% init git %LOCALFBREPO% %QAFOLDER% || goto :ko
cd %QAFOLDER% || goto :ko
%FULLBUILD% clone *  || goto :ko

%FULLBUILD% view all * || goto :ko
%FULLBUILD% view csc cassandra-sharp-contrib/* || goto :ko
%FULLBUILD% build all || goto :ko
%FULLBUILD% history || goto :ko
%FULLBUILD% publish *  || goto :ko

:ok
echo *** SUCCESSFUL
exit /b 0

:ko
cd %HERE%
echo *** FAILURE
exit /b 0