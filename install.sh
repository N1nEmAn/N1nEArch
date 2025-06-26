#!/bin/bash
sudo sh ./install_gtk_themes.sh
# --- 配置区 ---
# 临时解压目录，用于存放解压后的内容和临时的软件包列表
TEMP_EXTRACT_DIR="$HOME/temp_dotfiles_restore"
# 备份文件中包含的软件包列表文件名
PACKAGE_LIST_FILE="installed_packages.txt"

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
print_pacman_info "此脚本将帮助您检查并安装缺失的软件包，然后选择性地恢复备份的配置文件。"

echo " "
# 查找最新的备份文件
LATEST_BACKUP=$(ls -t "$HOME"/arch_dotfiles_backup_*.tar.gz 2>/dev/null | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
  print_error "在您的家目录中找不到任何以 'arch_dotfiles_backup_' 开头并以 '.tar.gz' 结尾的备份文件。请确保备份文件已存在于您的 \$HOME 目录下。"
fi

BACKUP_FILE=$(basename "$LATEST_BACKUP")
print_pacman_info "找到最新的备份文件: ${BACKUP_FILE}"
echo " "

if ! ask_yes_no "是否要继续使用此备份文件进行恢复？"; then
  print_pacman_info "用户取消，脚本退出。"
  exit 0
fi

# 创建临时目录
if [ -d "$TEMP_EXTRACT_DIR" ]; then
  print_warn "临时目录 '${TEMP_EXTRACT_DIR}' 已存在，正在删除旧目录..."
  rm -rf "$TEMP_EXTRACT_DIR" || print_error "无法删除旧的临时目录，请手动检查或删除：${TEMP_EXTRACT_DIR}"
fi
mkdir -p "$TEMP_EXTRACT_DIR" || print_error "无法创建临时目录 '${TEMP_EXTRACT_DIR}'。"

print_pacman_action "正在解压备份文件 '${HOME}/${BACKUP_FILE}' 到 '${TEMP_EXTRACT_DIR}'..."
tar -xzvf "${HOME}/${BACKUP_FILE}" -C "${TEMP_EXTRACT_DIR}" || print_error "解压失败！请检查备份文件是否损坏或路径是否正确。"

echo " "
print_pacman_info "--- 软件包检查与安装 ---"

# 检查软件包列表文件是否存在于备份中
if [ ! -f "$TEMP_EXTRACT_DIR/$PACKAGE_LIST_FILE" ]; then
  print_warn "备份中未找到软件包列表文件 '${PACKAGE_LIST_FILE}'。将跳过软件包安装步骤。"
  print_warn "您可能需要手动安装所有依赖的软件包。"
else
  print_pacman_action "正在检查缺失的软件包..."
  MISSING_PACKAGES=()
  while IFS= read -r pkg; do
    if ! pacman -Q "$pkg" &>/dev/null; then
      MISSING_PACKAGES+=("$pkg")
    fi
  done <"$TEMP_EXTRACT_DIR/$PACKAGE_LIST_FILE"

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
    fi
  fi
fi

echo " "
print_pacman_info "--- 配置文件恢复 ---"
print_pacman_info "现在将逐个询问您是否恢复各个配置模块..."
echo " "

# --- 复制配置文件（交互式） ---
# 遍历临时解压目录中的所有项目
# 排除 PACKAGE_LIST_FILE，因为它不是一个配置目录
find "$TEMP_EXTRACT_DIR" -mindepth 1 -maxdepth 1 ! -name "$PACKAGE_LIST_FILE" | while read item; do
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
print_pacman_action "正在清理临时目录 '${TEMP_EXTRACT_DIR}'..."
rm -rf "$TEMP_EXTRACT_DIR" || print_warn "无法删除临时目录 '${TEMP_EXTRACT_DIR}'，请手动清理。"

print_pacman_info "所有选择的 Dotfiles 和软件包安装已完成！"
print_pacman_info "重要提示：您可能需要**重启应用程序或桌面会话**（注销再登录），甚至**重启电脑**，以使所有更改生效。"
print_pacman_info "如果您安装了新的 GTK 主题或图标，可能需要使用 $(lxappearance) 或其他工具重新应用它们。"

echo " "
print_pacman_info "祝您使用新 Arch Linux 愉快！"
