@echo off
setlocal enabledelayedexpansion

REM Configuración
set PGHOST=localhost
set PGPORT=5432
set BACKUP_DIR=C:\Postgrebk

chcp 65001

:mainMenu
cls
echo ******
echo *   Respaldar/Restaurar Esquema de una Base de Datos PostgreSQL   *
echo ******
echo 1. Respaldar Esquema
echo 2. Restaurar Esquema
echo 3. Salir

echo *******************************************************************
echo Respaldo y Restauración del esquema de una Base de Datos
echo Propósito General
echo Este script de lote de Windows (.bat) está diseñado para facilitar la creación de copias de seguridad (respaldos) y la restauración de esquemas de bases de datos PostgreSQL. 
echo Proporciona un menú interactivo para guiar al usuario a través de los procesos.
echo *******************************************************************
pause
set /p option="Selecciona una opción: "

if "%option%"=="1" goto :backupSchema
if "%option%"=="2" goto :restoreSchema
if "%option%"=="3" exit /b

echo Opción inválida.
pause
goto :mainMenu

:backupSchema
cls
echo ******
echo *   Respaldar Esquema de una Base de Datos PostgreSQL   *
echo ******

REM Solicitar nombre de usuario de PostgreSQL
set /p PGUSER="Ingresa el nombre de usuario de PostgreSQL: "

REM Validar que el usuario no esté vacío
if "%PGUSER%"=="" (
    echo.
    echo ¡ERROR! El nombre de usuario no puede estar vacío.
    echo.
    pause
    goto :backupSchema
)

REM Listar bases de datos disponibles
echo Listando bases de datos disponibles...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;" > temp_dbs.txt

set count=0
for /f "tokens=*" %%a in (temp_dbs.txt) do (
    set /a count+=1
    set "db!count!=%%a"
    echo !count!. %%a
)
del temp_dbs.txt

REM Solicitar el nombre de la base de datos
set /p DATABASE="Ingresa el nombre de la base de datos: "

REM Validar que la base de datos exista en la lista
set found=false
for /l %%i in (1,1,%count%) do (
    if "!db%%i!"=="%DATABASE%" (
        set found=true
        goto :continueBackup
    )
)

:continueBackup

if not "!found!"=="true" (
    echo.
    echo ¡ERROR! La base de datos no existe.
    echo.
    pause
    goto :backupSchema
)

REM Si no se ingresa el nombre de la base de datos, se asume "postgres"
if "%DATABASE%"=="" set DATABASE=postgres  

REM Obtener la fecha en formato yyyy-MM-DD
for /f "tokens=2 delims==" %%D in ('wmic os get localdatetime /value') do set datetime=%%D
set YYYY=!datetime:~0,4!
set MM=!datetime:~4,2!
set DD=!datetime:~6,2!

REM Definir la Ruta del Archivo de Respaldo
set SCHEMA_BACKUP_FILE=%BACKUP_DIR%\backup_%DATABASE%_!YYYY!-!MM!-!DD!.sql

REM Mostrar información antes de iniciar el respaldo
echo.
echo Iniciando respaldo del esquema de la base de datos '!DATABASE!'...
echo Archivo de respaldo: !SCHEMA_BACKUP_FILE!
echo.

REM Ejecutar el Comando de Respaldo
pg_dump -U %PGUSER% --schema-only -Fc -h %PGHOST% -p %PGPORT% -d %DATABASE% > "!SCHEMA_BACKUP_FILE!"

REM Comprobación de errores
if %errorlevel% neq 0 (
    echo.
    echo ¡ERROR! Falló el respaldo del esquema de la base de datos '!DATABASE!'.
    echo.
    pause
    goto :mainMenu
)

REM Confirmación de respaldo exitoso
echo.
echo ¡Respaldo del esquema de la base de datos '!DATABASE!' completado exitosamente!
echo Archivo de respaldo creado: !SCHEMA_BACKUP_FILE!
echo.
pause
goto :mainMenu

:restoreSchema
cls
echo ******
echo *   Restaurar Esquema de una Base de Datos PostgreSQL   *
echo ******

REM Solicitar nombre de usuario de PostgreSQL
set /p PGUSER="Ingresa el nombre de usuario de PostgreSQL: "

REM Validar que el usuario no esté vacío
if "%PGUSER%"=="" (
    echo.
    echo ¡ERROR! El nombre de usuario no puede estar vacío.
    echo.
    pause
    goto :restoreSchema
)

REM Solicitar el nombre de la nueva base de datos
set /p NEW_DATABASE="Ingresa el nombre de la NUEVA base de datos: "

REM Validar que el nombre de la nueva base de datos no esté vacío
if "%NEW_DATABASE%"=="" (
    echo.
    echo ¡ERROR! El nombre de la nueva base de datos no puede estar vacío.
    echo.
    pause
    goto :restoreSchema
)

REM Crear la nueva base de datos
echo Creando la base de datos '!NEW_DATABASE!'...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -c "CREATE DATABASE !NEW_DATABASE!;"

REM Comprobar si la base de datos se creó correctamente
if %errorlevel% neq 0 (
    echo.
    echo ¡ERROR! No se pudo crear la base de datos '!NEW_DATABASE!'.
    echo.
    pause
    goto :restoreSchema
)

REM Mostrar archivos de respaldo disponibles
echo.
echo Archivos de respaldo disponibles:
for /f "delims=" %%a in ('dir %BACKUP_DIR%\backup_*.sql /b') do (
    echo %%a
)
echo.

REM Solicitar el nombre del archivo de respaldo
set /p BACKUP_FILE="Ingresa el nombre del archivo de respaldo a restaurar: "

REM Validar que el archivo exista
if not exist "%BACKUP_DIR%\%BACKUP_FILE%" (
    echo.
    echo ¡ERROR! El archivo de respaldo no existe.
    echo.
    pause
    goto :restoreSchema
)

REM Mostrar información antes de iniciar la restauración
echo.
echo Iniciando restauración del esquema en la base de datos '!NEW_DATABASE!'...
echo Archivo de respaldo: %BACKUP_DIR%\%BACKUP_FILE%
echo.

REM Ejecutar el Comando de Restauración
pg_restore -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %NEW_DATABASE% -Fc "%BACKUP_DIR%\%BACKUP_FILE%"

REM Comprobación de errores
if %errorlevel% neq 0 (
    echo.
    echo ¡ERROR! Falló la restauración del esquema en la base de datos '!NEW_DATABASE!'.
    echo.
    pause
    goto :mainMenu
)

REM Confirmación de restauración exitosa
echo.
echo ¡Restauración del esquema en la base de datos '!NEW_DATABASE!' completada exitosamente!
echo.
pause
goto :mainMenu