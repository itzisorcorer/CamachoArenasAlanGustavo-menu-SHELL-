@echo off
setlocal enabledelayedexpansion

REM Configuración
set PGHOST=localhost
set PGPORT=5432

cls
echo **********************************************
echo *        Modificar Permisos de Usuario       *
echo **********************************************

set /p PGUSER="Ingresa el nombre de usuario de PostgreSQL: "
set /p DBNAME="Ingresa el nombre de la base de datos: "
set /p USERNAME="Ingresa el nombre del usuario al que modificarás permisos: "

REM Solicitar la contraseña sin mostrarla
set "PGPASSWORD="
echo Ingresa la contraseña de %PGUSER%:
for /f "delims=" %%x in ('powershell -Command "$p = read-host 'Contraseña' -AsSecureString; $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($p); [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)"') do set "PGPASSWORD=%%x"
set PGPASSWORD=%PGPASSWORD%

echo.
echo Listando permisos disponibles:
echo 1. Conceder permisos de lectura (SELECT)
echo 2. Conceder permisos de escritura (INSERT, UPDATE, DELETE)
echo 3. Conceder permisos de eliminación (TRUNCATE)
echo 4. Conceder permisos de referencias (REFERENCES)
echo 5. Conceder permisos de disparadores (TRIGGER)
echo 6. Revocar todos los permisos
echo 7. Conceder todos los permisos (SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER)
set /p choice="Elige una opción (1-7): "

REM Validar elección
if "%choice%"=="1" (
    echo Otorgando permisos de lectura...
    psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %DBNAME% -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO %USERNAME%;" -w
    echo Permisos de lectura concedidos.
)

if "%choice%"=="2" (
    echo Otorgando permisos de escritura...
    psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %DBNAME% -c "GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO %USERNAME%;" -w
    echo Permisos de escritura concedidos.
)

if "%choice%"=="3" (
    echo Otorgando permisos de eliminación...
    psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %DBNAME% -c "GRANT TRUNCATE ON ALL TABLES IN SCHEMA public TO %USERNAME%;" -w
    echo Permisos de eliminación concedidos.
)

if "%choice%"=="4" (
    echo Otorgando permisos de referencias...
    psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %DBNAME% -c "GRANT REFERENCES ON ALL TABLES IN SCHEMA public TO %USERNAME%;" -w
    echo Permisos de referencias concedidos.
)

if "%choice%"=="5" (
    echo Otorgando permisos de disparadores...
    psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %DBNAME% -c "GRANT TRIGGER ON ALL TABLES IN SCHEMA public TO %USERNAME%;" -w
    echo Permisos de disparadores concedidos.
)

if "%choice%"=="6" (
    echo Revocando todos los permisos...
    psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %DBNAME% -c "REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM %USERNAME%;" -w
    echo Todos los permisos revocados para %USERNAME%..
)

if "%choice%"=="7" (
    echo Otorgando todos los permisos...
    psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %DBNAME% -c "GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA public TO %USERNAME%;" -w
    echo Todos los permisos concedidos para %USERNAME%.
)

echo Permisos modificados exitosamente.
pause
exit /b
