@echo off
setlocal enabledelayedexpansion

REM Configuración
set PGUSER=postgres
set PGHOST=localhost
set PGPORT=5432

REM Listar usuarios
cls
echo ****************************************
echo *     Borrar Usuario de PostgreSQL     *
echo ****************************************

echo ******************************************************************************
echo *Se elimina un usuario, eliminando las conexiones que esten vinculadas a el..*
echo ******************************************************************************
pause
echo Listando usuarios disponibles...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -t -c "\du" | findstr /v /c:"postgres" | findstr /r /v "^\s*$" > temp_users.txt
REM Se enlista los usuarios
set count=0
for /f "tokens=1 delims=|" %%a in (temp_users.txt) do (
    set "userName=%%a"
    if not "!userName!"=="" (
        set /a count+=1
        echo !count!. !userName!
        set "user!count!=!userName!"
    )
)
del temp_users.txt
REM se selecciona al usuario al que se desea eliminar
set /p userchoice="Selecciona el usuario por número para borrar: "
if not defined user%userchoice% (
    echo Selección inválida.
    pause
    exit /b
)
set "USER=!user%userchoice%!"
set USER=%USER: =%
REM Se elimina el usuario, se le hace una pregunta de si esta seguro
echo Usuario seleccionado: %USER%
set /p confirm="¿Estás seguro de eliminar el usuario %USER%? (s/n): "
if /i "%confirm%" NEQ "s" exit /b

REM Solicitar la contraseña solo una vez, después de la confirmación
echo Ingresa la contraseña de %PGUSER%:
for /f "delims=" %%x in ('powershell -Command "$p = read-host 'Contraseña' -AsSecureString; $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($p); [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)"') do set "PGPASSWORD=%%x"
set PGPASSWORD=%PGPASSWORD%

REM Obtener lista de bases de datos
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;" > temp_dbs.txt

REM Se elimina aunque este vinculado con algun dato
for /f "tokens=*" %%d in (temp_dbs.txt) do (
    set "DB=%%d"
    set DB=!DB: =!
    if not "!DB!"=="" (
        psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d !DB! -c "DROP OWNED BY %USER% CASCADE;" > nul 2>&1
        psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d !DB! -c "REASSIGN OWNED BY %USER% TO postgres;" > nul 2>&1
    )
)
del temp_dbs.txt

REM Intentar eliminar usuario
echo Borrando el usuario %USER%...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d postgres -c "DROP ROLE %USER%;" > nul 2>&1

if %errorlevel% neq 0 (
    echo Error al borrar el usuario %USER%.
    pause
    exit /b
)
REM se elimina al usuario en caso de no ser posible manda un mensaje y si no hay error se elimina
echo Usuario %USER% eliminado exitosamente.
pause
exit /b
