# scripts/new-project.ps1
# Purpose: Interactively create a Vue 3 + Vite project with mandatory configurations (base and Hash routing)
# Usage: Run in the parent directory where you want to create the project

param(
    [string]$projectName = $(Read-Host "Enter project name (lowercase, e.g., my-tool)")
)

# ============================================================
# Helper: Write file with UTF-8 without BOM (supports new files)
# ============================================================
function Write-FileUtf8NoBom {
    param(
        [string]$Path,
        [string]$Content
    )
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    # Use GetUnresolvedProviderPathFromPSPath instead of Resolve-Path
    # The former can handle non-existent paths, the latter would crash
    $resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    [System.IO.File]::WriteAllText($resolvedPath, $Content, $utf8NoBom)
}

# ============================================================
# Helper: Write JSON config file
# ============================================================
function Write-ConfigFile {
    param(
        [string]$Path,
        [hashtable]$Data
    )
    $json = $Data | ConvertTo-Json -Depth 2
    Write-FileUtf8NoBom -Path $Path -Content $json
}

# ============================================================
# Phase 0: Environment check
# ============================================================

# Check if folder already exists
if (Test-Path $projectName) {
    Write-Host "[ERROR] Folder '$projectName' already exists. Please choose a different name." -ForegroundColor Red
    exit 1
}

# Check Node environment
$nodeVersion = node -v 2>$null
if (-not $nodeVersion) {
    Write-Host "[ERROR] Node.js not detected. Please install Node.js first." -ForegroundColor Red
    Write-Host "Download: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# ============================================================
# Phase 1: Create Vue project
# ============================================================
Write-Host "Creating Vue 3 project with Vite: $projectName ..." -ForegroundColor Cyan
npm create vite@latest $projectName -- --template vue
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Project creation failed. Please check network or run 'npm create vite@latest' manually." -ForegroundColor Red
    exit 1
}

# Enter project directory
Set-Location $projectName

# ============================================================
# Phase 2: Install additional dependencies
# ============================================================
$extraDeps = @()
$choices = @("Pinia (state management)", "Vue Router (routing)", "Axios (HTTP)", "Vditor (Markdown editor)", "KaTeX (math formulas)")
Write-Host "`nOptional dependencies (enter numbers, comma-separated, e.g., 1,2):" -ForegroundColor Yellow
for ($i=0; $i -lt $choices.Length; $i++) {
    Write-Host "  $($i+1). $($choices[$i])"
}
$selection = Read-Host "Select (press Enter to skip)"
if ($selection -ne "") {
    $indices = $selection -split ',' | ForEach-Object { $_.Trim() }
    foreach ($idx in $indices) {
        switch ($idx) {
            "1" { $extraDeps += "pinia" }
            "2" { $extraDeps += "vue-router@4" }
            "3" { $extraDeps += "axios" }
            "4" { $extraDeps += "vditor" }
            "5" { $extraDeps += "katex" }
            default { Write-Host "Ignoring invalid option: $idx" -ForegroundColor Gray }
        }
    }
}

if ($extraDeps.Count -gt 0) {
    Write-Host "Installing additional dependencies: $($extraDeps -join ' ')" -ForegroundColor Cyan
    npm install $extraDeps --save
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Dependency installation failed. Please run 'npm install' manually." -ForegroundColor Red
    }
}

# ============================================================
# Phase 2.5: Install vite-plugin-singlefile (mandatory dependency)
# ============================================================
Write-Host "Installing vite-plugin-singlefile (for offline single-file packaging)..." -ForegroundColor Cyan
npm install vite-plugin-singlefile --save-dev
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] vite-plugin-singlefile installation failed. Please run manually: npm install vite-plugin-singlefile --save-dev" -ForegroundColor Red
    # Do not exit, allow user to install manually later
}

# ============================================================
# Phase 3: Overwrite vite.config.js (UTF-8 without BOM)
# ============================================================
Write-Host "Setting up vite.config.js (with vite-plugin-singlefile)..." -ForegroundColor Cyan
$viteConfig = @"
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { viteSingleFile } from 'vite-plugin-singlefile'

export default defineConfig({
  plugins: [
    vue(),
    viteSingleFile(),  // Force inline all JS/CSS to solve file:// protocol CORS issue
  ],
  base: './',  // Force relative paths for offline support
  build: {
    target: 'es2015',
    assetsInlineLimit: 0,  // Keep images as external files
  }
})
"@
Write-FileUtf8NoBom -Path "vite.config.js" -Content $viteConfig

# ============================================================
# Phase 4: Create router file from template (if Vue Router selected)
# ============================================================
$routerInstalled = $extraDeps -contains "vue-router@4"
if ($routerInstalled) {
    $routerDir = "src/router"
    $routerFile = Join-Path $routerDir "index.js"
    
    # Create router directory if it doesn't exist
    if (-not (Test-Path $routerDir)) {
        New-Item -ItemType Directory -Path $routerDir -Force | Out-Null
    }
    
    # Get skill root directory (parent of the script's parent)
    $skillRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
    # Note: filename is router-index.template.js (template first)
    $templatePath = Join-Path $skillRoot "assets/router-index.template.js"
    
    if (Test-Path $templatePath) {
        Write-Host "Creating src/router/index.js from template (Hash mode)..." -ForegroundColor Cyan
        $templateContent = Get-Content $templatePath -Raw
        Write-FileUtf8NoBom -Path $routerFile -Content $templateContent
        Write-Host "Router file created." -ForegroundColor Green
    } else {
        Write-Host "[WARN] Template not found: $templatePath. Please create src/router/index.js manually." -ForegroundColor Yellow
        Write-Host "Reference: use createWebHashHistory() instead of createWebHistory()" -ForegroundColor Yellow
    }
}

# ============================================================
# Phase 5: Update .gitignore (UTF-8 without BOM)
# ============================================================
$gitignore = ".gitignore"

if (Test-Path $gitignore) {
    $content = Get-Content $gitignore
    $needUpdate = $false
    
    # Check *.zip using Select-String (regex matching, more robust)
    $zipRuleFound = $content | Select-String -Pattern '^\s*\*\.zip\s*$' -Quiet
    if (-not $zipRuleFound) {
        Add-Content $gitignore "`n# Ignore release packages`n*.zip"
        $needUpdate = $true
    }
    
    # Check the three readme files
    foreach ($file in @("README.txt", "README_zh.txt", "README_en.txt")) {
        $fileRuleFound = $content | Select-String -Pattern "^\s*$([regex]::Escape($file))\s*$" -Quiet
        if (-not $fileRuleFound) {
            Add-Content $gitignore "`n# Ignore readme files for release`n$file"
            $needUpdate = $true
        }
    }
    
    if ($needUpdate) {
        Write-Host "Added ignore rules to .gitignore." -ForegroundColor Green
    } else {
        Write-Host ".gitignore already contains all required rules." -ForegroundColor Gray
    }
} else {
    # Create complete .gitignore (UTF-8 without BOM) with standard security entries
    $gitignoreContent = @"
node_modules
.DS_Store
dist
*.zip
README.txt
README_zh.txt
README_en.txt

# Environment files (if you add a backend later)
.env
.env.*
*.log
local/
"@
    Write-FileUtf8NoBom -Path $gitignore -Content $gitignoreContent
    Write-Host "Created .gitignore with complete rules." -ForegroundColor Green
}

# ============================================================
# Phase 6: GitHub repository configuration
# ============================================================
Write-Host "`n--- GitHub Repository Setup ---" -ForegroundColor Cyan
$githubEnabled = Read-Host "Do you plan to open-source this project on GitHub? (y/n)"
$configData = @{}

if ($githubEnabled -eq 'y' -or $githubEnabled -eq 'Y') {
    $username = Read-Host "Enter your GitHub username"
    $repo = Read-Host "Enter the repository name"
    
    if ($username -and $repo) {
        $configData = @{
            github = @{
                enabled = $true
                username = $username
                repo = $repo
            }
        }
        Write-ConfigFile -Path ".skill-config.json" -Data $configData
        Write-Host "[OK] GitHub configuration saved to .skill-config.json" -ForegroundColor Green
        Write-Host "  Repo URL: https://github.com/$username/$repo" -ForegroundColor Gray
    } else {
        Write-Host "[WARN] Username or repository name was empty. Skipping GitHub configuration." -ForegroundColor Yellow
        Write-Host "You can configure it later by telling the AI: 'Add GitHub info: username X, repo Y'" -ForegroundColor Yellow
    }
} else {
    Write-Host "GitHub configuration skipped. You can add it later by telling the AI." -ForegroundColor Gray
    Write-Host "Example: 'Add GitHub info: username myname, repo my-tool'" -ForegroundColor Gray
}

# ============================================================
# Phase 7: Completion
# ============================================================
Write-Host "`n[OK] Project '$projectName' created successfully!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  cd $projectName" -ForegroundColor Cyan
Write-Host "  npm run dev  # Start development server" -ForegroundColor Cyan
Write-Host "To build for release, run .\scripts\build-and-pack.ps1" -ForegroundColor Cyan
if ($routerInstalled) {
    Write-Host "Vue Router (Hash mode) configured. Add your routes as needed." -ForegroundColor Green
}
Write-Host "`nReadme files will be generated by AI during first build. Please let AI assist." -ForegroundColor Yellow