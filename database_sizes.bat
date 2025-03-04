@echo off
setlocal enabledelayedexpansion

REM Configuración
set PGHOST=localhost
set PGPORT=5432

:mainMenu
cls
echo ****************************************
echo *       Ver Tamaño de Bases de Datos   *
echo ****************************************
set /p PGUSER="Ingresa el nombre de usuario de PostgreSQL: "

REM Obtener la letra de la unidad donde se encuentra el directorio de datos de PostgreSQL
set /p PGDATA="Ingresa la ruta del directorio de datos de PostgreSQL (por ejemplo, C:\Program Files\PostgreSQL\15\data): "
set DRIVE_LETTER=%PGDATA:~0,2%

REM Verificar si la unidad existe
if not exist %DRIVE_LETTER%\ (
    echo La unidad %DRIVE_LETTER% no existe.
    pause
    goto :mainMenu
)

REM Obtener el espacio total y libre en la unidad utilizando PowerShell
for /f "tokens=1,2" %%a in ('powershell -command "Get-PSDrive %DRIVE_LETTER:~0,1% | Select-Object Used,Free"') do (
    set UsedSpace=%%a
    set FreeSpace=%%b
)

REM Verificar si se obtuvieron los valores correctamente
if "%UsedSpace%"=="" (
    echo Error al obtener la información del espacio en disco.
    pause
    goto :mainMenu
)

REM Convertir bytes a GB
set /a UsedGB=%UsedSpace:~0,-9%
set /a FreeGB=%FreeSpace:~0,-9%
set /a TotalGB=UsedGB + FreeGB

REM Mostrar información del disco
echo Espacio total en %DRIVE_LETTER%: %TotalGB% GB
echo Espacio usado en %DRIVE_LETTER%: %UsedGB% GB
echo Espacio libre en %DRIVE_LETTER%: %FreeGB% GB

REM Mostrar el tamaño de las bases de datos junto con la información del disco
echo Mostrando el tamaño de las bases de datos...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -c "SELECT datname AS database, pg_size_pretty(pg_database_size(datname)) AS size, '%TotalGB% GB' AS total_disk_space, '%FreeGB% GB' AS free_disk_space FROM pg_database;"

if %errorlevel% neq 0 (
    echo No se pudo obtener el tamaño de las bases de datos.
    pause
    goto :mainMenu
)

pause
goto :mainMenu
