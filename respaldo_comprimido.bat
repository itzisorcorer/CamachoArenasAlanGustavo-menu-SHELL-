@echo off
setlocal enabledelayedexpansion

REM Configuración del servidor PostgreSQL
set PGHOST=localhost
set PGPORT=5432
chcp 65001 

:mainMenu
cls
echo ********************************************
echo *     Crea un respaldo comprimido          *
echo ********************************************

echo *******************************************************************
echo *Crea un respaldo comprimido de la base de datos que se seleccione*
echo *******************************************************************
pause

:: Pedir usuario de PostgreSQL
set /p PGUSER="Ingrese el nombre de usuario de PostgreSQL: "

:: Validar conexión antes de continuar
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -c "SELECT 1;" >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Usuario o conexión inválida.
    pause
    goto :mainMenu
)

:: Listar bases de datos disponibles
echo Listando bases de datos disponibles...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;" > temp_dbs.txt

set count=0
for /f "tokens=*" %%a in (temp_dbs.txt) do (
    set /a count+=1
    set "db!count!=%%a"
    echo !count!. %%a
)
del temp_dbs.txt

if %count%==0 (
    echo No hay bases de datos disponibles.
    pause
    goto :mainMenu
)

:: Seleccionar base de datos
set /p dbchoice="Seleccione la base de datos por número: "
if not defined db%dbchoice% (
    echo Selección inválida.
    pause
    goto :mainMenu
)
set "DATABASE=!db%dbchoice%!"

:: Preguntar por ruta de respaldo
set /p assignPath="¿Quieres asignar una ruta personalizada para el respaldo? (s/n): "
if /I "%assignPath%"=="s" (
    set /p BACKUP_DIR="Ingrese la ruta donde desea guardar el respaldo: "
) else (
    set BACKUP_DIR="C:\Postgrebk"
)

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

:: Obtener fecha actual
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "DATE_SUFFIX=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%"

:: Ruta del respaldo
set "BACKUP_PATH=%BACKUP_DIR%\respaldo_%DATABASE%_%DATE_SUFFIX%.backup"

echo ----------------------------------------
echo Base de datos seleccionada: %DATABASE%
echo Respaldo se guardará en: %BACKUP_PATH%
echo ----------------------------------------
pause

:: Ejecutar respaldo comprimido correctamente
pg_dump -U %PGUSER% -h %PGHOST% -p %PGPORT% -F c -Z 9 -d %DATABASE% -f "%BACKUP_PATH%"

if %errorlevel% neq 0 (
    echo [ERROR] No se pudo realizar el respaldo.
    pause
) else (
    echo [ÉXITO] Respaldo guardado en: %BACKUP_PATH%
    pause
)

exit /b
