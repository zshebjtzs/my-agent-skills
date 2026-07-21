# scripts/build-and-pack.ps1
# 用途：构建 Vue 项目并打包为可离线运行的 zip 压缩包
# 使用：在项目根目录下运行此脚本（需先安装 Node.js 依赖）
# 参数：
#   -version       版本号（如 v1.0.0），若未提供则交互式输入
#   -SkipSourceZip 跳过源代码打包，仅生成项目压缩包

param(
    [string]$version = $(Read-Host "请输入版本号（如 v1.0.0）"),
    [switch]$SkipSourceZip
)

# ============================================================
# 阶段 0：环境检查
# ============================================================

# 检查是否在项目根目录（存在 package.json）
if (-not (Test-Path "package.json")) {
    Write-Host "错误：请在项目根目录（含 package.json）运行此脚本。" -ForegroundColor Red
    exit 1
}

# 检查 Node.js 是否安装
$nodeVersion = node -v 2>$null
if (-not $nodeVersion) {
    Write-Host "错误：未检测到 Node.js，请先安装 Node.js。" -ForegroundColor Red
    Write-Host "下载地址：https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}
Write-Host "检测到 Node.js 版本：$nodeVersion" -ForegroundColor Green

# 检查依赖是否已安装
if (-not (Test-Path "node_modules")) {
    Write-Host "依赖未安装，正在执行 npm install ..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "npm install 失败，请检查网络或手动安装。" -ForegroundColor Red
        exit 1
    }
}

# ============================================================
# 阶段 1：检查说明文件是否存在
# ============================================================
$readmeFiles = @("README.txt", "README_zh.txt", "README_en.txt")
$existingReadmes = @()
foreach ($file in $readmeFiles) {
    if (Test-Path $file) {
        $existingReadmes += $file
    }
}

if ($existingReadmes.Count -eq 0) {
    Write-Host "错误：未检测到任何说明文件（README.txt / README_zh.txt / README_en.txt）。" -ForegroundColor Red
    Write-Host "请让 AI 先生成说明文件，或手动在项目根目录创建 README.txt。" -ForegroundColor Yellow
    exit 1
}

Write-Host "检测到说明文件：$($existingReadmes -join ', ')" -ForegroundColor Green

# ============================================================
# 阶段 2：执行构建
# ============================================================
Write-Host "开始构建项目（npm run build）..." -ForegroundColor Cyan
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "构建失败，请检查项目配置。" -ForegroundColor Red
    exit 1
}
Write-Host "构建成功！生成 dist/ 目录。" -ForegroundColor Green

# 检查 dist 是否存在
if (-not (Test-Path "dist")) {
    Write-Host "错误：未找到 dist/ 目录，构建可能未完成。" -ForegroundColor Red
    exit 1
}

# ============================================================
# 阶段 3：复制说明文件到 dist/（带错误处理）
# ============================================================
Write-Host "正在复制说明文件到 dist/ 目录..." -ForegroundColor Cyan
foreach ($file in $existingReadmes) {
    try {
        Copy-Item -Path $file -Destination "dist\" -Force -ErrorAction Stop
        Write-Host "  已复制: $file" -ForegroundColor Gray
    } catch {
        Write-Host "错误：复制 $file 到 dist/ 失败：$_" -ForegroundColor Red
        exit 1
    }
}
Write-Host "说明文件复制完成。" -ForegroundColor Green

# ============================================================
# 阶段 4：打包 dist/ 为 zip（使用 try/catch）
# ============================================================
$projectName = (Get-Item -Path ".").Name
$zipName = "$projectName-$version.zip"
$parentDir = (Get-Item -Path "..").FullName
$zipPath = Join-Path $parentDir $zipName

Write-Host "正在打包 dist/ 内容到 $zipPath ..." -ForegroundColor Cyan

try {
    Compress-Archive -Path "dist\*" -DestinationPath $zipPath -Force -ErrorAction Stop
    Write-Host "打包完成！压缩包位于：$zipPath" -ForegroundColor Green
} catch {
    Write-Host "打包失败：$_" -ForegroundColor Red
    exit 1
}

# ============================================================
# 阶段 5：打包源代码（受 -SkipSourceZip 控制）
# ============================================================
if ($SkipSourceZip) {
    Write-Host "已跳过源代码打包（-SkipSourceZip 指定）。" -ForegroundColor Gray
} else {
    $srcZipPath = Join-Path $parentDir "Source Code.zip"
    Write-Host "正在打包源代码到 $srcZipPath（不含 node_modules、dist 等）..." -ForegroundColor Cyan
    $exclude = @("node_modules", "dist", ".git", "*.zip", ".vscode", ".idea")
    $itemsToZip = Get-ChildItem -Path "." -Exclude $exclude
    
    try {
        Compress-Archive -Path $itemsToZip.FullName -DestinationPath $srcZipPath -Force -ErrorAction Stop
        Write-Host "源代码打包完成。" -ForegroundColor Green
    } catch {
        Write-Host "源代码打包失败：$_" -ForegroundColor Red
        exit 1
    }
}

# ============================================================
# 阶段 6：更新 .gitignore（使用 Select-String 正则匹配）
# ============================================================
$gitignore = ".gitignore"
if (Test-Path $gitignore) {
    $content = Get-Content $gitignore
    $needUpdate = $false
    
    # 检查 *.zip（使用 Select-String 匹配整行，更稳健）
    $zipRuleFound = $content | Select-String -Pattern '^\s*\*\.zip\s*$' -Quiet
    if (-not $zipRuleFound) {
        Add-Content $gitignore "`n# Ignore release packages`n*.zip"
        Write-Host "已向 .gitignore 添加 '*.zip' 规则。" -ForegroundColor Yellow
        $needUpdate = $true
    }
    
    # 检查三个说明文件
    foreach ($file in $readmeFiles) {
        $fileRuleFound = $content | Select-String -Pattern "^\s*$([regex]::Escape($file))\s*$" -Quiet
        if (-not $fileRuleFound) {
            Add-Content $gitignore "`n# Ignore readme files for release`n$file"
            Write-Host "已向 .gitignore 添加 '$file' 规则。" -ForegroundColor Yellow
            $needUpdate = $true
        }
    }
    
    if (-not $needUpdate) {
        Write-Host ".gitignore 中已包含所有必要规则。" -ForegroundColor Gray
    }
} else {
    Write-Host "警告：未找到 .gitignore 文件，建议手动创建并添加以下规则：" -ForegroundColor Yellow
    Write-Host "  *.zip" -ForegroundColor Yellow
    Write-Host "  README.txt" -ForegroundColor Yellow
    Write-Host "  README_zh.txt" -ForegroundColor Yellow
    Write-Host "  README_en.txt" -ForegroundColor Yellow
}

# ============================================================
# 完成
# ============================================================
Write-Host "`n全部完成！" -ForegroundColor Green
Write-Host "  - 发行包: $zipPath" -ForegroundColor Cyan
if (-not $SkipSourceZip) {
    Write-Host "  - 源码包: $srcZipPath" -ForegroundColor Cyan
}
Write-Host "你可以将以上文件上传到 GitHub Release。" -ForegroundColor Cyan