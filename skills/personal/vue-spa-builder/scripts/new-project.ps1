# scripts/new-project.ps1
# 用途：交互式创建 Vue 3 + Vite 项目，并配置强制项（base 和 Hash 路由）
# 使用：在希望创建项目的父目录下运行

param(
    [string]$projectName = $(Read-Host "请输入项目名称（英文小写，如 my-tool）")
)

# 检查是否已存在同名文件夹
if (Test-Path $projectName) {
    Write-Host "错误：文件夹 '$projectName' 已存在，请更换名称。" -ForegroundColor Red
    exit 1
}

# 检查 Node 环境
$nodeVersion = node -v 2>$null
if (-not $nodeVersion) {
    Write-Host "错误：未检测到 Node.js，请先安装 Node.js。" -ForegroundColor Red
    Write-Host "下载地址：https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

Write-Host "正在使用 Vite 创建 Vue 3 项目：$projectName ..." -ForegroundColor Cyan
npm create vite@latest $projectName -- --template vue
if ($LASTEXITCODE -ne 0) {
    Write-Host "项目创建失败，请检查网络或手动执行 'npm create vite@latest'。" -ForegroundColor Red
    exit 1
}

# 进入项目目录
Set-Location $projectName

# 询问是否需要额外依赖
$extraDeps = @()
$choices = @("Pinia (状态管理)", "Vue Router (路由)", "Axios (HTTP)", "Vditor (Markdown编辑器)", "KaTeX (数学公式)")
Write-Host "`n可选的额外依赖（输入数字，多个用逗号分隔，如 1,2）:" -ForegroundColor Yellow
for ($i=0; $i -lt $choices.Length; $i++) {
    Write-Host "  $($i+1). $($choices[$i])"
}
$selection = Read-Host "请选择（直接回车跳过）"
if ($selection -ne "") {
    $indices = $selection -split ',' | ForEach-Object { $_.Trim() }
    foreach ($idx in $indices) {
        switch ($idx) {
            "1" { $extraDeps += "pinia" }
            "2" { $extraDeps += "vue-router@4" }
            "3" { $extraDeps += "axios" }
            "4" { $extraDeps += "vditor" }
            "5" { $extraDeps += "katex" }
            default { Write-Host "忽略无效选项: $idx" -ForegroundColor Gray }
        }
    }
}

if ($extraDeps.Count -gt 0) {
    Write-Host "正在安装额外依赖：$($extraDeps -join ' ')" -ForegroundColor Cyan
    npm install $extraDeps --save
    if ($LASTEXITCODE -ne 0) {
        Write-Host "依赖安装失败，请手动执行 npm install。" -ForegroundColor Red
    }
}

# 强制修改 vite.config.js
Write-Host "正在设置 vite.config.js (base: './') ..." -ForegroundColor Cyan
$viteConfig = @"
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  base: './'  // 强制相对路径，支持离线运行
})
"@
$viteConfig | Out-File -FilePath "vite.config.js" -Encoding utf8

# 若安装了 Vue Router，修改路由模式为 Hash
if ($extraDeps -contains "vue-router@4") {
    $routerFile = "src/router/index.js"
    if (Test-Path $routerFile) {
        Write-Host "正在将路由模式修改为 createWebHashHistory ..." -ForegroundColor Cyan
        $content = Get-Content $routerFile -Raw
        $newContent = $content -replace "createWebHistory", "createWebHashHistory"
        $newContent | Out-File -FilePath $routerFile -Encoding utf8
        Write-Host "路由模式已更新。" -ForegroundColor Green
    } else {
        Write-Host "未找到路由文件，请手动确认。" -ForegroundColor Yellow
    }
}

# ============================================================
# 更新 .gitignore：添加 *.zip 和三个说明文件
# ============================================================
$gitignore = ".gitignore"
$ignoreRules = @(
    "# Ignore release packages",
    "*.zip",
    "",
    "# Ignore readme files for release",
    "README.txt",
    "README_zh.txt",
    "README_en.txt"
)

if (Test-Path $gitignore) {
    $content = Get-Content $gitignore
    $needUpdate = $false
    
    # 检查 *.zip
    if ($content -notcontains "*.zip") {
        Add-Content $gitignore "`n# Ignore release packages`n*.zip"
        $needUpdate = $true
    }
    
    # 检查三个说明文件
    foreach ($file in @("README.txt", "README_zh.txt", "README_en.txt")) {
        if ($content -notcontains $file) {
            Add-Content $gitignore "`n# Ignore readme files for release`n$file"
            $needUpdate = $true
        }
    }
    
    if ($needUpdate) {
        Write-Host "已向 .gitignore 添加忽略规则。" -ForegroundColor Green
    } else {
        Write-Host ".gitignore 中已包含所有必要规则。" -ForegroundColor Gray
    }
} else {
    # 创建完整的 .gitignore
    @"
node_modules
.DS_Store
dist
*.zip
README.txt
README_zh.txt
README_en.txt
"@ | Out-File -FilePath $gitignore -Encoding utf8
    Write-Host "已创建 .gitignore 并添加完整规则。" -ForegroundColor Green
}

Write-Host "`n✅ 项目 '$projectName' 创建完成！" -ForegroundColor Green
Write-Host "下一步：`n  cd $projectName`n  npm run dev  # 启动开发服务器" -ForegroundColor Cyan
Write-Host "如需打包发布，请运行 .\scripts\build-and-pack.ps1" -ForegroundColor Cyan
Write-Host "`n说明文件将在首次构建时由 AI 生成，请让 AI 协助完成。" -ForegroundColor Yellow