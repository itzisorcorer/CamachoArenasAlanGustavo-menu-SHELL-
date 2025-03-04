@echo off
setlocal enabledelayedexpansion

REM Configuración
set PGHOST=localhost
set PGPORT=5432
set BACKUP_DIR=C:\Postgrebk
set DEFAULT_DB=mi_financiera_demo

REM Obtener la fecha y hora en formato AAAAMMDD_HHMM
for /f "tokens=2 delims==" %%i in ('"wmic os get localdatetime /value"') do set datetime=%%i
set "BACKUP_DATE=%datetime:~0,4%%datetime:~4,2%%datetime:~6,2%_%datetime:~8,2%%datetime:~10,2%"
:mainMenu
cls
echo ****************************************
echo *       Respaldar Base de Datos        *
echo ****************************************
set /p PGUSER="Ingresa el nombre de usuario de PostgreSQL: "
set /p DATABASE="Ingresa el nombre de la base de datos [%DEFAULT_DB%]: "
if "%DATABASE%"=="" set DATABASE=%DEFAULT_DB%

set "BACKUP_FILE=%BACKUP_DIR%\%DATABASE%_backup_%BACKUP_DATE%.backup"

REM Crear directorio de respaldo si no existe
if not exist "%BACKUP_DIR%" (
    mkdir "%BACKUP_DIR%"
)

echo Respaldando la base de datos %DATABASE%...
pg_dump -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %DATABASE% -F c -b -v -f "%BACKUP_FILE%"
if %errorlevel% neq 0 (
    echo Error al realizar el respaldo de la base de datos %DATABASE%.
    pause
	goto :mainMenu
   
)
echo Respaldo completado: %BACKUP_FILE%
pause
exit /b
