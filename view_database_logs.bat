@echo off
setlocal enabledelayedexpansion

REM Configuración
set PGHOST=localhost
set PGPORT=5432

:mainMenu
cls
echo ****************************************
echo *       Ver Logs de la Base de Datos   *
echo ****************************************

echo ***************************************************************************************
echo *  Permite visualizar los logs de la base de datos de una forma interactiva.          *
echo *  El usuario ingresa la ruta del archivo de logs y el script lo muestra paginado.    *
echo ***************************************************************************************
pause

set /p PGUSER="Ingresa el nombre de usuario de PostgreSQL: "
set /p LOG_FILE="Ingresa la ruta completa del archivo de log ("C:\Archivos de programa\PostgreSQL\15\data\log\postgresql-2024-10-14_090804.log"): "

REM Ver logs de la base de datos
echo Mostrando los últimos logs...
type %LOG_FILE% | more
if %errorlevel% neq 0 (
    echo Error al mostrar los logs. Asegúrate de que la ruta del archivo sea correcta.
    pause
    goto :mainMenu
)

pause
exit /b
