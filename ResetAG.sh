#!/bin/bash
# [AGENTS-MD] Protocol Reset Tool (ResetAG)
# Purpose: Unlock the project and force re-initialization WITHOUT deleting the framework.

echo "========================================================"
echo "  AGENTS-MD PROTOCOL RESET TOOL (v8.0 Ultimate)"
echo "========================================================"
echo ""
echo "[!] WARNING: This will reset project-specific configurations. / 警告：此操作将重置项目特定配置。"
echo "    Core framework directories (bmad, .agents) are preserved. / 核心框架目录 (bmad, .agents) 将被保留。"
echo ""

# 1. Remove governance and status markers
echo "[1/3] Clearing state markers... / 正在清理状态标记..."
if [ -f "PROJECT_STATUS.md" ]; then
    rm "PROJECT_STATUS.md"
    echo "[OK] Removed PROJECT_STATUS.md / 已移除 PROJECT_STATUS.md"
fi
if [ -f "CODE_AUDIT_REPORT.md" ]; then
    rm "CODE_AUDIT_REPORT.md"
    echo "[OK] Removed CODE_AUDIT_REPORT.md / 已移除 CODE_AUDIT_REPORT.md"
fi
if [ -f "PROJECT_FILES_ANALYSIS.md" ]; then
    rm "PROJECT_FILES_ANALYSIS.md"
    echo "[OK] Removed PROJECT_FILES_ANALYSIS.md / 已移除 PROJECT_FILES_ANALYSIS.md"
fi
if [ -f "find_today_changes.py" ]; then
    rm "find_today_changes.py"
    echo "[OK] Removed find_today_changes.py / 已移除 find_today_changes.py"
fi
if [ -f "scan_project_files.py" ]; then
    rm "scan_project_files.py"
    echo "[OK] Removed scan_project_files.py / 已移除 scan_project_files.py"
fi
if [ -d ".trae/documents" ]; then
    rm -rf ".trae/documents"
    echo "[OK] Removed Trae analysis documents / 已移除 Trae 分析文档"
fi

if [ -f "sprint-status.yaml" ]; then
    rm "sprint-status.yaml"
    echo "[OK] Removed sprint-status.yaml / 已移除 sprint-status.yaml"
fi
if [ -f "USER_PROFILE.md" ]; then
    rm "USER_PROFILE.md"
    echo "[OK] Removed USER_PROFILE.md / 已移除 USER_PROFILE.md"
fi
if [ -f ".ag_env_verified" ]; then
    rm ".ag_env_verified"
    echo "[OK] Invalidated environment verification / 已使其环境验证失效"
fi
if [ -d ".git" ]; then
    echo ""
    echo "❗❗ [WARNING] CRITICAL WARNING / 严重警告"
    echo "   You are about to PERMANENTLY DELETE the .git directory and ALL Git history!"
    echo "   您即将永久删除 .git 目录及所有 Git 历史记录！"
    echo ""
    echo "   To proceed, type exactly: I-CONFIRM"
    echo "   请精确输入：我已明确确认"
    echo ""
    read -p "Round 1 / 第一轮: " confirm_git1
    if [ "$confirm_git1" != "I-CONFIRM" ] && [ "$confirm_git1" != "我已明确确认" ]; then
        echo "[ABORT] Input mismatch. Operation cancelled. / 输入不匹配，操作已取消。"
    else
        echo ""
        echo "❗❗ [WARNING] FINAL WARNING / 最终警告 - Last chance to abort!"
        echo "   Type exactly: I-CONFIRM to EXECUTE, anything else to CANCEL."
        echo "   输入 我已明确确认 执行，其余任何内容取消。"
        echo ""
        read -p "Round 2 / 第二轮: " confirm_git2
        if [ "$confirm_git2" != "I-CONFIRM" ] && [ "$confirm_git2" != "我已明确确认" ]; then
            echo "[ABORT] Second confirmation failed. Operation cancelled. / 第二轮确认失败，操作已取消。"
        else
            rm -rf ".git"
            echo "[OK] Removed .git directory (for clean distribution) / 已移除 .git 目录 (为干净分发准备)"
        fi
    fi
fi

# 2. Clear project-specific configurations
echo "[2/3] Resetting configurations... / 正在重置配置..."
if [ -f "bmad/bmm/config.yaml" ]; then
    rm "bmad/bmm/config.yaml"
    echo "[OK] Reset BMAD BMM config / 已重置 BMAD BMM 配置"
fi
if [ -f "bmad/core/config.yaml" ]; then
    rm "bmad/core/config.yaml"
    echo "[OK] Reset BMAD Core config / 已重置 BMAD Core 配置"
fi
if [ -d "_bmad-output" ]; then
    rm -rf "_bmad-output"
    echo "[OK] Cleaned up runtime output directory / 已清理运行输出目录"
fi

# 3. Forced Context Logic
echo "[3/3] Forcing protocol re-indexing... / 正在强制协议重新索引..."
if [ -f "AGENTS.md" ]; then
    touch "AGENTS.md"
    echo "[OK] Updated AGENTS.md timestamp / 已更新 AGENTS.md 时间戳"
fi

# 4. Distribution Mode (Optional)
echo ""
read -p "[?] Prepare for new distribution? (Reset CHANGELOG history) / 准备全新分发？(重置 CHANGELOG 历史记录) (y/N): " dist_mode
if [[ "$dist_mode" =~ ^[Yy]$ ]]; then
    echo "[4/4] Resetting CHANGELOG.md... / 正在重置 CHANGELOG.md..."
    if [ -f "CHANGELOG.md" ]; then
        rm "CHANGELOG.md"
        echo "[OK] Deleted old CHANGELOG / 已删除旧的 CHANGELOG"
    fi
    CURRENT_DATE=$(date +%Y-%m-%d)
    cat <<EOF > CHANGELOG.md
# CHANGELOG

## ${CURRENT_DATE}

- chore: Project initialized for distribution.
EOF
    echo "[OK] Created fresh CHANGELOG.md / 已创建新的 CHANGELOG.md"
fi


echo ""
echo "========================================================"
echo "[SUCCESS] Project state reset. / 项目状态已重置。"
echo ""
echo "[NEXT STEP] To re-initialize the project, run: / 下一步：重新初始化项目，请运行："
echo "    ./setup.sh"
echo ""
echo "Or manually edit PROJECT_STATUS.md to set your governance mode. / 或手动编辑 PROJECT_STATUS.md 来设置您的治理模式。"
echo ""
echo "[INFO] After initialization, you can start working with the AI. / 初始化完成后，您就可以开始使用 AI 工作了。"
echo "========================================================"
echo ""
echo "[INFO] 脚本执行完毕。请查看上方输出了解具体执行的操作。"
echo "[INFO] Script finished. Review the output above for details."
echo ""
echo "按任意键关闭... / Press any key to close..."
read -n 1 -s
