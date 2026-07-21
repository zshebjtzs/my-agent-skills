# scripts/build-and-pack.ps1
# 用途：构建 Vue 项目并打包为可离线运行的 zip 压缩包
# 使用：在项目根目录下运行此脚本（需先安装 Node.js 依赖）

param(
    [string]$version = $(Read-Host "请输入版本号（如 v1.0.0）")
)

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

# 执行构建
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

# 进入 dist 目录，打包所有文件为 zip（确保解压后直接看到 index.html）
$projectName = (Get-Item -Path ".").Name
$zipName = "$projectName-$version.zip"
$parentDir = (Get-Item -Path "..").FullName
$zipPath = Join-Path $parentDir $zipName

Write-Host "正在打包 dist/ 内容到 $zipPath ..." -ForegroundColor Cyan
# 使用 PowerShell 原生 Compress-Archive（无需额外工具）
Compress-Archive -Path "dist\*" -DestinationPath $zipPath -Force
if ($LASTEXITCODE -ne 0) {
    Write-Host "打包失败，请检查权限或磁盘空间。" -ForegroundColor Red
    exit 1
}
Write-Host "打包完成！压缩包位于：$zipPath" -ForegroundColor Green

# 同时打包源代码（可选，但按用户要求命名为 Source Code.zip）
$srcZipPath = Join-Path $parentDir "Source Code.zip"
Write-Host "正在打包源代码到 $srcZipPath（不含 node_modules、dist 等）..." -ForegroundColor Cyan
# 定义排除项（使用通配符）
$exclude = @("node_modules", "dist", ".git", "*.zip", ".vscode", ".idea")
$compressParams = @{
    Path = "."
    DestinationPath = $srcZipPath
    Force = $true
}
# Compress-Archive 不支持排除，改用 Include 或使用 Get-ChildItem 筛选
$itemsToZip = Get-ChildItem -Path "." -Exclude $exclude
Compress-Archive -Path $itemsToZip.FullName -DestinationPath $srcZipPath -Force
Write-Host "源代码打包完成。" -ForegroundColor Green

# 更新 .gitignore（添加 *.zip 如果不存在）
$gitignore = ".gitignore"
if (Test-Path $gitignore) {
    $content = Get-Content $gitignore
    if ($content -notcontains "*.zip") {
        Add-Content $gitignore "`n# Ignore zip packages for release`n*.zip"
        Write-Host "已向 .gitignore 添加 '*.zip' 规则。" -ForegroundColor Yellow
    } else {
        Write-Host ".gitignore 中已存在 '*.zip' 规则，无需重复添加。" -ForegroundColor Gray
    }
} else {
    Write-Host "警告：未找到 .gitignore 文件，建议手动创建并添加 '*.zip'。" -ForegroundColor Yellow
}

Write-Host "`n全部完成！请检查以下文件：`n  - $zipPath`n  - $srcZipPath" -ForegroundColor Green
Write-Host "你可以将这两个文件上传到 GitHub Release。" -ForegroundColor Cyan