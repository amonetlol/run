#!/usr/bin/env bash

if [[ $# -gt 2 || $1 != "standalone" && $1 != "menu" ]]; then
	echo "Usage $0 [mode] [previous_menu]"
	exit 1
fi

THEME_PATH="$HOME/.config/rofi/catppuccin-script.rasi"
SCRIPT_DIR="$HOME/Scripts/Rofi"

MODE="${1:-menu}"
BACK="${2:-menu}"

options=$(printf " General\n Keybindings\n Hyprlock\n Hypridle\n Monitors" | rofi -i -dmenu -p " Hyprland" -theme "$THEME_PATH")

if [[ -z "$options" ]]; then
	if [[ "$MODE" == "menu" ]]; then
		exec "$SCRIPT_DIR/menu.sh" "$BACK"
	else
		exit 0
	fi
fi

case "$options" in
*General*)
	foot nvim "$HOME/.config/hypr/hyprland.lua"
	;;
*Keybindings*)
	foot nvim "$HOME/.config/hypr/keybindings.lua"
	;;
*Hyprlock*)
	foot nvim "$HOME/.config/hypr/hyprlock.conf"
	;;
*Hypridle*)
	foot nvim "$HOME/.config/hypr/hypridle.conf"
	;;
*Monitors*)
	foot nvim "$HOME/.config/hypr/monitors.lua"
	;;
*)
	notify-send -u normal "This option doesn't exist."
	;;
esac
