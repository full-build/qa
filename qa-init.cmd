setlocal
echo on
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

set VERSION=%TIME:~0,2%.%TIME:~3,2%.%TIME:~6,2%

taskkill /im tgitcache.exe
rmdir /s /q %QAFOLDER% || goto :ko

%FULLBUILD% init git %LOCALFBREPO% %QAFOLDER% || goto :ko
cd %QAFOLDER% || goto :ko
%FULLBUILD% clone * || goto :ko
goto :ok

%FULLBUILD% install || goto :ko
%FULLBUILD% package outdated || goto :ko
%FULLBUILD% package update || goto :ko
%FULLBUILD% convert --check * || goto :ko

%FULLBUILD% view all * || goto :ko
%FULLBUILD% view csc cassandra-sharp-contrib/* || goto :ko
%FULLBUILD% build all || goto :ko

pushd .full-build
git add *
git commit -am "qa"
git push origin master:master
popd

pushd cassandra-sharp
git add *
git commit -am "qa"
git push origin master:master
popd

pushd cassandra-sharp-contrib
git add *
git commit -am "qa"
git push origin master:master
popd

%FULLBUILD% history || goto :ko
%FULLBUILD% publish --push %VERSION% --view all *  || goto :ko
%FULLBUILD% app list --version %VERSION% || goto :ko


:ok
cd %HERE%
echo *** SUCCESSFUL
exit /b 0

:ko
cd %HERE%
echo *** FAILURE
exit /b 5
