@echo off
SETLOCAL
set gov=1.14
set nodev=13.10.1
cd /D "%~dp0"
GOTO checkPerm
GOTO end

:checkPerm
net session >nul 2>&1
if %errorLevel% == 0 (
GOTO start
) else (
@powershell "Start-Process -FilePath '%~dpnx0' -WorkingDirectory '%~dp0' -Verb RunAs"
GOTO end
)
GOTO end

:start
IF NOT EXIST C:\Extra mkdir C:\Extra
GOTO dgo
GOTO end

:dgo
IF EXIST go%gov%.windows-amd64.msi GOTO igo
ECHO Downloading Go v%gov%
START /wait wget.exe https://dl.google.com/go/go%gov%.windows-amd64.msi >nul
IF NOT EXIST go%gov%.windows-amd64.msi (
GOTO dnode
)
GOTO igo
GOTO end

:igo
IF EXIST "C:\Extra\Go\bin\go.exe" GOTO dnode
ECHO Installing Go v%gov% to C:\Extra\Go
START /wait msiexec /i "go%gov%.windows-amd64.msi" INSTALLDIR="C:\Extra\Go" /qb! >nul
ECHO[
GOTO dnode
GOTO end

:dnode
IF EXIST node-v%nodev%-x64.msi GOTO inode
ECHO Downloading Nodejs v%nodev% and Npm v6.13.7
START /wait wget.exe https://nodejs.org/dist/v%nodev%/node-v%nodev%-x64.msi >nul
IF NOT EXIST node-v%nodev%-x64.msi (
GOTO makeit
)
GOTO inode
GOTO end

:inode
IF EXIST "C:\Extra\nodejs\node.exe" GOTO makeit
ECHO Installing Nodejs v%nodev% and Npm v6.13.7 to C:\Extra\nodejs
START /wait msiexec /i "node-v%nodev%-x64.msi" INSTALLDIR="C:\Extra\nodejs" ADDLOCAL="DocumentationShortcuts,EnvironmentPathNode,EnvironmentPathNpmModules,npm,NodeRuntime,EnvironmentPath" /qb! >nul
ECHO[
GOTO makeit
GOTO end

:makeit
IF EXIST "C:\Windows\System32\make.exe" GOTO wgetit
ECHO Installing Make v4.3
COPY %~dp0\make.exe C:\Windows\System32\make.exe >nul

:wgetit
IF EXIST "C:\Windows\System32\wget.exe" GOTO tests
ECHO Installing Wget v1.20.3
COPY %~dp0\wget.exe C:\Windows\System32\wget.exe >nul
GOTO tests
GOTO end

:tests
ECHO[
ECHO ******************************************************************
ECHO[
ECHO Testing if installations were successful...
ECHO[
ECHO[
IF NOT EXIST "C:\Extra\Go\bin\go.exe" ECHO Go was not installed...
IF NOT EXIST "C:\Extra\nodejs\node.exe" ECHO Nodejs was not installed...
IF NOT EXIST "C:\Windows\System32\make.exe" ECHO Make was not installed...
IF NOT EXIST "C:\Windows\System32\wget.exe" ECHO Wget was not installed...
IF EXIST "C:\Extra\Go\bin\go.exe" ECHO Go was installed!
IF EXIST "C:\Extra\nodejs\node.exe" ECHO Nodejs was installed!
IF EXIST "C:\Windows\System32\make.exe" ECHO Make was installed!
IF EXIST "C:\Windows\System32\wget.exe" ECHO Wget was installed!
PAUSE
CLS
ECHO Completed!
C:\Windows\System32\timeout.exe 4 >nul
GOTO end

:end
ENDLOCAL
EXIT