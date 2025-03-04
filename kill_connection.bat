@echo off
setlocal enabledelayedexpansion

set PGHOST=localhost
set PGPORT=5432
REM set BACKUP_DIR=C:\Postgrebk
set DEFAULT_DB=Mi_financiera_demo_lap

:mainMenu
cls
echo ****************************************
echo *     Terminar conexiones activas      *
echo ****************************************

echo *****************************************************************************************
echo Este codigo muestra las conexiones activas a una base de datos que el usuario seleccione
echo Y tiene la finalidad de terminarlas para proporcionar estabilidad al sistema
echo *****************************************************************************************

pause
set /p PGUSER="Ingresa el nombre de usuario de PostgreSQL: "

echo Ingresa la contrasena del usuario %PGUSER%...
for /f "tokens=*" %%A in ('powershell -Command "$password = Read-Host -AsSecureString 'Contrasena'; [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))"') do set PGPASSWORD=%%A

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

:listConnections
cls
echo ****************************************
echo *     Conexiones activas en %DATABASE% *
echo ****************************************
echo.

REM Listar conexiones activas
psql -U %PGUSER% -d %DATABASE% -t -c "SELECT pid, usename, datname, state, query, client_addr FROM pg_stat_activity;" > temp_connections.txt

set connectionCount=0
for /f "tokens=1-6 delims=|" %%a in (temp_connections.txt) do (
    set /a connectionCount+=1
    echo [!connectionCount!] PID: %%a, Usuario: %%b, DB: %%c, Estado: %%d, Query: %%e, IP: %%f
    echo -------------------------
    set "pid!connectionCount!=%%a"
    set "user!connectionCount!=%%b"
    set "db!connectionCount!=%%c"
    set "state!connectionCount!=%%d"
    set "query!connectionCount!=%%e"
    set "ip!connectionCount!=%%f"
)
del temp_connections.txt

if %connectionCount%==0 (
    echo No hay conexiones activas.
    pause
    goto :mainMenu
)

set /p connectionChoice="Selecciona una conexion por numero para terminar (o 0 para volver al menu principal): "

if "%connectionChoice%"=="0" (
    goto :mainMenu
)

if not defined pid%connectionChoice% (
    echo Seleccion invalida.
    pause
    goto :listConnections
)

set "SELECTED_PID=!pid%connectionChoice%!"
set "SELECTED_USER=!user%connectionChoice%!"
set "SELECTED_DB=!db%connectionChoice%!"
set "SELECTED_STATE=!state%connectionChoice%!"
set "SELECTED_QUERY=!query%connectionChoice%!"
set "SELECTED_IP=!ip%connectionChoice%!"

echo.
echo Estas a punto de terminar la siguiente conexion:
echo PID: !SELECTED_PID!
echo Usuario: !SELECTED_USER!
echo Base de datos: !SELECTED_DB!
echo Estado: !SELECTED_STATE!
echo Query: !SELECTED_QUERY!
echo IP: !SELECTED_IP!
echo.

set /p confirm="¿Estas seguro de que deseas terminar esta conexion? (s/n): "
if /i "!confirm!"=="s" (
    echo Terminando la conexion...
    psql -U %PGUSER% -d %DATABASE% -c "SELECT pg_terminate_backend(!SELECTED_PID!);"
    echo Conexion terminada.
) else (
    echo Operacion cancelada.
)

pause
goto :listConnections