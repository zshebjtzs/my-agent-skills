# scripts/check-node.ps1
# Purpose: Check if Node.js is installed and display version information
# Usage: Run this script in any terminal

Write-Host "Checking Node.js environment..." -ForegroundColor Cyan

$nodeVersion = node -v 2>$null
if ($nodeVersion) {
    Write-Host "[OK] Node.js installed, version: $nodeVersion" -ForegroundColor Green
    $npmVersion = npm -v 2>$null
    if ($npmVersion) {
        Write-Host "[OK] npm installed, version: $npmVersion" -ForegroundColor Green
    } else {
        Write-Host "[WARN] npm not detected, installation may be incomplete." -ForegroundColor Yellow
    }
} else {
    Write-Host "[ERROR] Node.js not installed! Please download LTS version from https://nodejs.org/" -ForegroundColor Red
    Write-Host "After installation, restart your terminal and run this script again." -ForegroundColor Yellow
    exit 1
}
Write-Host "Environment check completed." -ForegroundColor Gray