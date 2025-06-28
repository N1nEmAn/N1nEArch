#!/bin/bash

# 定义用于隐藏窗口的暂存桌面名称或索引
# 确保这个桌面在你的bspwmrc中已经定义且不常用。
# 例如，你可以在 bspwmrc 中添加：bspc monitor <你的显示器名称> -d 1 2 3 4 5 6 7 8 9 99
# 或者如果你有多个显示器，为其中一个定义一个额外的桌面：bspc monitor <你的显示器名称> -d 1 2 3 4 5 scratchpad
# 这里的 "99" 或 "scratchpad" 就是你的暂存桌面名称。
SCRATCHPAD_DESKTOP="99" # 建议使用一个不常用的数字或名称

# 获取暂存桌面上的所有窗口的 ID 和标题
# 注意：现在我们查询的是特定桌面上的窗口，而不是所有隐藏状态的窗口
hidden_windows_raw=$(bspc query -N -d "$SCRATCHPAD_DESKTOP" -n .window)
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

# 如果没有暂存窗口（或所有窗口都没有标题），则退出
if [ "$hidden_count" -eq 0 ]; then
  exit 0
fi

# 如果只有一个暂存窗口，则直接唤起它
if [ "$hidden_count" -eq 1 ]; then
  # 提取窗口 ID 和标题
  selected_id=$(echo "$hidden_windows" | cut -d ':' -f 1)
  selected_title=$(echo "$hidden_windows" | cut -d ':' -f 2)

  # 将窗口移动到当前聚焦的桌面并聚焦
  bspc node "$selected_id" -d focused
  bspc node "$selected_id" -f
  exit 0
fi

# 如果有多个暂存窗口，使用 rofi 或 dmenu 显示列表并让用户选择
# 修改：rofi只显示标题部分，不显示ID，并增加“唤起所有窗口”选项
display_options=$(echo -e "$hidden_windows" | cut -d ':' -f 2)
display_options_with_all="唤起所有窗口 (All Hidden Windows)\n$display_options" # 添加唤起所有窗口的选项

selected_window_info=$(echo -e "$display_options_with_all" | rofi -dmenu -p "选择要唤起的窗口:") # 或者使用 dmenu

if [ -n "$selected_window_info" ]; then
  if [ "$selected_window_info" = "唤起所有窗口 (All Hidden Windows)" ]; then
    # --- 唤起所有窗口并重试直到全部唤醒 ---
    max_retries=5   # 最大重试次数
    retry_delay=0.1 # 每次重试前的延迟秒数

    for ((i = 1; i <= max_retries; i++)); do
      # 再次查询当前暂存桌面上的所有窗口
      current_scratchpad_ids=$(bspc query -N -d "$SCRATCHPAD_DESKTOP" -n .window)

      # 如果暂存桌面已经没有窗口了，就退出循环
      if [ -z "$current_scratchpad_ids" ]; then
        break
      fi

      # 遍历当前仍然在暂存桌面上的窗口，尝试将它们移动到当前聚焦的桌面
      echo "$current_scratchpad_ids" | while read -r id; do
        bspc node "$id" -d focused
      done

      # 如果不是最后一次重试，就稍作等待
      if [ "$i" -lt "$max_retries" ]; then
        sleep "$retry_delay"
      fi
    done
    # --- 唤起所有窗口并重试直到全部唤醒结束 ---

  else
    # 根据选中的标题找到对应的ID
    # 注意：如果多个窗口有相同的标题，这里可能需要更复杂的逻辑来区分
    selected_id=$(echo -e "$hidden_windows" | grep -m 1 ":$selected_window_info$" | cut -d ':' -f 1)

    if [ -n "$selected_id" ]; then
      # 唤起选中的窗口并聚焦
      bspc node "$selected_id" -d focused
      bspc node "$selected_id" -f
    fi
  fi
fi
