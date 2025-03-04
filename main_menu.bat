@echo off
setlocal enabledelayedexpansion

REM ===========================================================
REM             Consola de Respaldos 
REM ===========================================================
REM Este programa ha sido creado con fines educativos como una 
REM herramienta de práctica para la gestión de respaldos y restauración 
REM de bases de datos PostgreSQL. Está diseñado para ayudar a los estudiantes 
REM y profesionales a familiarizarse con los comandos de PostgreSQL y 
REM para su implementación en procesos de automatización. Este shell 
REM está diseñado para mejorarse con nuevas funcionalidades y comandos 
REM adicionales según las necesidades específicas.
REM MTI JERM



:mainMenu
cls
echo ****************************************
echo *   Menu de Respaldo y Restauracion    *
echo ****************************************
echo 1. Respaldar la base de datos
echo 2. Restaurar la base de datos existente
echo 3. Crear nueva base de datos y restaurar respaldo
echo 4. Borrar una base de datos
echo 5. Crear usuario y asignar permisos
echo 6. Modificar permisos de usuario 
echo 7. Ver usuarios y sus privilegios
echo 8. Eliminar un usuario - Ailine
echo 9. Listar todas las bases de datos -Daniel
echo 10. Ver el tamaño de las bases de datos -Marcos
echo 11. Terminar conexiones activas  -Alan
echo 12. Ver logs de la base de datos -Evelyn
REM extras
echo 13. Estatus de la base de datos -Amy
echo 14. Crea un respaldo comprimido -Javi
echo 15. Restauración de respaldo comprimido -Javi
echo 16. Verificar Integridad de la BD -Ines
echo 17. Generar Informe de Uso -Marisol
echo 18. Respaldar Esquema de una Base de Datos PostgreSQL -Carlos
echo 19. Respaldo y restauracion de una tabla -Gama
echo 20. Mostrar tamaño de la base de datos
echo 21. Salir
echo ****************************************
set /p choice="Selecciona una opcion (1/2/3/4/5/6/7/8/9/10/11/12/13/14/15/16/17/18/19/20/21): "

if "%choice%"=="1" call backup_database.bat
if "%choice%"=="2" call restore_database.bat
if "%choice%"=="3" call create_and_restore_database.bat
if "%choice%"=="4" call delete_database.bat
if "%choice%"=="5" call create_user.bat
if "%choice%"=="6" call modify_permissions.bat
if "%choice%"=="7" call view_users.bat
if "%choice%"=="8" call delete_user.bat
if "%choice%"=="9" call list_databases.bat
if "%choice%"=="10" call database_sizes.bat
if "%choice%"=="11" call kill_connection.bat
if "%choice%"=="12" call view_database_logs.bat

REM extras
if "%choice%"=="13" call statues.bat

if "%choice%"=="14" call respaldo_comprimido.bat
if "%choice%"=="15" call restauracion.bat
if "%choice%"=="16" call databases_integrity.bat
if "%choice%"=="17" call usage_report.bat
if "%choice%"=="18" call respaldo_restauracion_esquemabat.bat
if "%choice%"=="19" call respaldar_tabla.bat
if "%choice%"=="20" call see.bat

if "%choice%"==21"" goto :exitProgram


pause
goto :mainMenu

:exitProgram
echo Saliendo del programa...
endlocal
exit /b
