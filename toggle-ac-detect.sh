#!/usr/bin/env bash
# toggle-ac-detect.sh — Disable or enable AC adapter detection on Ubuntu/Linux
# For Razer Blade & similar laptops with AC connect/disconnect flickering.

BLACKLIST_FILE="/etc/modprobe.d/blacklist-acpi-power.conf"

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

show_help() {
cat << EOF
${YELLOW}Usage:${NC}
  sudo $(basename "$0") [option]

${YELLOW}Options:${NC}
  -d, --disable     Disable AC adapter detection (BIOS-only charging)
  -e, --enable      Re-enable AC adapter detection
  -s, --status      Show current AC detection status
  -h, --help        Show this help message

${YELLOW}Notes:${NC}
  • Requires reboot after enabling or disabling.
  • GNOME/KDE power notifications are adjusted automatically.
EOF
}

disable_ac_detect() {
    echo "[INFO] Disabling AC adapter detection..."
    if ! grep -q "^blacklist ac" "$BLACKLIST_FILE" 2>/dev/null; then
        echo "blacklist ac" | sudo tee "$BLACKLIST_FILE" >/dev/null
        sudo update-initramfs -u
        echo -e "${GREEN}[DONE]${NC} Kernel AC detection disabled."
    else
        echo -e "${YELLOW}[SKIP]${NC} Already disabled."
    fi
    disable_desktop_power_notifs
    echo "Reboot required for changes to take effect."
}

enable_ac_detect() {
    echo "[INFO] Enabling AC adapter detection..."
    if [ -f "$BLACKLIST_FILE" ]; then
        sudo rm -f "$BLACKLIST_FILE"
        sudo update-initramfs -u
        echo -e "${GREEN}[DONE]${NC} Kernel AC detection enabled."
    else
        echo -e "${YELLOW}[SKIP]${NC} Already enabled."
    fi
    enable_desktop_power_notifs
    echo "Reboot required for changes to take effect."
}

disable_desktop_power_notifs() {
    if command -v gsettings >/dev/null 2>&1; then
        echo "[GNOME] Disabling power notifications..."
        gsettings set org.gnome.settings-daemon.plugins.power active false 2>/dev/null || true
    fi
    if systemctl --user list-units | grep -q powerdevil.service; then
        echo "[KDE] Disabling PowerDevil..."
        systemctl --user mask plasma-powerdevil.service 2>/dev/null || true
    fi
}

enable_desktop_power_notifs() {
    if command -v gsettings >/dev/null 2>&1; then
        echo "[GNOME] Restoring power notifications..."
        gsettings set org.gnome.settings-daemon.plugins.power active true 2>/dev/null || true
    fi
    if systemctl --user list-unit-files | grep -q plasma-powerdevil.service; then
        echo "[KDE] Restoring PowerDevil..."
        systemctl --user unmask plasma-powerdevil.service 2>/dev/null || true
    fi
}

show_status() {
    echo -n "Kernel AC detection: "
    if [ -f "$BLACKLIST_FILE" ]; then
        echo -e "${RED}DISABLED${NC}"
    else
        echo -e "${GREEN}ENABLED${NC}"
    fi
}

case "$1" in
    -d|--disable) disable_ac_detect ;;
    -e|--enable) enable_ac_detect ;;
    -s|--status) show_status ;;
    -h|--help|"") show_help ;;
    *) echo "Unknown option: $1"; show_help; exit 1 ;;
esac

