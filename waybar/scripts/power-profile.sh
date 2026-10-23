#!/usr/bin/env bash

action="${1:-show}"
profile="$(powerprofilesctl get)"

# 左键在安静与性能模式之间切换
if [[ "$action" == "toggle" ]]; then
  if [[ "$profile" == "performance" ]]; then
    powerprofilesctl set power-saver
  else
    powerprofilesctl set performance
  fi
  exit
fi

# 右键直接切换到平衡模式
if [[ "$action" == "balanced" ]]; then
  powerprofilesctl set balanced
  exit
fi

# 输出当前模式对应的图标、颜色类和操作说明
if [[ "$profile" == "power-saver" ]]; then
  echo '{"text":"󰌪","class":"quiet","tooltip":"安静模式\n左键：切换到性能模式\n右键：切换到平衡模式"}'
elif [[ "$profile" == "balanced" ]]; then
  echo '{"text":"󰾅","class":"balanced","tooltip":"平衡模式\n左键：切换到性能模式\n右键：保持平衡模式"}'
else
  echo '{"text":"󰓅","class":"performance","tooltip":"性能模式\n左键：切换到安静模式\n右键：切换到平衡模式"}'
fi
