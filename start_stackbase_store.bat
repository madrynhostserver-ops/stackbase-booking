@echo off
setlocal

cd /d "%~dp0"

echo ==========================================
echo      StackBase Store - MVP Web
echo ==========================================
echo.

where bundle >nul 2>nul
if errorlevel 1 (
  echo ERROR: Bundler no esta disponible en el PATH.
  echo Instala Ruby y Bundler antes de continuar.
  pause
  exit /b 1
)

echo Preparando la base de datos...
call bundle exec rails db:prepare
if errorlevel 1 (
  echo ERROR: No se pudo preparar la base de datos.
  pause
  exit /b 1
)

echo Comprobando si Rails ya esta activo...
powershell -NoProfile -Command "$c=Get-NetTCPConnection -LocalPort 3100 -State Listen -ErrorAction SilentlyContinue; if ($c) { exit 0 } else { exit 1 }"
if not errorlevel 1 (
  echo Rails ya esta activo en http://127.0.0.1:3100
  echo No se reiniciara ni se ejecutaran seeds.
  endlocal
  exit /b 0
)

echo.
echo Aplicacion disponible en:
echo http://127.0.0.1:3100
echo.
echo Para verla como movil en VS Code:
echo Ctrl+Shift+P ^> Mobile Preview: Show
echo.
echo El servidor se ejecutara en una ventana/proceso independiente.
echo.

start "StackBase Store Rails" /b cmd /c "bundle exec rails server -b 127.0.0.1 -p 3100 >> log\server.log 2>&1"

echo Servidor iniciado sin bloquear esta terminal.
echo Logs: %CD%\log\server.log

endlocal
