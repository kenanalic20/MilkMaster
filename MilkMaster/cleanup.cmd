@echo off
REM MilkMaster Cleanup Script for Windows (Command Prompt)
REM This script stops Docker containers and removes migrations

echo === MilkMaster Cleanup Script ===
echo.

REM Stop and remove Docker containers
echo [1/2] Stopping Docker containers...
echo Running: docker-compose down

docker-compose down

if %errorlevel% neq 0 (
    echo WARNING: Docker compose down failed or no containers were running
)

echo Docker containers stopped
echo.

REM Remove Migrations folder
echo [2/2] Removing migrations folder...

if exist "MilkMaster.Domain\Migrations" (
    echo Deleting: MilkMaster.Domain\Migrations
    rmdir /s /q "MilkMaster.Domain\Migrations"
    echo Migrations folder removed successfully
) else (
    echo Migrations folder does not exist, skipping...
)

echo.
echo === Cleanup Complete! ===
echo.
echo Docker containers have been stopped and migrations have been removed.
echo You can now run setup.cmd again to start fresh.
echo.
