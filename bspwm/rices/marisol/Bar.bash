RICE=marisol
# This file launch the bar/s
for mon in $(polybar --list-monitors | cut -d":" -f1); do
  MONITOR=$mon polybar -q marisol -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
done
