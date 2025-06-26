#!/bin/bash
# --- 配置区 ---
# 软件包列表文件，现在直接在当前目录查找
PACKAGE_LIST_FILE="installed_packages.txt"
# 请注意：`sudo sh ./install_gtk_themes.sh` 这一行被放置在了函数定义之前和配置区之后，
# 这意味着它会在脚本启动时，在任何提示或检查之前立即执行。
# 如果你希望它在某些检查（比如软件包安装）之后，或者用户确认之后再执行，
# 你可能需要把它移动到脚本的相应位置。
sudo sh ./install_gtk_themes.sh

# --- 函数定义 ---

# 打印主要信息（Pacman 风格）
print_pacman_info() {
  echo -e "\e[1;36m::\e[0m $1"
}

# 打印操作信息（Pacman 风格）
print_pacman_action() {
  echo -e "\e[1;34m->\e[0m $1"
}

# 打印警告
print_warn() {
  echo -e "\e[1;33m==>\e[0m \e[33mWARN:\e[0m $1"
}

# 打印错误并退出
print_error() {
  echo -e "\e[1;31m==>\e[0m \e[31mERROR:\e[0m $1"
  exit 1
}

# 询问用户是否继续
ask_yes_no() {
  while true; do
    read -p "$1 (y/n): " yn
    case $yn in
    [Yy]*) return 0 ;;
    [Nn]*) return 1 ;;
    *) echo "请输入 y 或 n。" ;;
    esac
  done
}

# --- 脚本开始 ---

print_pacman_info "欢迎使用智能 Arch Linux dotfiles 恢复脚本"
print_pacman_info "此脚本将帮助您检查并安装缺失的软件包，然后选择性地恢复当前目录下的配置文件。"

echo " "
print_pacman_info "当前目录内容如下，这些文件将被视为您的配置源："
ls -F --color=always
echo " "

if ! ask_yes_no "是否要继续使用当前目录下的文件进行恢复？"; then
  print_pacman_info "用户取消，脚本退出。"
  exit 0
fi

echo " "
print_pacman_info "--- 软件包检查与安装 ---"

# 检查软件包列表文件是否存在于当前目录
if [ ! -f "$PACKAGE_LIST_FILE" ]; then
  print_warn "当前目录未找到软件包列表文件 '${PACKAGE_LIST_FILE}'。将跳过软件包安装步骤。"
  print_warn "您可能需要手动安装所有依赖的软件包。"
else
  print_pacman_action "正在检查缺失的软件包..."
  MISSING_PACKAGES=()
  while IFS= read -r pkg_with_version; do
    # 提取纯包名，移除版本号
    pkg_name=$(echo "$pkg_with_version" | awk '{print $1}')

    if ! pacman -Q "$pkg_name" &>/dev/null; then
      MISSING_PACKAGES+=("$pkg_name") # 只将包名添加到缺失列表
    fi
  done <"$PACKAGE_LIST_FILE"

  if [ ${#MISSING_PACKAGES[@]} -eq 0 ]; then
    print_pacman_info "所有必需的软件包均已安装。"
  else
    echo "以下软件包缺失，建议安装以确保配置正常工作："
    printf "  -> %s\n" "${MISSING_PACKAGES[@]}"
    echo " "

    if ask_yes_no "是否现在使用 yay 安装这些缺失的软件包？(需要 sudo 权限)"; then
      print_pacman_action "正在安装缺失的软件包，这可能需要一些时间..."
      # 使用 yay 的 --needed 选项避免重新安装已存在的包
      # yay -S --needed 会从标准输入读取包列表
      printf "%s\n" "${MISSING_PACKAGES[@]}" | yay -S --needed - || print_error "软件包安装失败！请检查网络连接或权限。"
      print_pacman_info "缺失软件包安装完成。"
    else
      print_warn "您选择不安装缺失的软件包。某些配置可能无法正常工作。"
    fi # <--- 这里是修复的地方，将 Hfi 改为 fi
  fi
fi

echo " "
print_pacman_info "--- 配置文件恢复 ---"
print_pacman_info "现在将逐个询问您是否恢复各个配置模块..."
echo " "

# --- 复制配置文件（交互式） ---
# 遍历当前目录中的所有项目
# 排除 PACKAGE_LIST_FILE，pack.sh, install.sh, install_gtk_themes.sh, README.md
# 这些是脚本文件和文档，不应该被视为 dotfiles 复制
find . -mindepth 1 -maxdepth 1 ! -name "$PACKAGE_LIST_FILE" \
  ! -name "pack.sh" \
  ! -name "install.sh" \
  ! -name "install_gtk_themes.sh" \
  ! -name "README.md" \
  ! -name "*.pkg.tar.zst" | while read item; do
  ITEM_NAME=$(basename "$item")
  DEST_PATH="$HOME/$ITEM_NAME"

  echo "---"
  print_pacman_info "发现配置模块: ${ITEM_NAME}"
  if ask_yes_no "是否要安装此模块的配置到 '${DEST_PATH}'？"; then
    # 检查目标路径是否存在
    if [ -d "$DEST_PATH" ] || [ -f "$DEST_PATH" ]; then
      print_warn "目标路径 '${DEST_PATH}' 已存在。"
      if ask_yes_no "是否要备份现有的 '${ITEM_NAME}' 配置？(强烈建议备份，避免数据丢失)"; then
        BACKUP_DEST="${DEST_PATH}.bak.$(date +%Y%m%d_%H%M%S)"
        print_pacman_action "正在将现有 '${DEST_PATH}' 备份到 '${BACKUP_DEST}'..."
        mv "$DEST_PATH" "$BACKUP_DEST" || print_error "备份旧配置失败！请检查权限或手动处理。"
        print_pacman_info "旧配置已备份。"
      else
        print_warn "您选择不备份现有配置，现有配置将被覆盖！"
      fi
    fi

    print_pacman_action "正在复制 '${ITEM_NAME}' 配置..."
    if [ -d "$item" ]; then
      cp -r "$item" "$HOME/" || print_error "复制目录 '${ITEM_NAME}' 失败！"
    elif [ -f "$item" ]; then
      cp "$item" "$HOME/" || print_error "复制文件 '${ITEM_NAME}' 失败！"
    fi
    print_pacman_info "'${ITEM_NAME}' 配置已安装。"
  else
    print_pacman_info "跳过 '${ITEM_NAME}' 配置的安装。"
  fi
  echo " "
done

# --- 清理 ---
# 由于不再有临时目录，此部分已移除
print_pacman_info "所有选择的 Dotfiles 和软件包安装已完成！"
print_pacman_info "重要提示：您可能需要**重启应用程序或桌面会话**（注销再登录），甚至**重启电脑**，以使所有更改生效。"
print_pacman_info "如果您安装了新的 GTK 主题或图标，可能需要使用 lxappearance 或其他工具重新应用它们。"

echo " "
print_pacman_info "祝您使用新 Arch Linux 愉快！"
