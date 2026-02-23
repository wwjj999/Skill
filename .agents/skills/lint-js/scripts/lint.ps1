# JavaScript Lint - PowerShell Script
param(
    [string]$Path = ".",
    [switch]$Fix = $false,
    [string]$Extensions = "js,jsx,ts,tsx",
    [switch]$AllowProtected = $false
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Write-Host "🔍 JavaScript Lint - ESLint" -ForegroundColor Cyan
Write-Host ""

# 检查 Node.js 和 ESLint
try {
    node --version | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Node not found" }
} catch {
    Write-Host "❌ Node.js 未安装: https://nodejs.org" -ForegroundColor Red
    exit 1
}

try {
    eslint --version | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "ESLint not found" }
} catch {
    Write-Host "⚠️  正在安装 ESLint..." -ForegroundColor Yellow
    npm install -g eslint
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 请手动安装: npm install -g eslint" -ForegroundColor Red
        exit 1
    }
}

$resolvedPath = Resolve-Path -Path $Path -ErrorAction SilentlyContinue
if (-not $resolvedPath) {
    Write-Host "❌ 路径不存在: $Path" -ForegroundColor Red
    exit 1
}

$extSet = $Extensions.Split(',') | ForEach-Object { $_.Trim().ToLower().TrimStart('.') } | Where-Object { $_ }
$files = Get-ChildItem -Path $resolvedPath -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $extSet -contains $_.Extension.TrimStart('.').ToLower() }

if (-not $AllowProtected) {
    $files = $files | Where-Object {
        $_.FullName -notmatch '[\\/]\.agents[\\/]' -and
        $_.FullName -notmatch '[\\/]bmad[\\/]' -and
        $_.Name -ne 'README.md'
    }
}

if (-not $files -or $files.Count -eq 0) {
    Write-Host "ℹ️ 未找到可检查文件" -ForegroundColor Yellow
    exit 0
}

$args = @()
if ($Fix) { $args += "--fix" }
$args += ($files | Select-Object -ExpandProperty FullName)

& eslint @args
exit $LASTEXITCODE
