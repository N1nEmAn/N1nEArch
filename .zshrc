#  ╔═╗╔═╗╦ ╦╦═╗╔═╗  ╔═╗╔═╗╔╗╔╔═╗╦╔═╗
#  ╔═╝╚═╗╠═╣╠╦╝║    ║  ║ ║║║║╠╣ ║║ ╦
#  ╚═╝╚═╝╩ ╩╩╚═╚═╝  ╚═╝╚═╝╝╚╝╚  ╩╚═╝
# Function to list Docker containers, supports -a option to show all containers
dockps() {
  if [[ "$1" == "-a" ]]; then
    echo "Listing all Docker containers (including stopped):"
    docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
  else
    echo "Listing all running Docker containers:"
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
  fi
}
# Function to enter a Docker container by name or partial ID (first two characters)
docksh() {
  if [ -z "$1" ]; then
    echo "Usage: docksh <container_name_or_id>"
    return 1
  fi

  # Try to find the container ID by name or the first two characters of the ID
  local container_id=$(docker ps -aq --filter "name=$1" --filter "id=$1" | grep -E "^$1" | head -n 1)

  if [ -z "$container_id" ]; then
    # Attempt to find any container ID matching the first two characters
    container_id=$(docker ps -aq | grep "^$1")

    if [ -z "$container_id" ]; then
      echo "No container found matching '$1'."
      return 1
    fi

    echo "Starting container '$container_id'..."
    docker start "$container_id"
  fi

  # Enter the container's shell
  docker exec -it "$container_id" /bin/bash 2>/dev/null || docker exec -it "$container_id" /bin/sh
}
dockcp() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: dockcp <container_name_or_id>:<source_path> <destination_path>"
        return 1
    fi

    container_path=$1
    dest_path=$2

    docker cp "$container_path" "$dest_path"
}
dockshi() {
  docker run -it $1 /bin/bash
}

#  ┬  ┬┌─┐┬─┐┌─┐
#  └┐┌┘├─┤├┬┘└─┐
#   └┘ ┴ ┴┴└─└─┘

export VISUAL="${EDITOR}"
export EDITOR="nvim"
export TERMINAL="alacritty"
export BROWSER="microsoft-edge-dev"
export HISTORY_IGNORE="(ls|cd|pwd|exit|reboot|history|cd -|cd ..)"

bindkey '^A' beginning-of-line

bindkey '^[[1;5D' backward-word  # Ctrl + ← 向左移动一个单词

bindkey '^[[1;5C' forward-word   # Ctrl + → 向右移动一个单词
if [ -d "$HOME/.local/bin" ];
  then PATH="$HOME/.local/bin:$PATH"
fi

#  ┬  ┌─┐┌─┐┌┬┐  ┌─┐┌┐┌┌─┐┬┌┐┌┌─┐
#  │  │ │├─┤ ││  ├┤ ││││ ┬││││├┤ 
#  ┴─┘└─┘┴ ┴─┴┘  └─┘┘└┘└─┘┴┘└┘└─┘

autoload -Uz compinit

for dump in ~/.config/zsh/zcompdump(N.mh+24); do
  compinit -d ~/.config/zsh/zcompdump
done

compinit -C -d ~/.config/zsh/zcompdump

autoload -Uz add-zsh-hook
autoload -Uz vcs_info
precmd () { vcs_info }
_comp_options+=(globdots)

zstyle ':completion:*' verbose true
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS} 'ma=48;5;197;1'
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:warnings' format "%B%F{red}No matches for:%f %F{magenta}%d%b"
zstyle ':completion:*:descriptions' format '%F{yellow}[-- %d --]%f'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:*' formats '%F{green}%b%u%c%f '
zstyle ':vcs_info:*' actionformats '%F{green}%b|%a%u%c%f '

#  ┬ ┬┌─┐┬┌┬┐┬┌┐┌┌─┐  ┌┬┐┌─┐┌┬┐┌─┐
#  │││├─┤│ │ │││││ ┬   │││ │ │ └─┐
#  └┴┘┴ ┴┴ ┴ ┴┘└┘└─┘  ─┴┘└─┘ ┴ └─┘

expand-or-complete-with-dots() {
  echo -n "\e[31m…\e[0m"
  zle expand-or-complete
  zle redisplay
}

zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

#  ┬ ┬┬┌─┐┌┬┐┌─┐┬─┐┬ ┬
#  ├─┤│└─┐ │ │ │├┬┘└┬┘
#  ┴ ┴┴└─┘ ┴ └─┘┴└─ ┴ 

HISTFILE=~/.config/zsh/zhistory
HISTSIZE=20000
SAVEHIST=20000

#  ┌─┐┌─┐┬ ┬  ┌─┐┌─┐┌─┐┬    ┌─┐┌─┐┌┬┐┬┌─┐┌┐┌┌─┐
#  ┌─┘└─┐├─┤  │  │ ││ ││    │ │├─┘ │ ││ ││││└─┐
#  └─┘└─┘┴ ┴  └─┘└─┘└─┘┴─┘  └─┘┴   ┴ ┴└─┘┘└┘└─┘

setopt AUTOCD              # Change directory just by typing its name
setopt PROMPT_SUBST        # Enable command substitution in prompt
setopt MENU_COMPLETE       # Automatically highlight first element of completion menu
setopt LIST_PACKED         # The completion menu takes less space.
setopt AUTO_LIST           # Automatically list choices on ambiguous completion.
setopt HIST_IGNORE_DUPS    # Do not write events to history that are duplicates of previous events
setopt HIST_FIND_NO_DUPS   # When searching history don't display results already cycled through twice
setopt COMPLETE_IN_WORD    # Complete from both ends of a word.

#  ┌┬┐┬ ┬┌─┐  ┌─┐┬─┐┌─┐┌┬┐┌─┐┌┬┐
#   │ ├─┤├┤   ├─┘├┬┘│ ││││├─┘ │ 
#   ┴ ┴ ┴└─┘  ┴  ┴└─└─┘┴ ┴┴   ┴

PS1='λ %B%F{red}%~/ %f%b${vcs_info_msg_0_}'

#  ┌─┐┬  ┬ ┬┌─┐┬┌┐┌┌─┐
#  ├─┘│  │ ││ ┬││││└─┐
#  ┴  ┴─┘└─┘└─┘┴┘└┘└─┘

source /home/S3vn/.zsh/plugins/sudo/sudo.plugin.zsh
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

#  ┌─┐┬ ┬┌─┐┌┐┌┌─┐┌─┐  ┌┬┐┌─┐┬─┐┌┬┐┬┌┐┌┌─┐┬  ┌─┐  ┌┬┐┬┌┬┐┬  ┌─┐
#  │  ├─┤├─┤││││ ┬├┤    │ ├┤ ├┬┘│││││││├─┤│  └─┐   │ │ │ │  ├┤ 
#  └─┘┴ ┴┴ ┴┘└┘└─┘└─┘   ┴ └─┘┴└─┴ ┴┴┘└┘┴ ┴┴─┘└─┘   ┴ ┴ ┴ ┴─┘└─┘

function xterm_title_precmd () {
  print -Pn -- '\e]2;%n@%m %~\a'
  [[ "$TERM" == 'screen'* ]] && print -Pn -- '\e_\005{g}%n\005{-}@\005{m}%m\005{-} \005{B}%~\005{-}\e\\'
}

function xterm_title_preexec () {
  print -Pn -- '\e]2;%n@%m %~ %# ' && print -n -- "${(q)1}\a"
  [[ "$TERM" == 'screen'* ]] && { print -Pn -- '\e_\005{g}%n\005{-}@\005{m}%m\005{-} \005{B}%~\005{-} %# ' && print -n -- "${(q)1}\e\\"; }
}

if [[ "$TERM" == (kitty*|alacritty*|termite*|gnome*|konsole*|kterm*|putty*|rxvt*|screen*|tmux*|xterm*) ]]; then
  add-zsh-hook -Uz precmd xterm_title_precmd
  add-zsh-hook -Uz preexec xterm_title_preexec
fi

#  ┌─┐┬  ┬┌─┐┌─┐
#  ├─┤│  │├─┤└─┐
#  ┴ ┴┴─┘┴┴ ┴└─┘

alias grub-update="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias mantenimiento="yay -Sc && sudo pacman -Scc"
alias purga="sudo pacman -Rns $(pacman -Qtdq) ; sudo fstrim -av"
alias update="sudo pacman -Syyu"

alias vm-on="sudo systemctl start libvirtd.service"
alias vm-off="sudo systemctl stop libvirtd.service"

alias musica="ncmpcpp"

alias ls='eza --icons'
# alias ls='lsd'
alias l='eza -alg --group-directories-first --octal-permissions '
alias ll='eza -algF --group-directories-first --octal-permissions'
alias lld='eza -algFD --group-directories-first --octal-permissions '
alias vi='nvim'
alias set-proxy='export ALL_PROXY=http://127.0.0.1:7890'
alias unset-proxy='unset ALL_PROXY'
alias x="startx"
alias cat="bat"

#use sdu-net
alias sdunet="~/Public/sdunetd/sdunetd-linux-amd64 -c ~/Public/sdunetd/config.json &  ~/Public/sdunetd/sdunetd-linux-amd64 -c ~/Public/sdunetd/configv6.json &"
#alias btop="bpytop"

# SWITCH GPU

alias gpu-mode='optimus-manager --print-mode'
alias nvidia='optimus-manager --switch nvidia'

# PWN

alias checkaslr='cat /proc/sys/kernel/randomize_va_space'
alias aslron='echo 2 | sudo tee /proc/sys/kernel/randomize_va_space'
alias aslrhalf='echo 1 | sudo tee /proc/sys/kernel/randomize_va_space'
alias aslroff='echo 0 | sudo tee /proc/sys/kernel/randomize_va_space'

# Applications

alias discord='discord --proxy-server="socks5://127.0.0.1:1080"'
alias element='element-desktop --proxy-server="socks5://127.0.0.1:1080"'

#  ┌─┐┬ ┬┌┬┐┌─┐  ┌─┐┌┬┐┌─┐┬─┐┌┬┐
#  ├─┤│ │ │ │ │  └─┐ │ ├─┤├┬┘ │ 
#  ┴ ┴└─┘ ┴ └─┘  └─┘ ┴ ┴ ┴┴└─ ┴ 

$HOME/.local/bin/colorscript -r

# export PATH="/home/N1nE/.cargo/bin:$PATH"
export BAT_THEME="TwoDark"
fc -R ~/.zsh_history
alias vit="~/Temp/vitex.sh"
alias wsc="wsc -p 21097"
# export PS1="\[\033[0m\]ξ \[\033[1;35m\]\w/ \[\033[0m\]"
# fc -R ~/.backup/zsh_20231224-203851/zhistory
#export ALL_PROXY=socks5://127.0.0.1:33333
export WASMTIME_NEW_CLI=0
# export PATH=~/Temp/AFLplusplus:$PATH

alias vxgraph="/home/N1nE/Progress/THU/VxHello/vx_graph/main.py"
alias arch="uname -m"
checkcwe() {
    docker run --rm -v "$1:/input" ghcr.io/fkie-cad/cwe_checker /input
}
alias firmwalker=/home/N1nE/Public/firmwalker/firmwalker.sh

export PATH=$PATH:$(go env GOPATH)/bin
alias untar="tar -xvf"
alias rf="rm -rf"
alias dcbuild=" docker-compose build"
alias dcup=" docker-compose up"
alias dcdown=" docker-compose down"
# alias intar="tar -cvf $1.tar.gz $1/*"
intar() {
    tar -cvf $1.tar.gz $1/*
}
alias fetch=fastfetch
rme() {
    local keyword="$1"

    # 检查是否提供关键字
    if [ -z "$keyword" ]; then
        echo "错误：请提供要保留的关键字作为参数！"
        return 1
    fi

    # 在当前目录删除不包含关键字的文件
    find ./ -type f ! -name "*$keyword*" -exec rm -f {} +

    echo "已删除当前目录下所有不包含 \"$keyword\" 的文件。"
}
alias sl=ls
export XDG_SESSION_TYPE=x11
alias suvi="sudo -E nvim"
export JAVA_HOME=/opt/android-studio/jbr
export PATH="$JAVA_HOME/bin:$PATH"
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
alias unzip="unzip -O cp936"
