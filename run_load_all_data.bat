@echo off
REM Run the full PostgreSQL load script using the explicit psql binary path.
SET "PSQL_PATH=C:\Program Files\PostgreSQL\18\bin\psql.exe"
SET "SCRIPT_PATH=%~dp0load_all_data.psql"
SET "DB_HOST=localhost"
SET "DB_USER=postgres"
SET "DB_NAME=nfl_db"

if not exist "%PSQL_PATH%" (
    echo ERROR: psql not found at %PSQL_PATH%
    echo Please install PostgreSQL or update PSQL_PATH in this batch file.
    pause
    exit /b 1
)
if not exist "%SCRIPT_PATH%" (
    echo ERROR: load_all_data.psql not found in the same folder as this batch file.
    echo Put run_load_all_data.bat and load_all_data.psql together in one folder.
    pause
    exit /b 1
)

echo Running data load script...
"%PSQL_PATH%" -h "%DB_HOST%" -U "%DB_USER%" -d "%DB_NAME%" -f "%SCRIPT_PATH%"
if errorlevel 1 (
    echo.
    echo ERROR: load script failed.
    pause
) else (
    echo.
    echo SUCCESS: load script completed.
    pause
)
