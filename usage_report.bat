@echo off
setlocal enabledelayedexpansion

REM Configuración inicial
set PGHOST=localhost
set PGPORT=5432

:mainMenu
cls
echo ****************************************
echo *       Generar Informe de Uso         *
echo ****************************************

echo **************************************************************************************************************
echo *Se otienen las estadiscicas sobre conexion, transacciones, bloques leidos y las filas afectadas de la tabla.*
echo **************************************************************************************************************
pause

set /p PGUSER="Ingresa el nombre de usuario de PostgreSQL: "
set PGPASSWORD=%db_password%

REM Obtener listado de bases de datos
echo Listando bases de datos disponibles...
set /a index=0
for /f "tokens=1" %%A in ('psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d postgres -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;"') do (
    set /a index+=1
    set "db[!index!]=%%A"
    echo !index! - %%A
)

if !index! equ 0 (
    echo No se encontraron bases de datos disponibles.
    pause
    goto :mainMenu
)

REM Seleccionar la base de datos
set /p choice="Selecciona el número de la base de datos: "
if !choice! lss 1 if !choice! gtr !index! (
    echo Selección no válida.
    pause
    goto :mainMenu
)

set "PGDATABASE=!db[%choice%]!"
echo Has seleccionado la base de datos: %PGDATABASE%

REM Verificar si la base de datos tiene registros en pg_stat_database
for /f %%C in ('psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d postgres -t -c "SELECT COUNT(*) FROM pg_stat_database WHERE datname = '!PGDATABASE!';"') do set "recordCount=%%C"

if "%recordCount%"=="0" (
    echo La base de datos seleccionada no tiene registros en pg_stat_database.
    echo Es posible que no haya tenido actividad reciente.
    pause
    goto :mainMenu
)

REM Generar informe de uso de la base de datos con nombres más descriptivos
echo Generando informe de uso de la base de datos...

REM Guardar la consulta en un archivo temporal
(
echo SELECT 
echo     datname AS "Base de Datos",
echo     numbackends AS "Conexiones Activas",
echo     xact_commit AS "Transacciones Confirmadas",
echo     xact_rollback AS "Transacciones Revertidas",
echo     blks_read AS "Bloques Leídos desde Disco",
echo     blks_hit AS "Bloques Recuperados de Caché",
echo     tup_returned AS "Filas Consultadas",
echo     tup_fetched AS "Filas Recuperadas",
echo     tup_inserted AS "Filas Insertadas",
echo     tup_updated AS "Filas Actualizadas",
echo     tup_deleted AS "Filas Eliminadas"
echo FROM pg_stat_database 
echo WHERE datname = '!PGDATABASE!';
) > query.sql

REM Ejecutar la consulta desde el archivo para evitar problemas de comillas
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %PGDATABASE% -f query.sql

REM Limpiar el archivo temporal
del query.sql

if %errorlevel% neq 0 (
    echo Error al generar el informe de uso.
    pause
    goto :mainMenu
)

pause
endlocal
