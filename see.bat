@echo off
setlocal enabledelayedexpansion

echo El proposito de esta consulta es Mostrar el tamaño de la base de datos y mostrar cuanto espacio queda en el disco duro en MG Y GB,esto con el proposito de planificacion del almacenamiento.

REM Configuración
set PGHOST=localhost
set PGPORT=5432

:mainMenu
cls
echo ****************************************
echo *    Tamaño de la Base de Datos     *
echo ****************************************

echo El proposito de esta consulta es Mostrar el tamaño de la base de datos y mostrar cuanto espacio queda en el disco duro en MG Y GB,esto con el proposito de planificacion del almacenamiento.
pause

set /p PGUSER="Ingresa el nombre de usuario de PostgreSQL: "


echo Listando bases de datos disponibles...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -t -A -c "SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname ASC;" > temp_dbs.txt

echo Bases de datos disponibles:
set count=0
for /f "delims=" %%a in (temp_dbs.txt) do (
    set /a count+=1
    echo !count!. %%a
    set "db!count!=%%a"
)
if %count%==0 (
    echo No hay bases de datos disponibles.
    pause
    exit /b
)

REM Seleccionar base de datos para ver información
set /p DB_CHOICE="Selecciona el número de la base de datos: "
if not defined db%DB_CHOICE% (
    echo Selección inválida.
    pause
    exit /b
)
set "SELECTED_DB=!db%DB_CHOICE%!"

echo Obteniendo información de la base de datos %SELECTED_DB%...

REM Mostrar el tamaño de la base de datos seleccionada
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %SELECTED_DB% -c "SELECT pg_size_pretty(pg_database_size('%SELECTED_DB%')) AS \"Tamano de la Base de Datos\";"

REM Obtener el espacio total y disponible en el disco
for /f "tokens=2 delims==" %%A in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace /value') do set FREE_SPACE=%%A

REM Convertir espacio libre a MB y GB
set /A FREE_SPACE_MB=%FREE_SPACE:~0,-6%
set /A FREE_SPACE_GB=%FREE_SPACE_MB% / 1024

REM Mostrar los resultados
echo Espacio disponible en el disco: %FREE_SPACE_MB% MB
echo Espacio disponible en el disco: %FREE_SPACE_GB% GB


pause
goto :mainMenu
exit /b


