# scripts/check-node.ps1
# 用途：检查 Node.js 是否已安装，并输出版本信息
# 使用：在任何终端运行此脚本

Write-Host "正在检查 Node.js 环境..." -ForegroundColor Cyan

$nodeVersion = node -v 2>$null
if ($nodeVersion) {
    Write-Host "✅ Node.js 已安装，版本：$nodeVersion" -ForegroundColor Green
    $npmVersion = npm -v 2>$null
    if ($npmVersion) {
        Write-Host "✅ npm 已安装，版本：$npmVersion" -ForegroundColor Green
    } else {
        Write-Host "⚠️ 未检测到 npm，可能安装不完整。" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Node.js 未安装！请前往 https://nodejs.org/ 下载 LTS 版本并安装。" -ForegroundColor Red
    Write-Host "安装后请重启终端再运行此脚本。" -ForegroundColor Yellow
    exit 1
}
Write-Host "环境检查完毕。" -ForegroundColor Gray