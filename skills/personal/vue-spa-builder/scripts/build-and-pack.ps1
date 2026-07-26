# scripts/build-and-pack.ps1
# Purpose: Build Vue project and package as an offline-ready zip archive
# Usage: Run from project root (where package.json is located)
# Parameters:
#   -version       Version number (e.g., v1.0.0), interactive input if omitted
#   -SkipSourceZip Skip source code packaging, only generate project archive

param(
    [string]$version = $(Read-Host "Enter version number (e.g., v1.0.0)"),
    [switch]$SkipSourceZip
)

# ============================================================
# Phase 0: Environment check
# ============================================================

# Check if running from project root (package.json exists)
if (-not (Test-Path "package.json")) {
    Write-Host "[ERROR] Please run this script from the project root (where package.json is located)." -ForegroundColor Red
    exit 1
}

# Check if Node.js is installed
$nodeVersion = node -v 2>$null
if (-not $nodeVersion) {
    Write-Host "[ERROR] Node.js not detected. Please install Node.js." -ForegroundColor Red
    Write-Host "Download: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}
Write-Host "Node.js version detected: $nodeVersion" -ForegroundColor Green

# Check if dependencies are installed
if (-not (Test-Path "node_modules")) {
    Write-Host "Dependencies not installed. Running npm install ..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] npm install failed. Please check network or run manually." -ForegroundColor Red
        exit 1
    }
}

# ============================================================
# Phase 1: Check if readme files exist
# ============================================================
$readmeFiles = @("README.txt", "README_zh.txt", "README_en.txt")
$existingReadmes = @()
foreach ($file in $readmeFiles) {
    if (Test-Path $file) {
        $existingReadmes += $file
    }
}

if ($existingReadmes.Count -eq 0) {
    Write-Host "[ERROR] No readme files detected (README.txt / README_zh.txt / README_en.txt)." -ForegroundColor Red
    Write-Host "Please ask AI to generate readme files, or manually create README.txt in project root." -ForegroundColor Yellow
    exit 1
}

Write-Host "Detected readme files: $($existingReadmes -join ', ')" -ForegroundColor Green

# ============================================================
# Phase 2: Run build
# ============================================================
Write-Host "Building project (npm run build)..." -ForegroundColor Cyan
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Build failed. Please check project configuration." -ForegroundColor Red
    exit 1
}
Write-Host "Build successful! dist/ directory generated." -ForegroundColor Green

# Check if dist exists
if (-not (Test-Path "dist")) {
    Write-Host "[ERROR] dist/ directory not found. Build may not have completed." -ForegroundColor Red
    exit 1
}

# ============================================================
# Phase 3: Copy readme files to dist/ (with error handling)
# ============================================================
Write-Host "Copying readme files to dist/ ..." -ForegroundColor Cyan
foreach ($file in $existingReadmes) {
    try {
        Copy-Item -Path $file -Destination "dist\" -Force -ErrorAction Stop
        Write-Host "  Copied: $file" -ForegroundColor Gray
    } catch {
        Write-Host "[ERROR] Failed to copy $file to dist/: $_" -ForegroundColor Red
        exit 1
    }
}
Write-Host "Readme files copied." -ForegroundColor Green

# ============================================================
# Phase 4: Package dist/ as zip (with try/catch)
# ============================================================
$projectName = (Get-Item -Path ".").Name
$zipName = "$projectName-$version.zip"
$parentDir = (Get-Item -Path "..").FullName
$zipPath = Join-Path $parentDir $zipName

Write-Host "Packaging dist/ contents to $zipPath ..." -ForegroundColor Cyan

try {
    Compress-Archive -Path "dist\*" -DestinationPath $zipPath -Force -ErrorAction Stop
    Write-Host "Package complete! Archive located at: $zipPath" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Packaging failed: $_" -ForegroundColor Red
    exit 1
}

# ============================================================
# Phase 5: Package source code (controlled by -SkipSourceZip)
# ============================================================
if ($SkipSourceZip) {
    Write-Host "Skipped source code packaging (-SkipSourceZip specified)." -ForegroundColor Gray
} else {
    $srcZipPath = Join-Path $parentDir "Source Code.zip"
    Write-Host "Packaging source code to $srcZipPath (excluding node_modules, dist, etc.)..." -ForegroundColor Cyan
    $exclude = @("node_modules", "dist", ".git", "*.zip", ".vscode", ".idea")
    $itemsToZip = Get-ChildItem -Path "." -Exclude $exclude
    
    try {
        Compress-Archive -Path $itemsToZip.FullName -DestinationPath $srcZipPath -Force -ErrorAction Stop
        Write-Host "Source code packaging complete." -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Source code packaging failed: $_" -ForegroundColor Red
        exit 1
    }
}

# ============================================================
# Phase 6: Update .gitignore (using Select-String regex matching)
# ============================================================
$gitignore = ".gitignore"
if (Test-Path $gitignore) {
    $content = Get-Content $gitignore
    $needUpdate = $false
    
    # Check *.zip (using Select-String for line matching, more robust)
    $zipRuleFound = $content | Select-String -Pattern '^\s*\*\.zip\s*$' -Quiet
    if (-not $zipRuleFound) {
        Add-Content $gitignore "`n# Ignore release packages`n*.zip"
        Write-Host "Added '*.zip' rule to .gitignore." -ForegroundColor Yellow
        $needUpdate = $true
    }
    
    # Check the three readme files
    foreach ($file in $readmeFiles) {
        $fileRuleFound = $content | Select-String -Pattern "^\s*$([regex]::Escape($file))\s*$" -Quiet
        if (-not $fileRuleFound) {
            Add-Content $gitignore "`n# Ignore readme files for release`n$file"
            Write-Host "Added '$file' rule to .gitignore." -ForegroundColor Yellow
            $needUpdate = $true
        }
    }
    
    if (-not $needUpdate) {
        Write-Host ".gitignore already contains all required rules." -ForegroundColor Gray
    }
} else {
    Write-Host "[WARN] .gitignore not found. Please manually add the following rules:" -ForegroundColor Yellow
    Write-Host "  *.zip" -ForegroundColor Yellow
    Write-Host "  README.txt" -ForegroundColor Yellow
    Write-Host "  README_zh.txt" -ForegroundColor Yellow
    Write-Host "  README_en.txt" -ForegroundColor Yellow
}

# ============================================================
# Phase 7: Completion
# ============================================================
Write-Host "`nAll done!" -ForegroundColor Green
Write-Host "  - Release package: $zipPath" -ForegroundColor Cyan
if (-not $SkipSourceZip) {
    Write-Host "  - Source package: $srcZipPath" -ForegroundColor Cyan
}
Write-Host "You can upload these files to GitHub Release." -ForegroundColor Cyan