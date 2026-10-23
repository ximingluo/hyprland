#!/usr/bin/env bash

# 读取当前系统名称和安装包数量
data=$(fastfetch --structure OS:Packages --format json)
os=$(jq -r '.[] | select(.type == "OS") | .result.prettyName' <<< "$data")
packages=$(jq -r '.[] | select(.type == "Packages") | .result | to_entries | map(select(.key != "all")) | map("\(.key): \(.value)") | join(", ")' <<< "$data")

# 输出 Waybar 图标和悬停信息
printf '{"text":" 󰣇","tooltip":"%s\\n%s"}\n' "$os" "$packages"
