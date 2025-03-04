@echo off
setlocal enabledelayedexpansion

REM Configuración
set PGHOST=localhost
set PGPORT=5432
set BACKUP_DIR=C:\Postgrebk

:mainMenu
cls
echo ******************************************
echo *   Crear y Restaurar Nueva Base de Datos*
echo ******************************************

REM Solicitar nombre de usuario de PostgreSQL
set /p PGUSER="Ingresa el nombre de usuario de PostgreSQL: "

REM Solicitar el nombre de la nueva base de datos
set /p NEW_DATABASE="Ingresa el nombre de la nueva base de datos: "

REM Listar archivos de respaldo disponibles
echo Archivos de respaldo disponibles:
set count=0
for %%F in ("%BACKUP_DIR%\*.backup") do (
    set /a count+=1
    echo !count!. %%~nxF
    set "file!count!=%%F"
)
if %count%==0 (
    echo No hay archivos de respaldo disponibles en %BACKUP_DIR%.
    pause
    exit /b
)

REM Seleccionar el archivo de respaldo por numero
set /p choice="Selecciona el archivo de respaldo por numero: "
if not defined file%choice% (
    echo Seleccion invalida.
    pause
     goto :mainMenu
)
set "RESTORE_FILE=!file%choice%!"

REM Verificar si el archivo de respaldo realmente existe
if not exist "!RESTORE_FILE!" (
    echo El archivo de respaldo !RESTORE_FILE! no existe.
    pause
     goto :mainMenu
)

REM Crear la nueva base de datos
echo Creando la nueva base de datos %NEW_DATABASE%...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -c "CREATE DATABASE %NEW_DATABASE%;" || (
    echo Error al crear la base de datos %NEW_DATABASE%.
    pause
    goto :mainMenu
)

REM Pausa breve para asegurar que la base de datos esté disponible
timeout /t 10

REM Restaurar el respaldo en la nueva base de datos
echo Restaurando el respaldo !RESTORE_FILE! en la nueva base de datos %NEW_DATABASE%...
pg_restore -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %NEW_DATABASE% -v "!RESTORE_FILE!"
if %errorlevel% neq 0 (
    echo Error al restaurar el respaldo !RESTORE_FILE! en la nueva base de datos %NEW_DATABASE%.
    pause
    goto :mainMenu
)
echo Restauracion completada en la nueva base de datos %NEW_DATABASE%.
pause
exit /b
