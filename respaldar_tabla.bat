@echo off
setlocal enabledelayedexpansion

:: Configuracion de PostgreSQL
set PGHOST=localhost
set PGPORT=5432

:mainMenu
cls
echo ******************************************
echo *       RESPALDO Y RESTAURACION       *
echo ******************************************
echo 1. Respaldar tabla
echo 2. Restaurar tabla
echo 3. Salir
echo ******************************************

echo ****************************************************************************************************************************
echo  Este script en Batch permite realizar respaldo y restauración de tablas en bases de datos PostgreSQL mediante
echo  una interfaz de línea de comandos interactiva, permitiendo al usuario elegir una tabla especifica y respaldarla en una ruta
echo  Seleccionada por el mismo, de igual manera permite restaurar dicho respaldo.
echo ****************************************************************************************************************************
pause
set /p option="Seleccione una opcion: "

if "%option%"=="1" goto :backupTable
if "%option%"=="2" goto :restoreTable
if "%option%"=="3" exit /b

echo Opcion invalida.
pause
goto :mainMenu

:backupTable
cls
echo ******************************************
echo *         RESPALDAR TABLA               *
echo ******************************************


set /p PGUSER="Ingrese el nombre de usuario de PostgreSQL: "

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

set /p dbchoice="Seleccione la base de datos por numero: "
if not defined db%dbchoice% (
    echo Seleccion invalida.
    pause
    goto :mainMenu
)
set "DATABASE=!db%dbchoice%!"

:: Listar tablas de la base seleccionada
echo Listando tablas en la base de datos %DATABASE%...
psql -U %PGUSER% -d %DATABASE% -t -c "\dt" > temp_tables.txt

set count=0
for /f "tokens=2 delims=|" %%a in (temp_tables.txt) do (
    set /a count+=1
    set "table!count!=%%a"
    echo !count!. %%a
)
del temp_tables.txt

if %count%==0 (
    echo No hay tablas disponibles en %DATABASE%.
    pause
    goto :mainMenu
)

set /p tableChoice="Seleccione la tabla por numero: "
if not defined table%tableChoice% (
    echo Seleccion invalida.
    pause
    goto :mainMenu
)
set "TABLE=!table%tableChoice%!"

:: Pedir al usuario que ingrese la ruta para guardar el respaldo
set /p BACKUP_DIR="Ingrese la ruta donde desea guardar el respaldo (ejemplo: C:\Respaldo\): "

:: Verificar si la ruta es válida
if not exist "%BACKUP_DIR%" (
    echo La ruta especificada no existe.
    pause
    goto :mainMenu
)

:: Obtener fecha actual
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "DATE_SUFFIX=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%"

:: Definir ruta del respaldo
set "BACKUP_PATH=%BACKUP_DIR%\respaldo_%DATABASE%_%TABLE%_%DATE_SUFFIX%.sql"

echo ----------------------------------------
echo Base de datos: %DATABASE%
echo Tabla: %TABLE%
echo Respaldo en: %BACKUP_PATH%
echo ----------------------------------------
pause

pg_dump -h %PGHOST% -p %PGPORT% -U %PGUSER% -t %TABLE% %DATABASE% > "%BACKUP_PATH%"

if %errorlevel% neq 0 (
    echo [ERROR] No se pudo realizar el respaldo.
    pause
) else (
    echo [EXITO] Respaldo realizado con exito.
    echo Archivo guardado en: %BACKUP_PATH%
    pause
)
goto :mainMenu

:restoreTable
cls
echo ******************************************
echo *         RESTAURAR TABLA               *
echo ******************************************

set /p PGUSER="Ingrese el nombre de usuario de PostgreSQL: "

:: Listar archivos de respaldo disponibles
echo.
echo Archivos de respaldo disponibles en la carpeta:
set count=0
for %%F in ("%BACKUP_DIR%\respaldo_*.sql") do (
    set /a count+=1
    echo !count!. %%~nxF
    set "file!count!=%%F"
)
if %count%==0 (
    echo No hay archivos de respaldo disponibles.
    pause
    goto :mainMenu
)

set /p fileChoice="Seleccione el archivo de respaldo por numero: "
if not defined file%fileChoice% (
    echo Seleccion invalida.
    pause
    goto :mainMenu
)
set "BACKUP_FILE=!file%fileChoice%!"

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

set /p dbchoice="Seleccione la base de datos por numero: "
if not defined db%dbchoice% (
    echo Seleccion invalida.
    pause
    goto :mainMenu
)
set "DATABASE=!db%dbchoice%!"

:: Listar tablas de la base seleccionada
echo Listando tablas en la base de datos %DATABASE%...
psql -U %PGUSER% -d %DATABASE% -t -c "\dt" > temp_tables.txt

set count=0
for /f "tokens=2 delims=|" %%a in (temp_tables.txt) do (
    set /a count+=1
    set "table!count!=%%a"
    echo !count!. %%a
)
del temp_tables.txt

set /p tableChoice="Seleccione la tabla por numero a restaurar: "
if not defined table%tableChoice% (
    echo Seleccion invalida.
    pause
    goto :mainMenu
)
set "TABLE=!table%tableChoice%!"

:: Confirmar eliminación de la tabla si ya existe
set /p confirm="¿Desea eliminar la tabla %TABLE% si ya existe? (S/N): "
if /i "%confirm%"=="S" (
    echo Eliminando tabla %TABLE%...
    psql -U %PGUSER% -d %DATABASE% -c "DROP TABLE IF EXISTS %TABLE% CASCADE;"
)

echo Restaurando la tabla %TABLE% en la base de datos %DATABASE%...
pause

psql -U %PGUSER% -d %DATABASE% -f "%BACKUP_FILE%"

if %errorlevel% neq 0 (
    echo [ERROR] No se pudo restaurar la tabla.
    pause
) else (
    echo [EXITO] Restauracion completada.
    pause
)
goto :mainMenu
