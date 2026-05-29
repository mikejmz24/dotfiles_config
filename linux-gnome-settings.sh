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
# 
# =============================================================================
# DISPLAY SCALING — Fractional / per-monitor scaling (Wayland)
# Unlocks the 125% / 150% / 175% scale options in Settings → Displays so each
# monitor can be scaled independently. Needed for the mixed-DPI setup: the
# 16" 1920x1200 laptop panel (~141 PPI) alongside a 32" 4K external monitor
# (3840x2160, ~138 PPI), which otherwise renders far too small at 100%.
#
# This line only ENABLES the feature. The actual per-monitor scale percentages
# live in ~/.config/monitors.xml, which is tied to each display's connector and
# serial number and is therefore machine-specific — it is NOT tracked by
# chezmoi. Set the percentages by hand in Settings → Displays on each machine.
# =============================================================================
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
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

# ── Workspace keybindings ──────────────────────────────
# Clear Super+1-9 from dash app launcher
for i in {1..9}; do
  gsettings set org.gnome.shell.keybindings switch-to-application-$i '[]'
done

# Super+1-9 → switch to workspace
for i in {1..9}; do
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']"
done

# Super+Shift+1-9 → move window to workspace
for i in {1..9}; do
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$i "['<Super><Shift>$i']"
done
