@echo off
setlocal enabledelayedexpansion

REM Configuración
set PGHOST=localhost
set PGPORT=5432

:mainMenu
cls
echo ****************************************
echo *       Listar Bases de Datos          *
echo ****************************************

REM Solicitar el nombre de usuario y la contraseña
set /p PGUSER="Ingresa el nombre de usuario de PostgreSQL: "

REM Solicitar la contraseña para el usuario
set "PGPASSWORD="
echo Ingresa la contraseña para el usuario %PGUSER%:
for /f "delims=" %%x in ('powershell -Command "$p = read-host 'Contraseña' -AsSecureString; $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($p); [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)"') do set "PGPASSWORD=%%x"

REM Listar todas las bases de datos
echo Listando todas las bases de datos...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -l -w
if %errorlevel% neq 0 (
    echo Error al listar las bases de datos.
    pause
    goto :mainMenu
)

pause
exit /b
