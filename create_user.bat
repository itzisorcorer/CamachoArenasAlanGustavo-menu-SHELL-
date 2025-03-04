@echo off
setlocal enabledelayedexpansion

REM Configuración
set PGHOST=localhost
set PGPORT=5432
set BACKUP_DIR=C:\Postgrebk
set DEFAULT_DB=mi_financiera_demo

:mainMenu
cls
echo ****************************************
echo *   Crear usuario y asignar permisos   *
echo ****************************************

REM Solicitar el nombre de usuario y contraseña
set /p PGUSER="Ingresa el nombre de usuario de PostgreSQL: "
set /p NEW_USER="Ingrese el nombre del nuevo usuario de PostgreSQL: "

REM Capturar la contraseña sin mostrarla
set "NEW_PASS="
echo Ingrese la contraseña del nuevo usuario:
for /f "delims=" %%x in ('powershell -Command "$p = read-host 'Contraseña' -AsSecureString; $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($p); [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)"') do set "NEW_PASS=%%x"

REM Crear usuario en PostgreSQL
echo Creando usuario...
echo CREATE USER "!NEW_USER!" WITH PASSWORD '!NEW_PASS!'; | psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d postgres
if %errorlevel% neq 0 (
    echo Error al crear el usuario.
    pause
    exit /b
)

REM Otorgar permisos
set /p DB_NAME="Ingrese el nombre de la base de datos a la que tendrá acceso: "
echo Verificando la existencia de la base de datos !DB_NAME!...

REM Verificar si la base de datos existe sin mostrar la salida de la consulta
for /f "tokens=*" %%i in ('psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d postgres -t -c "SELECT 1 FROM pg_database WHERE datname='!DB_NAME!';"') do set DB_EXISTS=%%i

if "%DB_EXISTS%"=="1" (
    echo La base de datos !DB_NAME! existe.
) else (
    echo La base de datos !DB_NAME! no existe.
    pause
    exit /b
)

REM Opciones de permisos
echo.
echo Opciones de permisos:
echo 1. Conceder permisos de lectura (SELECT)
echo 2. Conceder permisos de escritura (INSERT, UPDATE, DELETE)
echo 3. Conceder permisos de eliminación (TRUNCATE)
echo 4. Conceder permisos de referencias (REFERENCES)
echo 5. Conceder permisos de disparadores (TRIGGER)
echo 6. Revocar todos los permisos
echo 7. Conceder todos los permisos (SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER)
set /p choice="Elige una opción (1-7): "

if "%choice%"=="1" (
    echo Otorgando permisos de lectura...
    psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d !DB_NAME! -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO !NEW_USER!;"
    echo Permisos de lectura concedidos.
)

if "%choice%"=="2" (
    echo Otorgando permisos de escritura...
    psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d !DB_NAME! -c "GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO !NEW_USER!;"
    echo Permisos de escritura concedidos.
)

if "%choice%"=="3" (
    echo Otorgando permisos de eliminación...
    psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d !DB_NAME! -c "GRANT TRUNCATE ON ALL TABLES IN SCHEMA public TO !NEW_USER!;"
    echo Permisos de eliminación concedidos.
)

if "%choice%"=="4" (
    echo Otorgando permisos de referencias...
    psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d !DB_NAME! -c "GRANT REFERENCES ON ALL TABLES IN SCHEMA public TO !NEW_USER!;"
    echo Permisos de referencias concedidos.
)

if "%choice%"=="5" (
    echo Otorgando permisos de disparadores...
    psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d !DB_NAME! -c "GRANT TRIGGER ON ALL TABLES IN SCHEMA public TO !NEW_USER!;"
    echo Permisos de disparadores concedidos.
)

if "%choice%"=="6" (
    echo Revocando todos los permisos...
    psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d !DB_NAME! -c "REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM !NEW_USER!;"
    echo Todos los permisos revocados para !NEW_USER!..
)

if "%choice%"=="7" (
    echo Otorgando todos los permisos...
    psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d !DB_NAME! -c "GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA public TO !NEW_USER!;"
    echo Todos los permisos concedidos para !NEW_USER!.
)

echo Usuario "!NEW_USER!" creado y con los permisos asignados a la base "!DB_NAME!".  
pause  
exit /b
