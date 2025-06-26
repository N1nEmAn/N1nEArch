#!/bin/bash
# --- Configuration Section ---
# 软件包列表文件，现在直接在当前目录查找
PACKAGE_LIST_FILE="installed_packages.txt"

# --- Function Definitions ---

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

# 询问用户是否继续 (终极通用版本，强制从 /dev/tty 读取)
ask_yes_no() {
  local prompt_text="$1"
  local user_input

  while true; do
    # 打印提示到标准错误，以防标准输出被重定向
    echo -e "\e[1;36m::\e[0m ${prompt_text} (y/n): " >&2

    # 尝试从 /dev/tty 读取输入，这是最可靠的方式
    # 使用 || true 防止 read 失败时脚本退出 (例如 /dev/tty 不可用时)
    read user_input </dev/tty || true

    # 将输入转换为小写，并移除前导/尾随空格
    user_input=$(echo "$user_input" | tr '[:upper:]' '[:lower:]' | xargs)

    case "$user_input" in
    "y" | "yes")
      return 0
      ;;
    "n" | "no")
      return 1
      ;;
    *)
      print_warn "无效输入。请键入 'y' 或 'n' 来确认。"
      ;;
    esac
  done
}

# --- Script Start ---

print_pacman_info "欢迎使用智能 Arch Linux dotfiles 恢复脚本"
print_pacman_info "此脚本将帮助您检查并安装缺失的软件包，然后选择性地恢复当前目录下的配置文件。"

echo " "
print_pacman_info "当前目录内容如下，这些文件将被视为您的配置源："
ls -F --color=always
echo " "

# ---
# Initial confirmation to proceed
# ---
if ! ask_yes_no "是否要继续使用当前目录下的文件进行恢复？"; then
  print_pacman_info "用户取消，脚本退出。"
  exit 0
fi

# ---
# Install GTK Themes (moved here after initial user confirmation)
# ---
print_pacman_action "正在安装 GTK 主题..."
# 检查 install_gtk_themes.sh 是否存在且可执行
if [ -x "./install_gtk_themes.sh" ]; then
  sudo sh ./install_gtk_themes.sh || print_error "GTK 主题安装失败！请检查 install_gtk_themes.sh 脚本或权限。"
else
  print_warn "未找到可执行的 ./install_gtk_themes.sh 脚本，跳过 GTK 主题安装。"
fi

# ---
# Package Check and Installation
# ---
echo " "
print_pacman_info "--- 软件包检查与安装 ---"

# Check if the package list file exists in the current directory
if [ ! -f "$PACKAGE_LIST_FILE" ]; then
  print_warn "当前目录未找到软件包列表文件 '${PACKAGE_LIST_FILE}'。将跳过软件包安装步骤。"
  print_warn "您可能需要手动安装所有依赖的软件包。"
else
  print_pacman_action "正在检查缺失的软件包..."
  MISSING_PACKAGES=()
  while IFS= read -r pkg_with_version; do
    # Extract only the package name, removing the version part
    pkg_name=$(echo "$pkg_with_version" | awk '{print $1}')

    if ! pacman -Q "$pkg_name" &>/dev/null; then
      MISSING_PACKAGES+=("$pkg_name") # Add only the package name to the missing list
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
      # Use yay's --needed option to avoid reinstalling already existing packages
      # yay -S --needed reads package list from standard input
      printf "%s\n" "${MISSING_PACKAGES[@]}" | yay -S --needed - || print_error "软件包安装失败！请检查网络连接或权限。"
      print_pacman_info "缺失软件包安装完成。"
    else
      print_warn "您选择不安装缺失的软件包。某些配置可能无法正常工作。"
    fi
  fi
fi

---
## 配置文件恢复
---

echo " "
print_pacman_info "现在将逐个询问您是否恢复各个配置模块..."
echo " "

# --- 特殊文件处理：environment 和 .xinitrc ---
# 仅当这些文件存在于当前目录时才进行处理
if [ -f "./environment" ] || [ -f "./.xinitrc" ]; then
  echo "========================="
  print_pacman_info "请问您是否在装新机？这两个文件涉及 X11 的配置，如果不是，请选择否。"
  if ask_yes_no "是否要处理特殊的 X11 相关配置 (environment 和 .xinitrc)？"; then
    if [ -f "./environment" ]; then
      echo "========================="
      print_pacman_info "发现特殊配置文件: environment"
      print_pacman_info "目标路径: /etc/environment"
      if ask_yes_no "是否要安装此模块的配置？"; then
        if [ -f "/etc/environment" ]; then
          print_warn "目标文件 '/etc/environment' 已存在。"
          if ask_yes_no "是否要备份现有的 '/etc/environment' 配置？(强烈建议备份，避免数据丢失)"; then
            BACKUP_DEST="/etc/environment.bak.$(date +%Y%m%d_%H%M%S)"
            print_pacman_action "正在将现有 '/etc/environment' 备份到 '${BACKUP_DEST}'..."
            sudo mv "/etc/environment" "$BACKUP_DEST" || print_error "备份旧配置失败！请检查权限或手动处理。"
            print_pacman_info "旧配置已备份。"
          else
            print_warn "您选择不备份现有配置，现有配置将被覆盖！"
          fi
        fi
        print_pacman_action "正在复制 'environment' 配置到 /etc/..."
        sudo cp "./environment" "/etc/" || print_error "复制文件 'environment' 失败！"
        print_pacman_info "'environment' 配置已安装。"
      else
        print_pacman_info "跳过 'environment' 配置的安装。"
      fi
    fi

    if [ -f "./.xinitrc" ]; then
      echo "========================="
      print_pacman_info "发现特殊配置文件: .xinitrc"
      print_pacman_info "目标路径: ~/.xinitrc"
      if ask_yes_no "是否要安装此模块的配置？"; then
        if [ -f "$HOME/.xinitrc" ]; then
          print_warn "目标文件 '$HOME/.xinitrc' 已存在。"
          if ask_yes_no "是否要备份现有的 '$HOME/.xinitrc' 配置？(强烈建议备份，避免数据丢失)"; then
            BACKUP_DEST="$HOME/.xinitrc.bak.$(date +%Y%m%d_%H%M%S)"
            print_pacman_action "正在将现有 '$HOME/.xinitrc' 备份到 '${BACKUP_DEST}'..."
            mv "$HOME/.xinitrc" "$BACKUP_DEST" || print_error "备份旧配置失败！请检查权限或手动处理。"
            print_pacman_info "旧配置已备份。"
          else
            print_warn "您选择不备份现有配置，现有配置将被覆盖！"
          fi
        fi
        print_pacman_action "正在复制 '.xinitrc' 配置到 ~/..."
        cp "./.xinitrc" "$HOME/" || print_error "复制文件 '.xinitrc' 失败！"
        print_pacman_info "'.xinitrc' 配置已安装。"
      else
        print_pacman_info "跳过 '.xinitrc' 配置的安装。"
      fi
    fi
  else
    print_pacman_info "您选择跳过 X11 相关配置（environment 和 .xinitrc）的处理。"
  fi
  echo " "
fi

# --- 复制其他配置文件 (交互式) ---
# 迭代当前目录中的所有项目
# 排除 PACKAGE_LIST_FILE, pack.sh, install.sh, install_gtk_themes.sh, README.md, .git, environment, 和 .xinitrc
# 这些是脚本文件、文档或 Git 仓库元数据，以及已特殊处理的 X11 相关文件，不应作为常规 dotfiles 复制
find . -mindepth 1 -maxdepth 1 \
  ! -name "$PACKAGE_LIST_FILE" \
  ! -name "pack.sh" \
  ! -name "install.sh" \
  ! -name "install_gtk_themes.sh" \
  ! -name "README.md" \
  ! -name "*.pkg.tar.zst" \
  ! -name ".git" \
  ! -name "environment" \
  ! -name ".xinitrc" | while read item; do
  ITEM_NAME=$(basename "$item")

  # 判断是否为 zsh 相关的配置文件
  if [[ "$ITEM_NAME" == *zsh* ]]; then
    DEST_DIR="$HOME/" # Zsh 相关文件放到 ~/
    DEST_PATH="$HOME/$ITEM_NAME"
  else
    DEST_DIR="$HOME/.config/" # 其他文件放到 ~/.config/
    DEST_PATH="$HOME/.config/$ITEM_NAME"
  fi

  echo "========================="
  print_pacman_info "发现配置模块: ${ITEM_NAME}"
  print_pacman_info "目标路径: ${DEST_PATH}" # 打印目标路径
  if ask_yes_no "是否要安装此模块的配置？"; then     # 问题改为更通用
    # Check if the destination path already exists
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
      cp -r "$item" "$DEST_DIR" || print_error "复制目录 '${ITEM_NAME}' 失败！"
    elif [ -f "$item" ]; then
      cp "$item" "$DEST_DIR" || print_error "复制文件 '${ITEM_NAME}' 失败！"
    fi
    print_pacman_info "'${ITEM_NAME}' 配置已安装。"
  else
    print_pacman_info "跳过 '${ITEM_NAME}' 配置的安装。"
  fi
  echo " "
done

---
## 清理与提示
---

print_pacman_info "所有选择的 Dotfiles 和软件包安装已完成！"
print_pacman_info "重要提示：您可能需要**重启应用程序或桌面会话**（注销再登录），甚至**重启电脑**，以使所有更改生效。"
print_pacman_info "如果您安装了新的 GTK 主题或图标，可能需要使用 lxappearance 或其他工具重新应用它们。"

echo " "
print_pacman_info "祝您使用新 Arch Linux 愉快！"
