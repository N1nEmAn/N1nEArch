# Shell & Zinit
[ -d ~/.config/zsh ] && cp -r ~/.config/zsh ~/my_arch_dotfiles_backup/
[ -d ~/.zsh ] && cp -r ~/.zsh ./
[ -f ~/.zshrc ] && cp ~/.zshrc ./

# Terminal Emulators
[ -d ~/.config/alacritty ] && cp -r ~/.config/alacritty ~/my_arch_dotfiles_backup/
[ -d ~/.config/kitty ] && cp -r ~/.config/kitty ~/my_arch_dotfiles_backup/

# Window Manager & Related
[ -d ~/.config/bspwm ] && cp -r ~/.config/bspwm ~/my_arch_dotfiles_backup/
[ -d ~/.config/sxhkd ] && cp -r ~/.config/sxhkd ~/my_arch_dotfiles_backup/
[ -d ~/.config/polybar ] && cp -r ~/.config/polybar ~/my_arch_dotfiles_backup/
[ -d ~/.config/dunst ] && cp -r ~/.config/dunst ~/my_arch_dotfiles_backup/
[ -d ~/.config/rofi ] && cp -r ~/.config/rofi ~/my_arch_dotfiles_backup/
[ -d ~/.config/jgmenu ] && cp -r ~/.config/jgmenu ~/my_arch_dotfiles_backup/
[ -d ~/.config/nitrogen ] && cp -r ~/.config/nitrogen ~/my_arch_dotfiles_backup/
[ -d ~/.config/picom ] && cp -r ~/.config/picom ~/my_arch_dotfiles_backup/
[ -d ~/.config/eww ] && cp -r ~/.config/eww ~/my_arch_dotfiles_backup/

# File Manager
[ -d ~/.config/nemo ] && cp -r ~/.config/nemo ~/my_arch_dotfiles_backup/
[ -d ~/.config/ranger ] && cp -r ~/.config/ranger ~/my_arch_dotfiles_backup/
[ -d ~/.config/yazi ] && cp -r ~/.config/yazi ~/my_arch_dotfiles_backup/

# Input Method
[ -d ~/.config/fcitx5 ] && cp -r ~/.config/fcitx5 ~/my_arch_dotfiles_backup/

# Media
[ -d ~/.config/mpd ] && cp -r ~/.config/mpd ~/my_arch_dotfiles_backup/
[ -d ~/.config/ncmpcpp ] && cp -r ~/.config/ncmpcpp ~/my_arch_dotfiles_backup/

# Other Utilities
[ -d ~/.config/btop ] && cp -r ~/.config/btop ~/my_arch_dotfiles_backup/
[ -d ~/.config/eza ] && cp -r ~/.config/eza ~/my_arch_dotfiles_backup/
[ -d ~/.config/fastfetch ] && cp -r ~/.config/fastfetch ~/my_arch_dotfiles_backup/
[ -d ~/.config/clipcat ] && cp -r ~/.config/clipcat ~/my_arch_dotfiles_backup/
[ -d ~/.config/flameshot ] && cp -r ~/.config/flameshot ~/my_arch_dotfiles_backup/
[ -d ~/.config/redshift ] && cp -r ~/.config/redshift ~/my_arch_dotfiles_backup/
[ -d ~/.config/lxappearance ] && cp -r ~/.config/lxappearance ~/my_arch_dotfiles_backup/ # LXAppearance 配置可能也在此

# General Configs
[ -d ~/.config/fontconfig ] && cp -r ~/.config/fontconfig ~/my_arch_dotfiles_backup/

# Themes and Icons (仅当它们存储在家目录时)
[ -d ~/.themes ] && cp -r ~/.themes ~/my_arch_dotfiles_backup/
[ -d ~/.icons ] && cp -r ~/.icons ~/my_arch_dotfiles_backup/
