#!/bin/bash
# MilkMaster Setup Script for Linux/macOS
# This script automates the setup process for the MilkMaster application

echo "=== MilkMaster Setup Script ==="
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "ERROR: .env file not found in the current directory!"
    echo "Please unzip the .env file to the MilkMaster/ root directory and run this script again."
    exit 1
fi

echo "[1/3] .env file found ✓"
echo ""

# Navigate to MilkMaster.Domain and add migration
echo "[2/3] Creating database migration..."
cd MilkMaster.Domain || exit 1

echo "Running: dotnet ef migrations add InitialMigration"
if ! dotnet ef migrations add InitialMigration; then
    echo "ERROR: Failed to create migration"
    exit 1
fi

echo "Migration created successfully ✓"
cd .. || exit 1
echo ""

# Run Docker Compose
echo "[3/3] Starting Docker containers..."
echo "Running: docker-compose up --build -d"

if ! docker-compose up --build -d; then
    echo "ERROR: Failed to start Docker containers"
    exit 1
fi

echo "Docker containers started successfully ✓"
echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Application is now running!"
echo "You can check the status with: docker-compose ps"
echo ""
