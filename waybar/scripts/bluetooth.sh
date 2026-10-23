#!/usr/bin/env bash

action="${1:-show}"
state_file="$XDG_RUNTIME_DIR/waybar-bluetooth-view"

# 右键在设备名称与耳机电量之间切换
if [ "$action" = "toggle" ]; then
    view=$(cat "$state_file" 2>/dev/null)
    if [ "$view" = "battery" ]; then
        printf 'name\n' > "$state_file"
    else
        printf 'battery\n' > "$state_file"
    fi
    exit
fi

# 获取当前连接的蓝牙设备名称
connected=$(bluetoothctl devices Connected)

if [ -z "$connected" ]; then
    jq -cn --arg text '<span size="11520">󰂯</span>' --arg tooltip "未连接蓝牙设备" '{text: $text, tooltip: $tooltip}'
    exit
fi

names=$(printf '%s\n' "$connected" | sed 's/^Device [^ ]* //' | paste -sd ',' | sed 's/,/, /g')

# 读取已连接音频设备报告的电量
battery=""
while IFS= read -r device; do
    address=$(printf '%s\n' "$device" | awk '{print $2}')
    info=$(bluetoothctl info "$address")

    if printf '%s\n' "$info" | grep -q 'UUID: Audio Sink'; then
        battery=$(printf '%s\n' "$info" | sed -n 's/^[[:space:]]*Battery Percentage:.*(\([0-9]\+\))$/\1/p' | head -n 1)
    fi

    if [ -n "$battery" ]; then
        break
    fi
done <<< "$connected"

if [ -n "$battery" ]; then
    tooltip=$(printf '%s %s%%' "$names" "$battery")
    view=$(cat "$state_file" 2>/dev/null)

    if [ "$view" = "battery" ]; then
        jq -cn --arg text "<span size=\"11520\">󰂯</span>   $battery%" --arg tooltip "$tooltip" '{text: $text, tooltip: $tooltip}'
    else
        jq -cn --arg text "<span size=\"11520\">󰂯</span>   $names" --arg tooltip "$tooltip" '{text: $text, tooltip: $tooltip}'
    fi
    exit
fi

jq -cn --arg text "<span size=\"11520\">󰂯</span>   $names" --arg tooltip "$names" '{text: $text, tooltip: $tooltip}'
