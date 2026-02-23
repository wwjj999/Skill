#!/bin/bash

# Ensure we run from the project root (where this script lives)
cd "$(dirname "$0")"

echo "[AGENTS-MD] Bootstrapping Environment... / 正在引导环境..."

# Check for Node.js
if ! command -v node &> /dev/null && ! command -v nodejs &> /dev/null; then
    echo "[WARNING] Node.js not found. BMad-Method will run in degraded mode. / 未找到 Node.js，BMad-Method 将以降级模式运行。"
    echo "          Install Node.js v20+ for full functionality. / 请安装 Node.js v20+ 以获取完整功能。"
fi

# ============================================================
#  Python Environment Auto-Detection / Python 环境自动检测
# ============================================================
echo ""
echo "=== Python Environment Check / Python 环境检测 ==="

# --- Level 1: Python availability / 第 1 级：Python 可用性 ---
PYTHON_CMD=""
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
fi

if [ -z "$PYTHON_CMD" ]; then
    echo "  [WARNING] Python not found! Some features will be unavailable."
    echo "           未找到 Python！部分功能将不可用。"
    echo "           Please install Python 3.8+ from https://python.org"
    echo "           请从 https://python.org 安装 Python 3.8+"
    SKIP_PYTHON=true
else
    py_ver=$($PYTHON_CMD --version 2>&1)
    echo "  [OK] $py_ver detected / 已检测到"
    SKIP_PYTHON=false
fi

# --- Level 2: Core dependencies check / 第 2 级：核心依赖逐包检测 ---
if [ "$SKIP_PYTHON" = false ]; then
    PIP_CMD="$PYTHON_CMD -m pip"

    # Check psutil
    if $PYTHON_CMD -c "import psutil" &> /dev/null; then
        echo "  [OK] psutil already installed / 已安装"
    else
        echo "  [..] psutil not found, installing... / 未找到，正在安装..."
        if $PIP_CMD install psutil --quiet &> /dev/null; then
            echo "  [OK] psutil installed successfully / 安装成功"
        else
            echo "  [FAIL] psutil install failed. Run manually: pip install psutil"
            echo "        安装失败，请手动运行: pip install psutil"
        fi
    fi

    # Check PyYAML
    if $PYTHON_CMD -c "import yaml" &> /dev/null; then
        echo "  [OK] PyYAML already installed / 已安装"
    else
        echo "  [..] PyYAML not found, installing... / 未找到，正在安装..."
        if $PIP_CMD install PyYAML --quiet &> /dev/null; then
            echo "  [OK] PyYAML installed successfully / 安装成功"
        else
            echo "  [FAIL] PyYAML install failed. Run manually: pip install PyYAML"
            echo "        安装失败，请手动运行: pip install PyYAML"
        fi
    fi

    # --- Level 3: Optional dependencies hint / 第 3 级：可选依赖提示 ---
    if $PYTHON_CMD -c "from plyer import notification" &> /dev/null; then
        echo "  [OK] plyer installed (desktop notifications enabled) / 已安装（桌面通知已启用）"
    else
        echo "  [INFO] plyer not installed (optional: desktop notifications)"
        echo "        可选依赖未安装（桌面通知），如需安装: $PYTHON_CMD -m pip install plyer"
    fi
fi

echo "=== Environment Check Complete / 环境检测完成 ==="
echo ""



touch .ag_env_verified

# Function to create PROJECT_STATUS.md (must be defined before use)
create_status() {
    local current_date=$(date +%Y-%m-%d)
    local project_name=$(basename "$PWD")
    
    cat <<EOF > PROJECT_STATUS.md
# PROJECT_STATUS.md

## Schema: Project Status

- document_type: project_status_tracking
- governance_mode: Progressive
- target_audience: ai_agents
- enforcement_level: mandatory
- last_updated: $current_date
- compatible_with: Agents-MD Pro v8.0

---

## Governance Mode / 治理模式

**Mode**: Progressive ✅

**Description**: 
Keep old files, write new code via protocol. / 保留旧文件，新代码遵循协议规范。

---

## Project Skeleton / 项目结构

\`\`\`
$project_name/
├── .agents/             # Protocol Land (Immutable Core Rules)
├── scripts/             # Core Utilities & Configuration
├── bmad/             # BMAD Method workflows
├── context/          # Memory and status
├── docs/                # Documentation
├── AGENTS_INDEX.yaml    # Knowledge Index
├── *.md                 # Master boot and AI adapters
├── *.py              # Utility scripts
└── setup.bat/sh      # Environment setup
\`\`\`

---

## Tech Stack / 技术栈

- **Languages**: Python (utility scripts)
- **Protocols**: Agents-MD Pro v8.0, BMAD Method
- **Supported Languages**: zh-CN, en

---

## Architectural Decisions / 架构决策

| ADR | Title | Status |
|-----|-------|--------|
| ADR-001 | 混合智能架构 | ✅ Active |
| ADR-002 | 禁用 Eval | ✅ Active |
| ADR-003 | 认知镜像协议 | ✅ Active |

---

## Technical Debt / 技术债务

- [ ] None recorded yet

---

## Design Audit Status / 设计审计状态

- **Status**: Not Started
- **Last Audit**: N/A

---

## LastTask / 最近任务

| Field | Value |
|-------|-------|
| Task | Project Initialization |
| Status | ✅ Completed |
| Date | $current_date |

---

## Changelog / 变更日志

## $current_date
- chore: Project initialized in Progressive mode via setup script.
EOF
    
    echo "[OK] PROJECT_STATUS.md created / PROJECT_STATUS.md 创建成功。"
}

# Check for PROJECT_STATUS.md
if [ ! -f "PROJECT_STATUS.md" ]; then
    echo ""
    echo "========================================================"
    echo "[AGENTS-MD] First-time setup detected. / 检测到首次初始化。"
    echo "========================================================"
    echo ""
    echo "[AGENTS-MD] Creating PROJECT_STATUS.md with Progressive mode... / 正在使用 Progressive 模式创建 PROJECT_STATUS.md..."
    create_status
    echo ""
fi

echo "[AGENTS-MD] Setup Complete. Agent Environment is ready for Passive Context. / 初始化完成。Agent 环境已准备就绪。"
echo ""
echo "================================================================"
echo "[INFO] 脚本执行完毕。请查看上方输出了解具体执行的操作。"
echo "[INFO] Script finished. Review the output above for details."
echo "================================================================"
echo ""
echo "按任意键关闭... / Press any key to close..."
read -n 1 -s
