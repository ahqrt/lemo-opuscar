#!/bin/sh
# 给 DeepSeek Harness 安装 Lemo-Opuscar 技能：在技能根目录建一个软链接。
#   sh install.sh           安装（或更新）软链接
#   sh install.sh --force   目标位置已有真实目录时，先备份再替换
#
# 技能根目录 = $DSH_AGENTS_HOME/skills，默认 ~/.agents/skills。
# 链接到仓库里的技能目录，所以 `git pull` 之后不用重装。
set -e

HERE=$(cd -P "$(dirname "$0")" && pwd -P)
SKILL=$HERE/skills/lemo-opuscar
AGENTS_HOME=${DSH_AGENTS_HOME:-$HOME/.agents}
ROOT=$AGENTS_HOME/skills
TARGET=$ROOT/lemo-opuscar

[ -f "$SKILL/SKILL.md" ] || { echo "✗ 找不到 $SKILL/SKILL.md，请在仓库内运行本脚本"; exit 1; }

# 装之前先自检 frontmatter：name 必须匹配 ^[a-z0-9]+(-[a-z0-9]+)*$，且 name/description 都在
name=$(sed -n 's/^name:[[:space:]]*//p' "$SKILL/SKILL.md" | head -1 | tr -d '"'"'"'')
desc=$(sed -n 's/^description:[[:space:]]*//p' "$SKILL/SKILL.md" | head -1)
case "$name" in
  lemo-opuscar) ;;
  *) echo "✗ SKILL.md 的 name 是 \"$name\"，应为 lemo-opuscar"; exit 1 ;;
esac
[ -n "$desc" ] || { echo "✗ SKILL.md 缺少 description"; exit 1; }

mkdir -p "$ROOT"

if [ -L "$TARGET" ]; then
  ln -sfn "$SKILL" "$TARGET"
  echo "✓ 已更新软链接"
elif [ -e "$TARGET" ]; then
  if [ "$1" = "--force" ]; then
    BACKUP=$TARGET.backup.$(date +%Y%m%d%H%M%S)
    mv "$TARGET" "$BACKUP"
    ln -s "$SKILL" "$TARGET"
    echo "✓ 旧目录已备份到 $BACKUP"
  else
    echo "✗ $TARGET 已存在，且不是软链接。"
    echo "  确认那是旧副本后，用 sh install.sh --force 覆盖（会先备份）。"
    exit 1
  fi
else
  ln -s "$SKILL" "$TARGET"
  echo "✓ 已安装"
fi

echo "  $TARGET → $(cd -P "$TARGET" && pwd -P)"
echo
echo "下一步："
echo "  1. 重开一个 Harness 会话（技能目录会重新扫描）"
echo "  2. 直接说：做一支 45 秒的水彩风格短片，讲……"
echo "     第一次用会自动把风格库装到 ~/lemo-opuscar，并装核心依赖"
echo
echo "卸载：sh $HERE/uninstall.sh    （只删软链接，风格库和你自己存的风格都保留）"
