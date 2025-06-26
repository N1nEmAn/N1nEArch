fcitx5 &
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
xsettingsd &
exec bspwm
