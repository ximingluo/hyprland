#!/bin/bash
# 智能 GPU 信息脚本 - 修复版

CACHE_FILE="/tmp/waybar-gpu-cache"
STATE_FILE="/tmp/waybar-gpu-state"
CACHE_AGE=2

# 获取当前显示状态
get_state() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "0" > "$STATE_FILE"
        echo "0"
    fi
}

# 切换状态
toggle_state() {
    current_state=$(get_state)
    if [ "$current_state" = "0" ]; then
        echo "1" > "$STATE_FILE"
    else
        echo "0" > "$STATE_FILE"
    fi
}

# 直接获取并解析 GPU 信息
get_parsed_gpu_info() {
    # 读取 nvtop 快照中的 NVIDIA 统计
    gpu_info=$(nvtop -s | jq -r '.[] | select(.device_name | startswith("NVIDIA")) | [.gpu_util, .mem_util, .mem_used, .temp, .power_draw] | @tsv')
    IFS=$'\t' read -r usage mem_percentage mem_used temp power <<< "$gpu_info"

    usage=${usage%%%}
    mem_percentage=${mem_percentage%%%}
    temp=${temp%C}
    power=${power%W}
    mem_gb=$(awk -v bytes="$mem_used" 'BEGIN {printf "%.1f", bytes / 1073741824}')

    echo "$usage $mem_percentage $mem_gb $temp $power"
}

# 处理参数
case "$1" in
    "toggle")
        toggle_state
        state=$(get_state)
        read usage mem_percent mem_gb temp power <<< $(get_parsed_gpu_info)
        
        if [ "$state" = "1" ]; then
            echo "{\"text\": \"* ${usage}%  ${mem_gb}G\", \"tooltip\": \"GPU 详细信息:\\n使用率: ${usage}%\\n显存: ${mem_percent}% (${mem_gb}G)\\n温度: ${temp}℃\\n功率: ${power}W\"}"
        else
            echo "{\"text\": \"* ${usage}%  ${mem_percent}%\", \"tooltip\": \"GPU 详细信息:\\n使用率: ${usage}%\\n显存: ${mem_percent}% (${mem_gb}G)\\n温度: ${temp}℃\\n功率: ${power}W\"}"
        fi
        ;;
    *)
        state=$(get_state)
        read usage mem_percent mem_gb temp power <<< $(get_parsed_gpu_info)
        
        if [ "$state" = "1" ]; then
            echo "{\"text\": \"* ${usage}%  ${mem_gb}G\", \"tooltip\": \"GPU 详细信息:\\n使用率: ${usage}%\\n显存: ${mem_percent}% (${mem_gb}G)\\n温度: ${temp}℃\\n功率: ${power}W\"}"
        else
            echo "{\"text\": \"* ${usage}%  ${mem_percent}%\", \"tooltip\": \"GPU 详细信息:\\n使用率: ${usage}%\\n显存: ${mem_percent}% (${mem_gb}G)\\n温度: ${temp}℃\\n功率: ${power}W\"}"
        fi
        ;;
esac
