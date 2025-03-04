@echo off
setlocal enabledelayedexpansion

REM Configuración
set PGHOST=localhost
set PGPORT=5432

:mainMenu
cls
echo ****************************************
echo *       Verificar Integridad de la BD  *
echo ****************************************

echo **************************************************************************************************************
echo *Se limpia la base de datos eliminando datos muertos y actuliza las estadístias para optimizar las consultas.*
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

set "DBNAME=!db[%choice%]!"
echo Has seleccionado la base de datos: %DBNAME%

REM Verificar integridad de la base de datos
echo Verificando la integridad de la base de datos %DBNAME%...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %DBNAME% -c "VACUUM VERBOSE ANALYZE;"
REM VACUUM limpia la base de datos eliminando datos muertos.
REM ANALYZE actualiza las estadísticas para optimizar las consultas.
REM VERBOSE muestra detalles del proceso.

if %errorlevel% neq 0 (
    echo Error al verificar la integridad de la base de datos.
    pause
    goto :mainMenu
)

echo La integridad de la base de datos %DBNAME% ha sido verificada correctamente.
pause
endlocal