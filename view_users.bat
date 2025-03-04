view_user:
@echo off
setlocal enabledelayedexpansion

set PGHOST=localhost
set PGPORT=5432
set BACKUP_DIR=C:\Postgrebk
set DEFAULT_DB=Mi_financiera_demo_lap

:mainMenu
cls
echo ****************************************
echo *     Usuarios y sus privilegios       *
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
    goto :mainMenu
)

set /p dbchoice="Selecciona la base de datos por numero: "
if not defined db%dbchoice% (
    echo Opcion no valida.
    pause
    goto :mainMenu
)

set DBNAME=!db%dbchoice%!
echo Listando los usuarios, privilegios, tablas y esquemas en la base de datos !DBNAME!...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d !DBNAME! -c "SELECT grantee, privilege_type, table_name, table_schema FROM information_schema.role_table_grants WHERE table_schema='public';"

pause
exit /b

