#!/bin/bash

# 获取所有隐藏窗口的 ID 和标题
# 修改：只获取标题，不获取ID，避免在rofi中显示十六进制ID
# 同时，如果WM_NAME为空，则直接跳过该窗口
hidden_windows_raw=$(bspc query -N -n .hidden)
hidden_windows=""
hidden_count=0

if [ -n "$hidden_windows_raw" ]; then
  while read -r id; do
    title=$(xprop -id "$id" WM_NAME | awk -F '=' '{print $2}' | tr -d '"')
    # 如果标题为空，则跳过此窗口
    if [ -z "$title" ]; then
      continue # 跳过当前循环的剩余部分，处理下一个 ID
    fi
    hidden_windows+="$id:$title\n" # 内部仍然保留ID和标题的映射
    ((hidden_count++))
  done <<<"$hidden_windows_raw"
fi

# 如果没有隐藏窗口（或所有窗口都没有标题），则退出
if [ "$hidden_count" -eq 0 ]; then
  exit 0
fi

# 如果只有一个隐藏窗口，则直接唤起它
if [ "$hidden_count" -eq 1 ]; then
  # 提取窗口 ID 和标题
  selected_id=$(echo "$hidden_windows" | cut -d ':' -f 1)
  selected_title=$(echo "$hidden_windows" | cut -d ':' -f 2)

  bspc node "$selected_id" -g hidden=off
  bspc node "$selected_id" -f
  exit 0
fi

# 如果有多个隐藏窗口，使用 rofi 或 dmenu 显示列表并让用户选择
# 修改：rofi只显示标题部分，不显示ID，并增加“唤起所有窗口”选项
display_options=$(echo -e "$hidden_windows" | cut -d ':' -f 2)
display_options_with_all="唤起所有窗口 (All Hidden Windows)\n$display_options" # 添加唤起所有窗口的选项

selected_window_info=$(echo -e "$display_options_with_all" | rofi -dmenu -p "选择要唤起的窗口:") # 或者使用 dmenu

if [ -n "$selected_window_info" ]; then
  if [ "$selected_window_info" = "唤起所有窗口 (All Hidden Windows)" ]; then
    # 使用 xargs 一次性唤起所有隐藏窗口，更可靠
    # bspc query -N -n .hidden 会输出所有隐藏窗口的ID，每行一个
    # xargs -I {} 将每一行ID作为参数传递给 bspc node {} -g hidden=off
    bspc query -N -n .hidden | xargs -I {} bspc node {} -g hidden=off
  else
    # 根据选中的标题找到对应的ID
    # 注意：如果多个窗口有相同的标题，这里可能需要更复杂的逻辑来区分
    selected_id=$(echo -e "$hidden_windows" | grep -m 1 ":$selected_window_info$" | cut -d ':' -f 1)

    if [ -n "$selected_id" ]; then
      # 唤起选中的窗口并聚焦
      bspc node "$selected_id" -g hidden=off
      bspc node "$selected_id" -f
    fi
  fi
fi
