@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem Compila el mod TF8PlayerFortRise. No ejecuta TowerFall ni lo instala.
rem Para otra instalacion puede definir TF8_GAME_DIR antes de ejecutar.

set "ROOT=%~dp0"
if not defined TF8_GAME_DIR set "TF8_GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\TowerFall - FortRise2"
set "DOTNET=%ProgramFiles%\dotnet\dotnet.exe"
set "SDK_ROOT=%ProgramFiles%\dotnet\sdk"
set "REF_ROOT=%ProgramFiles%\dotnet\packs\Microsoft.NETCore.App.Ref"
set "OUT=%ROOT%TF8PlayerFortRise.dll"

if not exist "%DOTNET%" goto missing
if not exist "%TF8_GAME_DIR%\TowerFall.Patch.dll" goto missing
if not exist "%TF8_GAME_DIR%\0Harmony.dll" goto missing

for /f "delims=" %%S in ('dir /b /ad /o-n "%SDK_ROOT%\10.*" 2^>nul') do (
  if not defined TF8_SDK set "TF8_SDK=%%S"
)
if not defined TF8_SDK goto missing
set "CSC=%SDK_ROOT%\%TF8_SDK%\Roslyn\bincore\csc.dll"
if not exist "%CSC%" goto missing

for /f "delims=" %%R in ('dir /b /ad /o-n "%REF_ROOT%\10.*" 2^>nul') do (
  if not defined TF8_REF_VERSION set "TF8_REF_VERSION=%%R"
)
if not defined TF8_REF_VERSION goto missing
set "REF=%REF_ROOT%\%TF8_REF_VERSION%\ref\net10.0"
if not exist "%REF%" goto missing

rem Keep the long .NET reference list out of cmd.exe's 8191-character limit.
rem A response file guarantees that rebuilding really replaces the DLL.
set "RSP=%TEMP%\TF8PlayerFortRise-%RANDOM%%RANDOM%.rsp"
> "%RSP%" (
  echo /nologo
  echo /target:library
  echo /langversion:latest
  echo /nullable:enable
  echo /out:"%OUT%"
  for %%F in ("%REF%\*.dll") do echo /reference:"%%~fF"
  echo /reference:"%TF8_GAME_DIR%\TowerFall.Patch.dll"
  echo /reference:"%TF8_GAME_DIR%\FNA.dll"
  echo /reference:"%TF8_GAME_DIR%\0Harmony.dll"
  echo /reference:"%TF8_GAME_DIR%\Microsoft.Extensions.Logging.Abstractions.dll"
  echo "%ROOT%src\TF8PlayerFortRiseModule.cs"
  echo "%ROOT%src\GameplayPatches.cs"
)

echo Compilando TF8PlayerFortRise.dll...
"%DOTNET%" "%CSC%" @"%RSP%"
set "RESULT=%ERRORLEVEL%"
del /q "%RSP%" >nul 2>nul
if not "%RESULT%"=="0" goto failed
echo.
echo Compilacion completada:
echo %OUT%
echo.
pause
exit /b 0

:missing
echo.
echo ERROR: no se encontro el SDK .NET 10 o la instalacion de FortRise.
echo Ruta del juego: %TF8_GAME_DIR%
echo.
pause
exit /b 1

:failed
echo.
echo ERROR: la compilacion fallo.
pause
exit /b 1
