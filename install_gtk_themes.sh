#!/usr/bin/env bash

set -e

# --- 全局变量和颜色定义 ---
CRE=$(tput setaf 1) # Red
CYE=$(tput setaf 3) # Yellow
CGR=$(tput setaf 2) # Green
CBL=$(tput setaf 4) # Blue
BLD=$(tput bold)    # Bold
CNC=$(tput sgr0)    # Reset colors

ERROR_LOG="$HOME/RiceError.log" # 错误日志文件路径

# --- 辅助函数 ---

# 打印带有Logo的标题
logo() {
  text="$1"
  printf "%b" "
    1llusion Dotfiles\n\n"
  printf ' %s [%s%s %s%s %s]%s\n\n' "${CRE}" "${CNC}" "${CYE}" "${text}" "${CNC}" "${CRE}" "${CNC}"
}

# 记录错误信息到日志并输出到标准错误
log_error() {
  error_msg=$1
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  printf "%s" "[${timestamp}] ERROR: ${error_msg}\n" >>"$ERROR_LOG"
  printf "%s%sERROR:%s %s\n" "${CRE}" "${BLD}" "${CNC}" "${error_msg}" >&2
}

# 检查软件包是否已安装
is_installed() {
  pacman -Qq "$1" >/dev/null 2>&1
}

# --- 添加 gh0stzk 仓库 ---
add_gh0stzk_repo() {
  clear
  logo "Add gh0stzk custom repo"
  repo_name="gh0stzk-dotfiles"
  sleep 2

  printf "%b\n" "${BLD}${CYE}Installing ${CBL}${repo_name}${CYE} repository...${CNC}"

  if ! grep -q "\[${repo_name}\]" /etc/pacman.conf; then
    if printf "\n[%s]\nSigLevel = Optional TrustAll\nServer = http://gh0stzk.github.io/pkgs/x86_64\n" "$repo_name" |
      sudo tee -a /etc/pacman.conf >/dev/null 2>>"$ERROR_LOG"; then
      printf "\n%b\n" "${BLD}${CYE}${repo_name} ${CGR}repository added successfully!${CNC}"

      if ! sudo pacman -Syy 2>&1 | tee -a "$ERROR_LOG" >/dev/null; then
        log_error "Database update failed"
        return 1
      fi
    else
      log_error "Error adding repository - check permissions"
      return 1
    fi
  else
    printf "\n%b\n" "${BLD}${CYE}The repository already exists and is configured${CNC}"
    sleep 3
    return 0
  fi
}

# --- 添加 chaotic-aur 仓库 ---
add_chaotic_repo() {
  clear
  logo "Add chaotic-aur repository"
  repo_name="chaotic-aur"
  key_id="3056513887B78AEB"
  sleep 2

  printf "%b\n" "${BLD}${CYE}Installing ${CBL}${repo_name}${CYE} repository...${CNC}"

  if grep -q "\[${repo_name}\]" /etc/pacman.conf; then
    printf "%b\n" "\n${BLD}${CYE}Repository already exists in pacman.conf${CNC}"
    sleep 3
    return 0
  fi

  if ! pacman-key -l | grep -q "$key_id"; then
    printf "%b\n" "${BLD}${CYE}Adding GPG key...${CNC}"
    if ! sudo pacman-key --recv-key "$key_id" --keyserver keyserver.ubuntu.com 2>&1 | tee -a "$ERROR_LOG" >/dev/null; then
      log_error "Failed to receive GPG key"
      return 1
    fi

    printf "%b\n" "${BLD}${CYE}Signing key locally...${CNC}"
    if ! sudo pacman-key --lsign-key "$key_id" 2>&1 | tee -a "$ERROR_LOG" >/dev/null; then
      log_error "Failed to sign GPG key"
      return 1
    fi
  else
    printf "\n%b\n" "${BLD}${CYE}GPG key already exists in keyring${CNC}"
  fi

  chaotic_pkgs="chaotic-keyring chaotic-mirrorlist"
  for pkg in $chaotic_pkgs; do
    if ! pacman -Qq "$pkg" >/dev/null 2>&1; then
      printf "%b\n" "${BLD}${CYE}Installing ${CBL}${pkg}${CNC}"
      if ! sudo pacman -U --noconfirm "https://cdn-mirror.chaotic.cx/chaotic-aur/${pkg}.pkg.tar.zst" 2>&1 | tee -a "$ERROR_LOG" >/dev/null; then
        log_error "Failed to install ${pkg}"
        return 1
      fi
    else
      printf "%b\n" "${BLD}${CYE}${pkg} is already installed${CNC}"
    fi
  done

  printf "\n%b\n" "${BLD}${CYE}Adding repository to pacman.conf...${CNC}"
  if ! printf "\n[%s]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n" "$repo_name" |
    sudo tee -a /etc/pacman.conf >/dev/null 2>>"$ERROR_LOG"; then
    log_error "Failed to add repository configuration"
    return 1
  fi

  printf "%b\n" "\n${BLD}${CBL}${repo_name} ${CGR}Repository configured successfully!${CNC}"
  sleep 3
}

# --- 安装 gh0stzk 仓库依赖 ---
install_gh0stzk_dependencies() {
  clear
  logo "Installing needed packages from gh0stzk repository..."
  sleep 2

  gh0stzk_dependencies="
    gh0stzk-gtk-themes gh0stzk-cursor-qogirr gh0stzk-icons-beautyline
    gh0stzk-icons-candy gh0stzk-icons-catppuccin-mocha gh0stzk-icons-dracula
    gh0stzk-icons-glassy gh0stzk-icons-gruvbox-plus-dark gh0stzk-icons-hack
    gh0stzk-icons-luv gh0stzk-icons-sweet-rainbow gh0stzk-icons-tokyo-night
    gh0stzk-icons-vimix-white gh0stzk-icons-zafiro gh0stzk-icons-zafiro-purple
  "

  printf "%b\n\n" "\n${BLD}${CBL}Checking for required packages...${CNC}"
  sleep 2

  missing_gh0stzk_pkgs=""
  for pkg in $gh0stzk_dependencies; do
    if ! is_installed "$pkg"; then
      missing_gh0stzk_pkgs="$missing_gh0stzk_pkgs $pkg"
      printf "%b\n" " ${BLD}${CYE}$pkg ${CRE}not installed${CNC}"
    else
      printf "%b\n" "${BLD}${CGR}$pkg ${CBL}already installed${CNC}"
    fi
  done

  if [ -n "$(printf "%s" "$missing_gh0stzk_pkgs" | tr -s ' ')" ]; then
    count=$(printf "%s" "$missing_gh0stzk_pkgs" | wc -w)
    printf "\n%b\n\n" "${BLD}${CYE}Installing $count packages, please wait...${CNC}"

    if sudo pacman -S --noconfirm $missing_gh0stzk_pkgs 2>&1 | tee -a "$ERROR_LOG" >/dev/null; then
      failed_gh0stzk_pkgs=""
      for pkg in $missing_gh0stzk_pkgs; do
        if ! is_installed "$pkg"; then
          failed_gh0stzk_pkgs="$failed_gh0stzk_pkgs $pkg"
          log_error "Failed to install: $pkg"
        fi
      done

      if [ -z "$(printf "%s" "$failed_gh0stzk_pkgs" | tr -s ' ')" ]; then
        printf "%b\n\n" "${BLD}${CGR}All packages installed successfully!${CNC}"
      else
        fail_count=$(printf "%s" "$failed_gh0stzk_pkgs" | wc -w)
        printf "%b\n" "${BLD}${CRE}Failed to install $fail_count packages:${CNC}"
        printf "%b\n\n" "  ${BLD}${CYE}$(printf "%s" "$failed_gh0stzk_pkgs")${CNC}"
      fi
    else
      log_error "Critical error during batch installation"
      printf "%b\n" "${BLD}${CRE}Installation failed! Check log for details${CNC}"
      return 1
    fi
  else
    printf "\n%b\n" "${BLD}${CGR}All dependencies are already installed!${CNC}"
  fi

  sleep 3
}

# --- 执行顺序（示例）---
# 为了单独运行 install_gh0stzk_dependencies，你需要确保以下函数和变量可用
# initial_checks # 原始脚本中的其他检查，此处未包含，但如果直接运行可能需要
# welcome # 原始脚本中的欢迎界面，此处未包含

add_gh0stzk_repo             # 添加 gh0stzk 仓库
add_chaotic_repo             # 添加 chaotic-aur 仓库（因为 gh0stzk 的一些主题可能依赖 chaotic-aur 中的 paru 或其他包）
install_gh0stzk_dependencies # 运行安装 gh0stzk 仓库依赖的函数
