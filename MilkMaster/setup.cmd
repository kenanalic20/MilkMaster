@echo off
REM MilkMaster Setup Script for Windows (Command Prompt)
REM This script automates the setup process for the MilkMaster application

echo === MilkMaster Setup Script ===
echo.

REM Check if .env file exists
if not exist ".env" (
    echo ERROR: .env file not found in the current directory!
    echo Please unzip the .env file to the MilkMaster/ root directory and run this script again.
    exit /b 1
)

echo [1/3] .env file found
echo.

REM Navigate to MilkMaster.Domain and add migration
echo [2/3] Creating database migration...
cd MilkMaster.Domain

echo Running: dotnet ef migrations add InitialMigration
dotnet ef migrations add InitialMigration

if %errorlevel% neq 0 (
    echo ERROR: Failed to create migration
    cd ..
    exit /b 1
)

echo Migration created successfully
cd ..
echo.

REM Run Docker Compose
echo [3/3] Starting Docker containers...
echo Running: docker-compose up --build -d

docker-compose up --build -d

if %errorlevel% neq 0 (
    echo ERROR: Failed to start Docker containers
    exit /b 1
)

echo Docker containers started successfully
echo.
echo === Setup Complete! ===
echo.
echo Application is now running!
echo You can check the status with: docker-compose ps
echo.
