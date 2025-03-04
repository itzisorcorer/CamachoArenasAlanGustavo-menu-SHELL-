@echo off
setlocal enabledelayedexpansion

REM Configuración
set PGHOST=localhost
set PGPORT=5432
:mainMenu
cls
echo ****************************************
echo *       Borrar Base de Datos           *
echo ****************************************
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
    exit /b
)

set /p dbchoice="Selecciona la base de datos por numero para borrar: "
if not defined db%dbchoice% (
    echo Seleccion invalida.
    pause
     goto :mainMenu
)
set "DATABASE=!db%dbchoice%!"

echo Quieres hacer un respaldo de la base de datos %DATABASE% antes de borrarla? (s/n): 
set /p backupChoice=
if /i "%backupChoice%"=="s" call backup_database.bat
if /i not "%backupChoice%"=="n" (
    echo Seleccion invalida.
    pause
    goto :mainMenu
)

echo Borrando la base de datos %DATABASE%...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -c "DROP DATABASE %DATABASE%;" || (
    echo Error al borrar la base de datos %DATABASE%.
    pause
    goto :mainMenu
)
echo Base de datos %DATABASE% borrada exitosamente.
pause
exit /b
