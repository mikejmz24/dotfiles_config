# =============================================================================
# APP LAUNCHER
# pop-launcher (System76) was the original plan — it's a Spotlight-like
# launcher designed specifically for GNOME Wayland. However it was removed
# from the system76-dev PPA and moved to the COSMIC desktop environment
# which is not available on standard Ubuntu.
#
# Current solution: GNOME Activities (Super key)
# - Press Super to open Activities with instant search
# - Start typing immediately to find apps, files, settings
# - Works natively on Wayland, no configuration needed
# - Good enough for daily use on the Darter Pro
# =============================================================================

# =============================================================================
# WINDOW MANAGEMENT
# Super+Up — maximize window (keeps top bar visible)
# Super+F — true fullscreen (hides everything including top bar)
# Works system-wide across all apps
# =============================================================================
gsettings set org.gnome.desktop.wm.keybindings maximize "['<Super>Up']"
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Super>f']"

# =============================================================================
# DOCK — Completely hidden, never visible
# ubuntu-dock disabled — falls back to GNOME built-in dash
# Just Perfection extension used to hide the built-in dash from Activities
# =============================================================================
gnome-extensions disable ubuntu-dock@ubuntu.com
dconf write /org/gnome/shell/extensions/just-perfection/dash false
dconf write /org/gnome/shell/extensions/just-perfection/dash-app-running false
dconf write /org/gnome/shell/extensions/just-perfection/dash-separator false
dconf write /org/gnome/shell/extensions/just-perfection/show-apps-button false
