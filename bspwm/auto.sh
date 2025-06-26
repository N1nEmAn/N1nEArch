#!/bin/bash

# Define the new resolution and modeline for 120Hz
NEW_MODE="3840x2160_120.00"
MODELINE="592.00 3840 4096 4544 5256 2160 2161 2166 2250 -hsync +vsync"
cvt 1440 900 144
xrandr --newmode "1440x900_144.00" 298.00 1440 1552 1704 1968 900 903 913 964 -hsync +vsync
xrandr --addmode DisplayPort-1 "1440x900_144.00"
sh ~/.screenlayout/steram.sh
# sunshine &
# Function to check if a mode exists
mode_exists() {
  xrandr --verbose | grep -q "$NEW_MODE"
}

# Check if HDMI-A-0 is connected
if xrandr | grep "HDMI-A-0 connected"; then
  # Check if the mode already exists
  if mode_exists; then
    echo "Mode $NEW_MODE already exists."
  else
    # Create and add the new mode
    echo "Creating new mode $NEW_MODE."
    xrandr --newmode "$NEW_MODE" $MODELINE
    xrandr --addmode HDMI-A-0 "$NEW_MODE"
  fi

  # Apply the new mode
  if xrandr --output HDMI-A-0 --mode "$NEW_MODE" --right-of eDP; then
    echo "Resolution 3840x2160 at 120Hz applied successfully."
  else
    echo "Resolution 3840x2160 at 120Hz not supported. Falling back to 2560x1440."
    xrandr --output HDMI-A-0 --mode 2560x1440 --right-of eDP
  fi

  # If DisplayPort-0 is connected, set it up as well
  if xrandr | grep "DisplayPort-0 connected"; then
    xrandr --output DisplayPort-0 --mode "$NEW_MODE" --left-of HDMI-A-0
  fi

elif xrandr | grep "eDP connected 1600x2560+0+0 left "; then
  # If HDMI-A-0 is not connected, make eDP the primary display and set rotation
  xrandr --output eDP --primary
  xrandr --output eDP --rotate normal
fi

# Handle the case for three screens
if xrandr | grep "DisplayPort-0 connected" && xrandr | grep "HDMI-A-0 connected"; then
  xrandr --newmode "3840x2160_120" 592.00 3840 4096 4544 5256 2160 2161 2166 2250 -hsync +vsync && xrandr --addmode DisplayPort-0 "3840x2160_120" && xrandr --output DisplayPort-0 --mode "3840x2160_120"
  xrandr --output eDP --primary --mode 2560x1600 --pos 0x0 --rotate normal --output HDMI-A-0 --mode 3840x2160_120.00 --pos 6400x0 --rotate right --output DisplayPort-0 --mode 3840x2160_120 --pos 2560x0 --rotate normal --output DisplayPort-1 --off --output DisplayPort-2 --off --output DisplayPort-3 --off --output DisplayPort-4 --off --output DisplayPort-5 --off --output DisplayPort-6 --off
fi
