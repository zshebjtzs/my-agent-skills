# scripts/build-and-pack.ps1
# Purpose: Build Vue project and package as an offline-ready zip archive
# Usage: Run from project root (where package.json is located)
# Parameters:
#   -version           Version number (e.g., v1.0.0), interactive input if omitted
#   -SkipSourceZip     Skip source code packaging, only generate project archive
#   -SkipGitHubCheck   Skip GitHub info injection into readme files
#   -SkipValidation    Skip post-build validation

param(
    [string]$version = $(Read-Host "Enter version number (e.g., v1.0.0)"),
    [switch]$SkipSourceZip,
    [switch]$SkipGitHubCheck,
    [switch]$SkipValidation
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
# Phase 1.5: Inject GitHub info from .skill-config.json (unless skipped)
# ============================================================
if (-not $SkipGitHubCheck) {
    $configFile = ".skill-config.json"
    if (Test-Path $configFile) {
        try {
            $config = Get-Content $configFile -Raw | ConvertFrom-Json
            if ($config.github -and $config.github.enabled -eq $true) {
                $username = $config.github.username
                $repo = $config.github.repo
                if ($username -and $repo) {
                    $repoUrl = "https://github.com/$username/$repo"
                    Write-Host "GitHub repo detected: $repoUrl" -ForegroundColor Cyan
                    
                    # Inject/update GitHub info into readme files
                    foreach ($file in $existingReadmes) {
                        $content = Get-Content $file -Raw
                        # Check if GitHub line already exists
                        $githubLinePattern = "(?m)^GitHub:\s*https?://github\.com/[\w\-\.]+/[\w\-\.]+$"
                        $newLine = "GitHub: $repoUrl"
                        
                        if ($content -match $githubLinePattern) {
                            # Replace existing GitHub line
                            $content = $content -replace $githubLinePattern, $newLine
                        } else {
                            # Insert after project name line (first line that looks like a title)
                            # Find first non-empty line that looks like a title or project name
                            $lines = $content -split "`r`n|`n"
                            $insertIndex = -1
                            for ($i = 0; $i -lt $lines.Count; $i++) {
                                if ($lines[$i] -match '^(Project Name|Name):\s*\S+') {
                                    $insertIndex = $i + 1
                                    break
                                }
                            }
                            if ($insertIndex -eq -1) {
                                # Fallback: insert after first non-empty line
                                for ($i = 0; $i -lt $lines.Count; $i++) {
                                    if ($lines[$i] -match '\S') {
                                        $insertIndex = $i + 1
                                        break
                                    }
                                }
                            }
                            if ($insertIndex -gt 0 -and $insertIndex -le $lines.Count) {
                                $lines = $lines[0..($insertIndex-1)] + @($newLine) + $lines[$insertIndex..($lines.Count-1)]
                            } else {
                                # Fallback: append to end
                                $lines += $newLine
                            }
                            $content = $lines -join "`n"
                        }
                        
                        # Write back with UTF-8 without BOM
                        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
                        $resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($file)
                        [System.IO.File]::WriteAllText($resolvedPath, $content, $utf8NoBom)
                    }
                    Write-Host "GitHub info injected into readme files." -ForegroundColor Green
                }
            }
        } catch {
            Write-Host "[WARN] Failed to parse .skill-config.json: $_" -ForegroundColor Yellow
            Write-Host "GitHub info injection skipped." -ForegroundColor Yellow
        }
    }
}

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
# Phase 4.5: Post-build validation (unless skipped)
# ============================================================
if (-not $SkipValidation) {
    Write-Host "`n--- Post-build validation ---" -ForegroundColor Cyan
    $validationPassed = $true
    $indexHtml = Join-Path "dist" "index.html"
    
    if (Test-Path $indexHtml) {
        $content = Get-Content $indexHtml -Raw
        
        # Check 1: Verify base: './' is NOT needed in HTML (it's a Vite build-time config)
        # But we can check if there are any absolute paths starting with '/'
        $absolutePathPattern = '(src|href)\s*=\s*"/(?!assets|favicon\.svg)'
        if ($content -match $absolutePathPattern) {
            Write-Host "  [WARN] Found absolute paths starting with '/' in index.html. This may cause issues in file:// protocol." -ForegroundColor Yellow
            Write-Host "    Make sure vite.config.js has base: './'" -ForegroundColor Yellow
            $validationPassed = $false
        } else {
            Write-Host "  [OK] No absolute paths found in index.html" -ForegroundColor Green
        }
        
        # Check 2: Verify JS/CSS are inlined (not loaded via external src/link)
        # Look for script tags with src attribute pointing to .js files
        $externalScriptPattern = '<script[^>]*src\s*=\s*"[^"]*\.js[^"]*"[^>]*>'
        $externalCssPattern = '<link[^>]*rel\s*=\s*"stylesheet"[^>]*href\s*=\s*"[^"]*\.css[^"]*"[^>]*>'
        
        $externalScripts = [regex]::Matches($content, $externalScriptPattern)
        $externalCss = [regex]::Matches($content, $externalCssPattern)
        
        # Check if there are any external script/css references
        # Note: Some references like favicon are fine
        $hasExternalJs = $externalScripts.Count -gt 0
        $hasExternalCss = $externalCss.Count -gt 0
        
        if ($hasExternalJs -or $hasExternalCss) {
            Write-Host "  [WARN] Found external JS or CSS references. This may cause CORS issues in file:// protocol." -ForegroundColor Yellow
            if ($hasExternalJs) {
                Write-Host "    Found $($externalScripts.Count) external script reference(s)" -ForegroundColor Yellow
                # Show first match
                $firstMatch = $externalScripts[0].Value
                if ($firstMatch.Length -gt 100) { $firstMatch = $firstMatch.Substring(0, 100) + "..." }
                Write-Host "    Example: $firstMatch" -ForegroundColor Gray
            }
            if ($hasExternalCss) {
                Write-Host "    Found $($externalCss.Count) external CSS reference(s)" -ForegroundColor Yellow
                $firstMatch = $externalCss[0].Value
                if ($firstMatch.Length -gt 100) { $firstMatch = $firstMatch.Substring(0, 100) + "..." }
                Write-Host "    Example: $firstMatch" -ForegroundColor Gray
            }
            Write-Host "    Ensure vite-plugin-singlefile is properly configured." -ForegroundColor Yellow
            $validationPassed = $false
        } else {
            Write-Host "  [OK] No external JS/CSS references found (all inlined)" -ForegroundColor Green
        }
        
        # Check 3: Check file size - warn if unusually large (over 5MB)
        $fileInfo = Get-Item $indexHtml
        if ($fileInfo.Length -gt 5MB) {
            Write-Host "  [WARN] index.html is quite large ($([math]::Round($fileInfo.Length/1MB, 2)) MB)." -ForegroundColor Yellow
            Write-Host "    Consider reviewing assetsInlineLimit setting if images are being inlined unnecessarily." -ForegroundColor Yellow
        } else {
            Write-Host "  [OK] index.html size: $([math]::Round($fileInfo.Length/1KB, 2)) KB" -ForegroundColor Green
        }
        
        if ($validationPassed) {
            Write-Host "[OK] All validation checks passed." -ForegroundColor Green
        } else {
            Write-Host "[WARN] Some validation checks produced warnings. The package should still work, but review the warnings above." -ForegroundColor Yellow
        }
    } else {
        Write-Host "[WARN] dist/index.html not found. Validation skipped." -ForegroundColor Yellow
    }
    Write-Host ""
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
    
    # Check .skill-config.json
    $configRuleFound = $content | Select-String -Pattern '^\s*\.skill-config\.json\s*$' -Quiet
    if (-not $configRuleFound) {
        Add-Content $gitignore "`n# Ignore skill configuration`n.skill-config.json"
        Write-Host "Added '.skill-config.json' rule to .gitignore." -ForegroundColor Yellow
        $needUpdate = $true
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
    Write-Host "  .skill-config.json" -ForegroundColor Yellow
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