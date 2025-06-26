#!/bin/bash

# Define the new resolution and modeline for 120Hz
NEW_MODE="3840x2160_120.00"
MODELINE="592.00 3840 4096 4544 5256 2160 2161 2166 2250 -hsync +vsync"

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
fi

if ! xrandr | grep "HDMI-A-0 connected"; then
  # If HDMI-A-0 is not connected, make eDP the primary display and set rotation
  if xrandr --current | grep "eDP connected 1600x2560+0+0 left "; then
    xrandr --output eDP --primary
    xrandr --output eDP --rotate normal
  fi
fi
xrandr --newmode "3840x2160_120" 592.00 3840 4096 4544 5256 2160 2161 2166 2250 -hsync +vsync && xrandr --addmode DisplayPort-0 "3840x2160_120" && xrandr --output DisplayPort-0 --mode "3840x2160_120"
