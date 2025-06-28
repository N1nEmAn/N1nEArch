#!/bin/bash

# 获取所有隐藏窗口的 ID 和标题
hidden_windows=$(bspc query -N -n .hidden | while read -r id; do
  title=$(xprop -id "$id" WM_NAME | awk -F '=' '{print $2}' | tr -d '"')
  echo "$id:$title"
done)

# 计算隐藏窗口的数量
hidden_count=$(echo "$hidden_windows" | wc -l)
# 移除可能存在的空行导致计数不准
if [ -z "$hidden_windows" ]; then
  hidden_count=0
fi

# 如果没有隐藏窗口，则退出
if [ "$hidden_count" -eq 0 ]; then
  dunstify -u low -i ~/.config/bspwm/assets/info.svg 'No Hidden Windows' '没有隐藏的窗口.'
  exit 0
fi

# 如果只有一个隐藏窗口，则直接唤起它
if [ "$hidden_count" -eq 1 ]; then
  selected_id=$(echo "$hidden_windows" | cut -d ':' -f 1)
  bspc node "$selected_id" -g hidden=off
  bspc node "$selected_id" -f
  exit 0
fi

# 如果有多个隐藏窗口，使用 rofi 或 dmenu 显示列表并让用户选择
selected_window_info=$(echo "$hidden_windows" | rofi -dmenu -p "选择要唤起的窗口:") # 或者使用 dmenu

if [ -n "$selected_window_info" ]; then
  # 提取窗口 ID
  selected_id=$(echo "$selected_window_info" | cut -d ':' -f 1)
  # 唤起选中的窗口并聚焦
  bspc node "$selected_id" -g hidden=off
  bspc node "$selected_id" -f
fi
