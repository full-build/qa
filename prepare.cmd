setlocal
set HERE=%~dp0
set LOCALFOLDER=%HERE%local
set LOCALFBREPO=%HERE%local\full-build
set LOCALCSREPO=%HERE%local\cassandra-sharp
set LOCALCSCREPO=%HERE%local\cassandra-sharp-contrib
set LOCALBIN=%HERE%local\bin

set PAKETBOOTSTRAP=%HERE%tools/paket.bootstrapper.exe
set PAKET=%HERE%tools/paket.exe
set PATH=%PATH%;%HERE%packages\Paket\tools

rmdir /s /q %LOCALFOLDER%

rem create binaries folder
mkdir %LOCALBIN%

rem creating master repository
mkdir %LOCALFBREPO%
git init %LOCALFBREPO%

rem cloning repositories
mkdir %LOCALFOLDER%
git clone https://github.com/pchalamet/cassandra-sharp %LOCALFOLDER%\cassandra-sharp
git clone https://github.com/pchalamet/cassandra-sharp-contrib %LOCALFOLDER%\cassandra-sharp-contrib

rem fetch tools
%PAKETBOOTSTRAP%
%PAKET% restore || goto :ko
type %HERE%paket.lock
