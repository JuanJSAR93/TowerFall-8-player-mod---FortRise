@echo off
setlocal EnableExtensions

rem FNA crea sus slots de mandos antes de que FortRise cargue los mods.
rem Estas variables solo existen durante esta ejecucion del juego.
set "FNA_GAMEPAD_NUM_GAMEPADS=8"

rem Prueba para ocho mandos: joy.cpl ve los ocho como dispositivos DirectInput,
rem mientras que XInput solo puede exponer cuatro. Deben definirse ANTES de
rem iniciar SDL/FNA.
set "SDL_JOYSTICK_DIRECTINPUT=1"
set "SDL_JOYSTICK_RAWINPUT=1"
set "SDL_JOYSTICK_RAWINPUT_CORRELATE_XINPUT=0"
set "SDL_XINPUT_ENABLED=0"
set "SDL_JOYSTICK_GAMEINPUT=1"
set "SDL_JOYSTICK_THREAD=1"

set "GAME_ROOT=%~dp0..\.."
pushd "%GAME_ROOT%" || (
  echo No se encontro la carpeta del juego.
  pause
  exit /b 1
)

if not exist "FortRise.exe" (
  echo No se encontro FortRise.exe. Coloca este archivo dentro de Mods\TF8Player.
  popd
  pause
  exit /b 1
)

start "TowerFall 8 Players" /wait "FortRise.exe" --tf8players
set "EXIT_CODE=%ERRORLEVEL%"
popd
exit /b %EXIT_CODE%
