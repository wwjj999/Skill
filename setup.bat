@echo off
chcp 65001 >nul
setlocal

REM Ensure we run from the project root (where this script lives)
cd /d "%~dp0"

echo [AGENTS-MD] Bootstrapping Environment... / 正在引导环境...
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set "iso_date=%%i"
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-Item '%CD%').Name"') do set "project_name=%%i"

REM Check for Node.js
node --version >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Node.js not found. BMad-Method will run in degraded mode. / 未找到 Node.js，BMad-Method 将以降级模式运行。
    echo          Install Node.js v20+ for full functionality. / 请安装 Node.js v20+ 以获取完整功能。
)

REM ============================================================
REM  Python Environment Auto-Detection / Python 环境自动检测
REM ============================================================
echo.
echo === Python Environment Check / Python 环境检测 ===

REM --- Level 1: Python availability / 第 1 级：Python 可用性 ---
REM Try 'python' first, then 'py' (Windows Python Launcher)
set "PYTHON_CMD="
python --version >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set "PYTHON_CMD=python"
    goto :python_found
)
py --version >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set "PYTHON_CMD=py"
    goto :python_found
)

echo   [WARNING] Python not found! Some features will be unavailable.
echo            未找到 Python！部分功能将不可用。
echo            Please install Python 3.8+ from https://python.org
echo            请从 https://python.org 安装 Python 3.8+
goto :skip_python_deps

:python_found
for /f "delims=" %%v in ('%PYTHON_CMD% --version 2^>^&1') do set "py_ver=%%v"
echo   [OK] %py_ver% detected (via %PYTHON_CMD%) / 已检测到

REM --- Level 2: Core dependencies check / 第 2 级：核心依赖逐包检测 ---
call :check_pkg psutil psutil
call :check_pkg yaml PyYAML

REM --- Level 3: Optional dependencies hint / 第 3 级：可选依赖提示 ---
call :check_optional plyer plyer "desktop notifications / 桌面通知"

echo === Environment Check Complete / 环境检测完成 ===
echo.

:skip_python_deps

echo. > .ag_env_verified
if exist .ag_env_verified attrib +h .ag_env_verified

REM Check for PROJECT_STATUS.md
if not exist PROJECT_STATUS.md (
    echo.
    echo ========================================================
    echo [AGENTS-MD] First-time setup detected. / 检测到首次初始化。
    echo ========================================================
    echo.
    echo [AGENTS-MD] Creating PROJECT_STATUS.md with Progressive mode... / 正在使用 Progressive 模式创建 PROJECT_STATUS.md...
    call :create_status
    echo.
)

echo [AGENTS-MD] Setup Complete. Agent Environment is ready for Passive Context. / 初始化完成。Agent 环境已准备就绪。
goto :end

REM ============================================================
REM  Subroutine: check_pkg <import_name> <pip_name>
REM  Check and install a required Python package
REM ============================================================
:check_pkg
%PYTHON_CMD% -c "import %~1" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo   [OK] %~2 already installed / 已安装
    goto :eof
)
echo   [..] %~2 not found, installing... / 未找到，正在安装...
%PYTHON_CMD% -m pip install %~2 --quiet
if %ERRORLEVEL% EQU 0 (
    echo   [OK] %~2 installed successfully / 安装成功
    goto :eof
)
echo   [FAIL] %~2 install failed / 安装失败
echo         Please run manually / 请手动运行: %PYTHON_CMD% -m pip install %~2
goto :eof

REM ============================================================
REM  Subroutine: check_optional <import_name> <pip_name> <desc>
REM  Check optional dependency (hint only, no auto-install)
REM ============================================================
:check_optional
%PYTHON_CMD% -c "import %~1" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo   [OK] %~2 installed ^(%~3^) / 已安装
    goto :eof
)
echo   [INFO] %~2 not installed (optional: %~3)
echo         如需安装 / To install: %PYTHON_CMD% -m pip install %~2
goto :eof

REM ============================================================
REM  Subroutine: create_status
REM  Create PROJECT_STATUS.md
REM ============================================================
:create_status
(
    echo # PROJECT_STATUS.md
    echo.
    echo ## Schema: Project Status
    echo.
    echo - document_type: project_status_tracking
    echo - governance_mode: Progressive
    echo - target_audience: ai_agents
    echo - enforcement_level: mandatory
    echo - last_updated: %iso_date%
    echo - compatible_with: Agents-MD Pro v8.0
    echo.
    echo ---
    echo.
    echo ## Governance Mode / 治理模式
    echo.
    echo **Mode**: Progressive ✅
    echo.
    echo **Description**: 
    echo Keep old files, write new code via protocol. / 保留旧文件，新代码遵循协议规范。
    echo.
    echo ---
    echo.
    echo ## Project Skeleton / 项目结构
    echo.
    echo %project_name%/
    echo ├── .agents/             # Protocol Land ^(Immutable Core Rules^)
    echo ├── scripts/             # Core Utilities ^& Configuration
    echo ├── bmad/                # BMAD Method workflows
    echo ├── context/             # Memory and status
    echo ├── docs/                # Documentation
    echo ├── AGENTS_INDEX.yaml    # Knowledge Index
    echo ├── *.md                 # Master boot and AI adapters
    echo ├── *.py                 # Root-level utility scripts
    echo └── setup.bat/sh         # Environment setup
    echo \`\`\`
    echo.
    echo ---
    echo.
    echo ## Tech Stack / 技术栈
    echo.
    echo - **Languages**: Python ^(utility scripts^)
    echo - **Protocols**: Agents-MD Pro v8.0, BMAD Method
    echo - **Supported Languages**: zh-CN, en
    echo.
    echo ---
    echo.
    echo ## Architectural Decisions / 架构决策
    echo.
    echo ^| ADR ^| Title ^| Status ^|
    echo ^|-----^|-------^|--------^|
    echo ^| ADR-001 ^| 混合智能架构 ^| ✅ Active ^|
    echo ^| ADR-002 ^| 禁用 Eval ^| ✅ Active ^|
    echo ^| ADR-003 ^| 认知镜像协议 ^| ✅ Active ^|
    echo.
    echo ---
    echo.
    echo ## Technical Debt / 技术债务
    echo.
    echo - [ ] None recorded yet
    echo.
    echo ---
    echo.
    echo ## Design Audit Status / 设计审计状态
    echo.
    echo - **Status**: Not Started
    echo - **Last Audit**: N/A
    echo.
    echo ---
    echo.
    echo ## LastTask / 最近任务
    echo.
    echo ^| Field ^| Value ^|
    echo ^|-------^|-------^|
    echo ^| Task ^| Project Initialization ^|
    echo ^| Status ^| ✅ Completed ^|
    echo ^| Date ^| %iso_date% ^|
    echo.
    echo ---
    echo.
    echo ## Changelog / 变更日志
    echo.
    echo ## %iso_date%
    echo - chore: Project initialized in Progressive mode via setup script.
) > PROJECT_STATUS.md
echo [OK] PROJECT_STATUS.md created / PROJECT_STATUS.md 创建成功。
goto :eof

:end
echo.
echo ================================================================
echo [INFO] 脚本执行完毕。请查看上方输出了解具体执行的操作。
echo [INFO] Script finished. Review the output above for details.
echo ================================================================
echo.
echo 按任意键关闭窗口... / Press any key to close...
pause >nul
