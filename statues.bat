@echo off
setlocal enabledelayedexpansion

REM Configuración
@echo off
setlocal enabledelayedexpansion

REM Configuración
set PGHOST=localhost
set PGPORT=5432
set PG_SERVICE=postgresql-x64-15

REM Configurar la consola para usar UTF-8
chcp 65001 >nul

REM Verificar si el servicio ya está en ejecución
sc query "%PG_SERVICE%" | find "RUNNING" >nul
if %errorlevel% neq 0 (
    echo Iniciando el servicio %PG_SERVICE%...
    net start %PG_SERVICE%
    timeout /t 3 /nobreak >nul
) else (
    echo El servicio %PG_SERVICE% ya está en ejecución.
)

:mainMenu
cls
echo *******************************************
echo *   Ver Estatus de la Base de Datos       *
echo *******************************************

echo ************************************************************************************************************************************
echo *Este codigo te permite interactuar con una base de datos Postgres y obtener información sobre su estado, 
echo *mostrar bases de datos disponibles, seleccionar una base de datos, consultar el estado de las bases de datos, 
echo *obtener su tamaño y contar el número de conexiones activas.Ademas contiene la opción de verificar si es servicio ya esta iniciado, 
echo *si no es asi automaticamente este codigo te permite levantar el sistema y continuar ejecutandolo.
echo ************************************************************************************************************************************


REM Solicitar nombre de usuario de PostgreSQL
set /p PGUSER="Ingresa el nombre de usuario de PostgreSQL: "

REM Intentar listar bases de datos disponibles
echo Listando bases de datos disponibles...

psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -t -A -c "SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname ASC;" > temp_dbs.txt

REM Mostrar bases de datos disponibles
echo Bases de datos disponibles:
set count=0
for /f "delims=" %%a in (temp_dbs.txt) do (
    set /a count+=1
    echo !count!. %%a
    set "db!count!=%%a"
)
del temp_dbs.txt
if %count%==0 (
    echo No hay bases de datos disponibles.
    pause
    exit /b
)

REM Seleccionar base de datos para ver estatus
set /p DB_CHOICE="Selecciona el número de la base de datos para ver su estatus: "
if not defined db%DB_CHOICE% (
    echo Selección inválida.
    pause
    exit /b
)
set "SELECTED_DB=!db%DB_CHOICE%!"

REM Verificar el estado de la base de datos
echo Verificando el estatus de la base de datos %SELECTED_DB%...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %SELECTED_DB% -c "SELECT pg_database.datname, pg_stat_activity.state, pg_stat_activity.query, pg_stat_activity.state_change FROM pg_database LEFT JOIN pg_stat_activity ON pg_stat_activity.datid = pg_database.oid WHERE pg_database.datname = '%SELECTED_DB%';"

REM Mostrar tamaño de la base de datos
echo Obteniendo el tamaño de la base de datos %SELECTED_DB%...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %SELECTED_DB% -c "SELECT pg_size_pretty(pg_database_size('%SELECTED_DB%')) AS size;"

REM Consultar el número de conexiones activas
echo Consultando el número de conexiones activas en %SELECTED_DB%...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %SELECTED_DB% -c "SELECT count(*) FROM pg_stat_activity WHERE datname = '%SELECTED_DB%';"

pause
exit /b
