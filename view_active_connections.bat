@echo off
setlocal enabledelayedexpansion

REM Configuración
set PGHOST=localhost
set PGPORT=5432

:mainMenu
cls
echo ****************************************
echo *       Ver Conexiones Activas         *
echo ****************************************
set /p PGUSER="Ingresa el nombre de usuario de PostgreSQL: "

REM Ver conexiones activas
echo Mostrando conexiones activas...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -c "SELECT pid, usename, state, query FROM pg_stat_activity;"
if %errorlevel% neq 0 (
    echo Error al mostrar las conexiones activas.
    pause
    goto :mainMenu
)

pause
exit /b
