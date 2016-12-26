setlocal
set HERE=%~dp0
set PAKETBOOTSTRAP=%HERE%tools/paket.bootstrapper.exe
set PAKET=%HERE%tools/paket.exe
set FULLBUILD=%HERE%packages/full-build/tools/fullbuild.exe

set PATH=%PATH%;%HERE%packages\Paket\tools
set PATH=%PATH%;%HERE%packages\NUnit.ConsoleRunner\tools
set PATH=%PATH%;%HERE%packages\full-build\tools

set QAFOLDER=%HERE%qa-cassandrasharp
rmdir /s /q %QAFOLDER%

%PAKETBOOTSTRAP%
%PAKET% restore || goto :ko
%FULLBUILD% setup git https://github.com/pchalamet/cassandra-sharp-full-build %HERE%binrepo %QAFOLDER% || goto :ko
cd %QAFOLDER% || goto :ko

%FULLBUILD% add nuget https://www.nuget.org/api/v2/ || goto :ko
%FULLBUILD% add repo cassandra-sharp https://github.com/pchalamet/cassandra-sharp || goto :ko
%FULLBUILD% add repo cassandra-sharp-contrib https://github.com/pchalamet/cassandra-sharp-contrib || goto :ko
%FULLBUILD% clone *  || goto :ko
%FULLBUILD% index * || goto :ko
%FULLBUILD% convert * || goto :ko
%FULLBUILD% view all * || goto :ko
%FULLBUILD% view csc cassandra-sharp-contrib/* || goto :ko
%FULLBUILD% list view || goto :ko
%FULLBUILD% describe view all || goto :ko
%FULLBUILD% graph all || goto :ko
%FULLBUILD% build all || goto :ko
%FULLBUILD% history || goto :ko
%FULLBUILD% drop view csc || goto :ko
%FULLBUILD% outdated package || goto :ko
%FULLBUILD% update package || goto :ko
%FULLBUILD% push 42 || goto :ko

:ok
echo *** SUCCESSFUL
exit /b 0

:ko
cd %HERE%
echo *** FAILURE
exit /b 0
