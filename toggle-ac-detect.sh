#!/usr/bin/env bash
# toggle-ac-detect.sh — Disable or enable AC adapter detection on Ubuntu/Linux
# Correct method (kernel param): acpi=noacpi_ac_adapter
# Fully functional on Razer Blade 2020 and any ACPI0003 AC adapter system.

GRUB_FILE="/etc/default/grub"
PARAM="acpi=noacpi_ac_adapter"

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

# -------------------- Desktop session helpers --------------------

get_desktop_user() {
  if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
    echo "$SUDO_USER"
    return
  fi
  user=$(loginctl list-sessions --no-legend 2>/dev/null | awk 'NR==1{print $3}')
  [ -n "$user" ] && echo "$user" && return
  whoami
}

run_as_desktop_user() {
  local user="$1"; shift
  uid=$(id -u "$user" 2>/dev/null) || return 1
  export XDG_RUNTIME_DIR="/run/user/$uid"
  export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"
  [ -S "${XDG_RUNTIME_DIR}/bus" ] || return 1
  sudo -u "$user" env XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" "$@"
}

disable_desktop_power_notifs() {
  user=$(get_desktop_user)

  if command -v gsettings >/dev/null 2>&1; then
    run_as_desktop_user "$user" gsettings set org.gnome.settings-daemon.plugins.power active false 2>/dev/null && \
    echo "[GNOME] Power notifications disabled for $user."
  fi

  if run_as_desktop_user "$user" systemctl --user status plasma-powerdevil.service >/dev/null 2>&1; then
    run_as_desktop_user "$user" systemctl --user mask plasma-powerdevil.service && \
    echo "[KDE] PowerDevil masked for $user."
  fi
}

enable_desktop_power_notifs() {
  user=$(get_desktop_user)

  if command -v gsettings >/dev/null 2>&1; then
    run_as_desktop_user "$user" gsettings set org.gnome.settings-daemon.plugins.power active true 2>/dev/null && \
    echo "[GNOME] Power notifications restored for $user."
  fi

  if run_as_desktop_user "$user" systemctl --user status plasma-powerdevil.service >/dev/null 2>&1; then
    run_as_desktop_user "$user" systemctl --user unmask plasma-powerdevil.service && \
    echo "[KDE] PowerDevil unmasked for $user."
  fi
}

# -------------------- Kernel param logic --------------------

disable_ac_detect() {
    echo "[INFO] Disabling AC adapter detection..."

    if grep -q "$PARAM" "$GRUB_FILE"; then
        echo -e "${YELLOW}[SKIP]${NC} Already disabled."
    else
        sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"/&$PARAM /" "$GRUB_FILE"
        sudo update-grub
        echo -e "${GREEN}[DONE]${NC} AC detection disabled using kernel parameter."
    fi

    disable_desktop_power_notifs
    echo "Reboot required for changes to take effect."
}

enable_ac_detect() {
    echo "[INFO] Enabling AC adapter detection..."

    if grep -q "$PARAM" "$GRUB_FILE"; then
        sudo sed -i "s/$PARAM//" "$GRUB_FILE"
        sudo update-grub
        echo -e "${GREEN}[DONE]${NC} AC detection enabled."
    else
        echo -e "${YELLOW}[SKIP]${NC} Already enabled."
    fi

    enable_desktop_power_notifs
    echo "Reboot required for changes to take effect."
}

show_status() {
  if grep -q "$PARAM" "$GRUB_FILE"; then
      echo -e "Kernel AC detection: ${RED}DISABLED${NC}"
  else
      echo -e "Kernel AC detection: ${GREEN}ENABLED${NC}"
  fi
}

show_help() {
cat << EOF
${YELLOW}Usage:${NC}
  sudo toggle-ac-detect.sh [option]

Options:
  -d, --disable     Disable AC adapter detection
  -e, --enable      Enable AC adapter detection
  -s, --status      Show status
  -h, --help        Show this help
EOF
}

case "$1" in
    -d|--disable) disable_ac_detect ;;
    -e|--enable) enable_ac_detect ;;
    -s|--status) show_status ;;
    -h|--help|"") show_help ;;
    *) echo "Unknown option: $1"; exit 1 ;;
esac

