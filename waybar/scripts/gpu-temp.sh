#!/bin/bash

# 读取 CPU、GPU 和主板温度
cpu_temp=$(cat /sys/class/thermal/thermal_zone7/temp)
cpu_temp=$((cpu_temp / 1000))
gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n 1)
board_temp=$(cat /sys/class/thermal/thermal_zone0/temp)
board_temp=$((board_temp / 1000))

if [[ "$gpu_temp" =~ ^[0-9]+$ ]]; then
    printf '{"text":" %s°C","tooltip":"CPU: %s°C\\nGPU: %s°C\\n主板: %s°C"}\n' "$board_temp" "$cpu_temp" "$gpu_temp" "$board_temp"
else
    printf '{"text":" %s°C","tooltip":"CPU: %s°C\\nGPU: N/A\\n主板: %s°C"}\n' "$board_temp" "$cpu_temp" "$board_temp"
fi
