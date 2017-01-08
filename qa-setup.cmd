setlocal
echo on
set HERE=%~dp0
set PAKET=%HERE%tools/paket.exe
rem set FULLBUILD=%HERE%packages/full-build/tools/fullbuild.exe --verbose
set FULLBUILD=fullbuild.exe --verbose

set PATH=%PATH%;%HERE%packages\NUnit.ConsoleRunner\tools
set PATH=%PATH%;%HERE%packages\Paket\tools
set PATH=%PATH%;%HERE%packages\full-build\tools

set LOCALFBREPO=%HERE%local\full-build
set LOCALCSREPO=%HERE%local\cassandra-sharp
set LOCALCSCREPO=%HERE%local\cassandra-sharp-contrib
set LOCALBIN=%HERE%local\bin
set QAFOLDER=%HERE%qa-setup

taskkill /im tgitcache.exe
rmdir /s /q %QAFOLDER%

%FULLBUILD% setup git %LOCALFBREPO% %LOCALBIN% %QAFOLDER% || goto :ko
cd %QAFOLDER% || goto :ko

pushd .full-build
echo framework: net45 > paket.dependencies
popd

%FULLBUILD% nuget add https://www.nuget.org/api/v2/ || goto :ko
%FULLBUILD% repo add cassandra-sharp %LOCALCSREPO% || goto :ko
%FULLBUILD% repo add cassandra-sharp-contrib %LOCALCSCREPO% || goto :ko
%FULLBUILD% clone * || goto :ko
%FULLBUILD% branch || goto :ko
%FULLBUILD% repo list || goto :ko
%FULLBUILD% index * || goto :ko
%FULLBUILD% install || goto :ko
%FULLBUILD% convert * || goto :ko
%FULLBUILD% view all * || goto :ko
%FULLBUILD% view csc cassandra-sharp-contrib/* || goto :ko
%FULLBUILD% view list || goto :ko
%FULLBUILD% view describe all || goto :ko
%FULLBUILD% graph all || goto :ko
%FULLBUILD% build all || goto :ko
%FULLBUILD% view drop csc || goto :ko
%FULLBUILD% app add cqlplus.zip zip cqlplus || goto :ko
%FULLBUILD% app list || goto :ko
%FULLBUILD% publish cqlplus.zip || goto :ko

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

%FULLBUILD% push --full 1.0.0 || goto :ko
%FULLBUILD% app list --version 1.0.0 || goto :ko

:ok
echo *** SUCCESSFUL
exit /b 0

:ko
cd %HERE%
echo *** FAILURE
exit /b 0
