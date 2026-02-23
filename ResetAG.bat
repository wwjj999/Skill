@echo off
chcp 65001 >nul
:: [AGENTS-MD] Protocol Reset Tool (ResetAG)
:: Purpose: Unlock the project and force re-initialization WITHOUT deleting the framework.

echo ========================================================
echo   AGENTS-MD PROTOCOL RESET TOOL (v8.0 Ultimate)
echo ========================================================
echo.
echo [!] WARNING: This will reset project-specific configurations. / 警告：此操作将重置项目特定配置。
echo     Core framework directories (bmad, .agents) are preserved. / 核心框架目录 (bmad, .agents) 将被保留。
echo.

:: 1. Remove governance and status markers
echo [1/3] Clearing state markers... / 正在清理状态标记...
if exist PROJECT_STATUS.md (
    del /f /q PROJECT_STATUS.md
    echo [OK] Removed PROJECT_STATUS.md / 已移除 PROJECT_STATUS.md
)
if exist CODE_AUDIT_REPORT.md (
    del /f /q CODE_AUDIT_REPORT.md
    echo [OK] Removed CODE_AUDIT_REPORT.md / 已移除 CODE_AUDIT_REPORT.md
)
if exist PROJECT_FILES_ANALYSIS.md (
    del /f /q PROJECT_FILES_ANALYSIS.md
    echo [OK] Removed PROJECT_FILES_ANALYSIS.md / 已移除 PROJECT_FILES_ANALYSIS.md
)
if exist find_today_changes.py (
    del /f /q find_today_changes.py
    echo [OK] Removed find_today_changes.py / 已移除 find_today_changes.py
)
if exist scan_project_files.py (
    del /f /q scan_project_files.py
    echo [OK] Removed scan_project_files.py / 已移除 scan_project_files.py
)
if exist .trae\documents (
    rmdir /s /q .trae\documents
    echo [OK] Removed Trae analysis documents / 已移除 Trae 分析文档
)

if exist sprint-status.yaml (
    del /f /q sprint-status.yaml
    echo [OK] Removed sprint-status.yaml / 已移除 sprint-status.yaml
)
if exist USER_PROFILE.md (
    del /f /q USER_PROFILE.md
    echo [OK] Removed USER_PROFILE.md / 已移除 USER_PROFILE.md
)
if exist .ag_env_verified (
    del /f /q /a .ag_env_verified
    echo [OK] Invalidated environment verification / 已使其环境验证失效
)
if not exist .git goto :after_git_check

echo.
echo [WARNING] ❗❗ CRITICAL WARNING ^/ 严重警告
echo    You are about to PERMANENTLY DELETE the .git directory and ALL Git history!
echo    您即将永久删除 .git 目录及所有 Git 历史记录！
echo.
echo    To proceed, type exactly: I-CONFIRM
echo    请精确输入：我已明确确认
echo.
set /p confirm_git1="Round 1 / 第一轮: "
if /i not "%confirm_git1%"=="I-CONFIRM" if /i not "%confirm_git1%"=="我已明确确认" (
    echo [ABORT] Input mismatch. Operation cancelled. ^/ 输入不匹配，操作已取消。
    goto :skip_git
)
echo.
echo [WARNING] ❗❗ FINAL WARNING ^/ 最终警告 - Last chance to abort!
echo    Type exactly: I-CONFIRM  to EXECUTE, anything else to CANCEL.
echo    输入 我已明确确认 执行，其余任何内容取消。
echo.
set /p confirm_git2="Round 2 / 第二轮: "
if /i not "%confirm_git2%"=="I-CONFIRM" if /i not "%confirm_git2%"=="我已明确确认" (
    echo [ABORT] Second confirmation failed. Operation cancelled. ^/ 第二轮确认失败，操作已取消。
    goto :skip_git
)
rmdir /s /q .git
echo [OK] Removed .git directory (for clean distribution) ^/ 已移除 .git 目录 (为干净分发准备)
goto :after_git_check

:skip_git
echo [SKIP] .git directory preserved. ^/ .git 目录已保留。

:after_git_check

REM 2. Clear project-specific configurations
echo [2/3] Resetting configurations... ^/ 正在重置配置...
if exist bmad\bmm\config.yaml (
    del /f /q bmad\bmm\config.yaml
    echo [OK] Reset BMAD BMM config / 已重置 BMAD BMM 配置
)
if exist bmad\core\config.yaml (
    del /f /q bmad\core\config.yaml
    echo [OK] Reset BMAD Core config / 已重置 BMAD Core 配置
)
if exist _bmad-output (
    rmdir /s /q _bmad-output
    echo [OK] Cleaned up runtime output directory / 已清理运行输出目录
)

:: 3. Forced Context Logic
echo [3/3] Forcing protocol re-indexing... / 正在强制协议重新索引...
if exist AGENTS.md (
    copy /b AGENTS.md +,, >nul
    echo [OK] Updated AGENTS.md timestamp / 已更新 AGENTS.md 时间戳
)

:: 4. Distribution Mode (Optional)
echo.
set /p dist_mode="[?] Prepare for new distribution? (Reset CHANGELOG history) / 准备全新分发？(重置 CHANGELOG 历史记录) (y/N): "
if /i "%dist_mode%"=="y" (
    echo [4/4] Resetting CHANGELOG.md... / 正在重置 CHANGELOG.md...
    if exist CHANGELOG.md (
        del /f /q CHANGELOG.md
        echo [OK] Deleted old CHANGELOG / 已删除旧的 CHANGELOG
    )
    for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set "iso_date=%%i"
    (
        echo # CHANGELOG
        echo.
        echo ## %iso_date%
        echo.
        echo - chore: Project initialized for distribution.
    ) > CHANGELOG.md
    echo [OK] Created fresh CHANGELOG.md / 已创建新的 CHANGELOG.md
)


echo.
echo ========================================================
echo [SUCCESS] Project state reset. / 项目状态已重置。
echo.
echo [NEXT STEP] To re-initialize the project, run: / 下一步：重新初始化项目，请运行：
echo     setup.bat
echo.
echo Or manually edit PROJECT_STATUS.md to set your governance mode. / 或手动编辑 PROJECT_STATUS.md 来设置您的治理模式。
echo.
echo [INFO] After initialization, you can start working with the AI. / 初始化完成后，您就可以开始使用 AI 工作了。
echo ========================================================
echo.
echo [INFO] 脚本执行完毕。请查看上方输出了解具体执行的操作。
echo [INFO] Script finished. Review the output above for details.
echo.
echo 按任意键关闭窗口... / Press any key to close...
pause >nul
