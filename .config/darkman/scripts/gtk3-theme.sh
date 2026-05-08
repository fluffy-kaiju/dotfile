#!/bin/sh
# The names for the Arc theme variations are ambiguous:
# "Darker" is actually LESS DARK than "Dark".

case "$1" in
#dark) ICON=Arc-Dark ;;
#light) ICON=Arc-Darker ;;
dark) ICON=prefer-dark ;;
light) ICON=prefer-light ;;
default) exit 1 ;;
esac

# gsettings set org.gnome.desktop.interface gtk-theme "$ICON"
gsettings set org.gnome.desktop.interface color-scheme "$ICON"
