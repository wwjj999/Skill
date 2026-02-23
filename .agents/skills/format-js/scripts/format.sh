#!/usr/bin/env bash
# JavaScript Format - Bash Script
set -eo pipefail
PATH_TARGET="."
CHECK_MODE=false
EXTENSIONS="js,jsx,ts,tsx,json,css,md"
ALLOW_PROTECTED=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --check) CHECK_MODE=true; shift ;;
        --allow-protected) ALLOW_PROTECTED=true; shift ;;
        *) PATH_TARGET="$1"; shift ;;
    esac
done

echo "🎨 JavaScript Format - Prettier"
echo ""

command -v node &>/dev/null || { echo "❌ Node.js 未安装: https://nodejs.org"; exit 1; }
if ! command -v prettier &>/dev/null; then
    echo "⚠️  正在安装 Prettier..."
    npm install -g prettier || { echo "❌ 请手动安装: npm install -g prettier"; exit 1; }
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
    echo "ℹ️ 未找到可格式化文件"
    exit 0
fi

if [ "$CHECK_MODE" = true ]; then
    prettier --check "${FILTERED[@]}"
else
    prettier --write "${FILTERED[@]}"
fi
exit $?
