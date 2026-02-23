#!/usr/bin/env bash
# JavaScript Lint - Bash Script
set -eo pipefail
PATH_TARGET="."
FIX_MODE=false
EXTENSIONS="js,jsx,ts,tsx"
ALLOW_PROTECTED=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --fix) FIX_MODE=true; shift ;;
        --allow-protected) ALLOW_PROTECTED=true; shift ;;
        *) PATH_TARGET="$1"; shift ;;
    esac
done

echo "🔍 JavaScript Lint - ESLint"
echo ""

command -v node &>/dev/null || { echo "❌ Node.js 未安装: https://nodejs.org"; exit 1; }
if ! command -v eslint &>/dev/null; then
    echo "⚠️  正在安装 ESLint..."
    npm install -g eslint || { echo "❌ 请手动安装: npm install -g eslint"; exit 1; }
fi

if [ ! -e "$PATH_TARGET" ]; then
    echo "❌ 路径不存在: $PATH_TARGET"
    exit 1
fi

IFS=',' read -r -a EXT_ARR <<< "$EXTENSIONS"
FILES=()

if [ -f "$PATH_TARGET" ]; then
    FILES+=("$PATH_TARGET")
else
    while IFS= read -r -d '' file; do
        FILES+=("$file")
    done < <(find "$PATH_TARGET" -type f -print0)
fi

FILTERED=()
for file in "${FILES[@]}"; do
    ext="${file##*.}"
    ext="${ext,,}"
    matched=false
    for want in "${EXT_ARR[@]}"; do
        [ "$ext" = "${want,,}" ] && matched=true && break
    done
    [ "$matched" = false ] && continue

    if [ "$ALLOW_PROTECTED" = false ]; then
        case "$file" in
            */.agents/*|*/bmad/*|*/README.md) continue ;;
        esac
    fi
    FILTERED+=("$file")
done

if [ "${#FILTERED[@]}" -eq 0 ]; then
    echo "ℹ️ 未找到可检查文件"
    exit 0
fi

ARGS=()
[ "$FIX_MODE" = true ] && ARGS+=(--fix)
ARGS+=("${FILTERED[@]}")
eslint "${ARGS[@]}"
exit $?
