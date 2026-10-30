#!/bin/sh
# 卸载 Lemo-Opuscar 技能：只删技能根目录里的软链接。
# 风格库（~/lemo-opuscar）、你自己存的风格（~/lemo-my-styles）和这个仓库都不动。
set -e

HERE=$(cd -P "$(dirname "$0")" && pwd -P)
SKILL=$HERE/skills/lemo-opuscar
AGENTS_HOME=${DSH_AGENTS_HOME:-$HOME/.agents}
TARGET=$AGENTS_HOME/skills/lemo-opuscar

if [ ! -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
  echo "· $TARGET 不存在，无需卸载"
  exit 0
fi

# 只删指向本仓库的链接，别误删别人的目录
if [ -L "$TARGET" ] && [ "$(cd -P "$TARGET" 2>/dev/null && pwd -P)" = "$SKILL" ]; then
  rm "$TARGET"
  echo "✓ 已移除 $TARGET"
else
  echo "✗ $TARGET 不是指向本仓库的软链接，未改动"
  exit 1
fi

echo "· 保留：技能库 ~/lemo-opuscar、你的风格 ~/lemo-my-styles、本仓库"
