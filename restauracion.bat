@echo off
setlocal enabledelayedexpansion

REM Configuración
set PGHOST=localhost
set PGPORT=5432
set BACKUP_DIR=C:\Postgrebk

:mainMenu
cls
echo ****************************************
echo *              Restauración            *
echo ****************************************

echo **********************************************************************************
echo *Restaura el archivo comprimido en una base de datos vacia con ruta perzonalizada*
echo **********************************************************************************
pause

echo DANGER: RECORDAR SOLO CON BASES DE DATOS VACIAS
set /p PGUSER="Ingresa el nombre de usuario de PostgreSQL: "

echo Listando bases de datos disponibles...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -t -c "\l" | findstr /v /c:"template0" | findstr /v /c:"template1" | findstr /r /v "^\s*$" > temp_dbs.txt

set count=0
for /f "tokens=1 delims=|" %%a in (temp_dbs.txt) do (
    set "dbName=%%a"
    if not "!dbName!"=="" (
        for /f "tokens=*" %%b in ("!dbName!") do (
            if not "%%b"=="" (
                set /a count+=1
                echo !count!. %%b
                set "db!count!=%%b"
            )
        )
    )
)
del temp_dbs.txt

if %count%==0 (
    echo No hay bases de datos disponibles.
    pause
    goto :mainMenu
)

set /p dbchoice="Selecciona la base de datos por numero: "
if not defined db%dbchoice% (
    echo Seleccion invalida.
    pause
    goto :mainMenu
)
set "DATABASE=!db%dbchoice%!"

set /p assignPath="¿Quieres asignar una ruta personalizada para restaurar? (s/n): "
if /I "%assignPath%"=="s" (
    set /p BACKUP_DIR="Ingrese la ruta donde desea guardar el respaldo: "
) else (
    set BACKUP_DIR="C:\Postgrebk"
)

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

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

set /p choice="Selecciona el archivo de respaldo por numero: "
if not defined file%choice% (
    echo Seleccion invalida.
    pause
    goto :mainMenu
)
set "RESTORE_FILE=!file%choice%!"

echo Restaurando la base de datos %DATABASE% desde el respaldo %RESTORE_FILE%...
pg_restore -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %DATABASE% -v "%RESTORE_FILE%"
if %errorlevel% neq 0 (
    echo Error al restaurar la base de datos %DATABASE% desde el respaldo %RESTORE_FILE%.
    pause
    goto :mainMenu
)
echo Restauracion completada en la base de datos %DATABASE%.
pause
exit /b
