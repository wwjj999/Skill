#!/bin/bash
# [AGENTS-MD] Protocol Reset Tool (ResetAG)
# Purpose: Unlock the project and force re-initialization WITHOUT deleting the framework.

echo "========================================================"
echo "  AGENTS-MD PROTOCOL RESET TOOL (v7.5 Refined)"
echo "========================================================"
echo ""
echo "[!] WARNING: This will reset project-specific configurations."
echo "    Core framework directories (bmad, .agents) are preserved."
echo ""

# 1. Remove governance and status markers
echo "[1/3] Clearing state markers..."
# PROJECT_STATUS.md and USER_PROFILE.md are mandatory. Reset to clean templates.
# PROJECT_STATUS.md is mandatory. Initialize with clean template.
cat <<EOF > PROJECT_STATUS.md
# PROJECT_STATUS.md

## Governance Mode / 治理模式
Progressive / 渐进式

## Project Skeleton / 项目骨架
(To be populated by AI on first run / 待 AI 首次运行时填充)

## Tech Stack / 技术栈
[]

## Architectural Decisions / 架构决策
[]

## Technical Debt / 技术债务
[]

## Design Audit Status / 设计审计状态
[]

## Last Task / 上次任务
[None / 无]
EOF
echo "[OK] Initialized PROJECT_STATUS.md (Template)"

# USER_PROFILE.md is mandatory. Initialize with clean template.
cat <<EOF > USER_PROFILE.md
# USER_PROFILE.md

## User Preferences / 用户偏好

- **Communication Language / 沟通语言**: [Select: Chinese / English]
- **Role / 角色**: [Select: Developer / Architect / CTO]

## Persona Handshake / 角色握手

(To be populated during onboarding / 待入职期间填充)
EOF
echo "[OK] Initialized USER_PROFILE.md (Template)"
if [ -f "sprint-status.yaml" ]; then
    rm "sprint-status.yaml"
    echo "[OK] Removed sprint-status.yaml"
fi
if [ -f ".ag_env_verified" ]; then
    rm ".ag_env_verified"
    echo "[OK] Invalidated environment verification"
fi

# ---------------------------------------------------------
# [NEW] Section: Context Factory Reset
# ---------------------------------------------------------
echo "[Reset] Cleaning up Context Memory..."

if [ -d "context" ]; then
    rm -rf "context"
    echo "[OK] Deleted existing context"
fi
mkdir "context"

# Restore context/memory.md (Core ADRs)
cat <<EOF > context/memory.md
# 决策记忆库 (TOC)

1. [ADR-001] 架构转型: 混合智能
2. [ADR-002] 安全审计: 禁用 Eval
3. [ADR-003] 语言协议: 认知镜像

## [ADR-001] 架构转型: 混合智能

- 决定: 采用 "Passive Context (Brain) + Active Skills (Hands)" 架构。
- 原因: Vercel 研究证明被动上下文对知识检索最有效，而 Skils 对执行具体动作（如 formatting）最稳定。

## [ADR-002] 安全审计: 禁用 Eval

- 决定: 全局禁用 shell 脚本中的 \`eval\`，改用数组扩展。
- 原因: 2026-02-05 安全审计发现潜在注入风险 (lint.sh)。

## [ADR-003] 语言协议: 认知镜像

- 决定: 实施 "Cognitive Mirroring Protocol"，强制 AI 用此匹配用户对话语言。
- 原因: 用户要求元认知工件 (Task/Plan) 必须本地化，以提升协作体验。
EOF
echo "[OK] Restored context/memory.md (Factory Default)"

# Restore context/status.md (Project Meta)
cat <<EOF > context/status.md
<project_meta>

- 当前阶段: Agents-MD Pro v7.5 Ultimate 维护与审计阶段。
- 核心架构: 被动上下文 (Passive Context) + 混合智能 (Hybrid Intelligence)。
- 技术栈: Python, PowerShell, Bash, Markdown (AgentsProtocols).
- 核心原则:
    1. 认知镜像协议 (Cognitive Mirroring Protocol): AI 输出语言必须匹配用户语言。
    2. 认知漏斗 (Cognitive Funnel): 强制引导所有 AI 读取 AGENTS.md。
</project_meta>
EOF
echo "[OK] Restored context/status.md (Factory Default)"

# ---------------------------------------------------------
# [INFO] .gemini directory contains project config (settings.json) and is preserved.
# ---------------------------------------------------------

# 2. Clear project-specific configurations
echo "[2/3] Resetting configurations..."
if [ -f "bmad/bmm/config.yaml" ]; then
    rm "bmad/bmm/config.yaml"
    echo "[OK] Reset BMAD BMM config"
fi
if [ -f "bmad/core/config.yaml" ]; then
    rm "bmad/core/config.yaml"
    echo "[OK] Reset BMAD Core config"
fi
if [ -d "_bmad-output" ]; then
    rm -rf "_bmad-output"
    echo "[OK] Cleaned up runtime output directory"
fi

# 3. Forced Context Logic
echo "[3/3] Forcing protocol re-indexing..."
if [ -f "AGENTS.md" ]; then
    touch "AGENTS.md"
    echo "[OK] Updated AGENTS.md timestamp"
fi

# 4. Distribution Mode (Optional)
echo ""
read -p "[?] Prepare for new distribution? (Reset CHANGELOG history) (y/N): " dist_mode
if [[ "$dist_mode" =~ ^[Yy]$ ]]; then
    echo "[4/4] Resetting CHANGELOG.md..."
    if [ -f "CHANGELOG.md" ]; then
        rm "CHANGELOG.md"
        echo "[OK] Deleted old CHANGELOG"
    fi
    cat <<EOF > CHANGELOG.md
# CHANGELOG

## \$(date +%Y-%m-%d)

- chore: 项目初始化 / Project initialized
EOF
    echo "[OK] Created fresh CHANGELOG.md (Bilingual Standard)"

    # Clean up AI specific temporary files (antigravity brain) but keep .gemini root
    if [ -d ".gemini/antigravity" ]; then
        rm -rf ".gemini/antigravity"
        echo "[OK] Cleaned up temporary AI memory (.gemini/antigravity)"
    fi
fi


echo ""
echo "========================================================"
echo "[SUCCESS] Project state reset."
echo ""
echo "[ACTION REQUIRED] Please copy and paste the following to the AI:"
echo ""
echo "Protocol Reset. Read AGENTS.md to re-initialize."
echo "========================================================"
echo ""
