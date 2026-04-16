#!/usr/bin/env bash
set -euo pipefail

ENABLE_NOW=1
RUN_NOW=0

for arg in "$@"; do
    case "$arg" in
        --no-enable)
            ENABLE_NOW=0
            ;;
        --run-now)
            RUN_NOW=1
            ;;
        -h|--help)
            cat <<'EOF'
Usage: setup.sh [--no-enable] [--run-now]

Installs battery alert scripts and systemd user units:
  - ~/.config/battery-notify/check.sh
  - ~/.config/systemd/user/battery-notify.service
  - ~/.config/systemd/user/battery-notify.timer

Options:
  --no-enable   Do not enable/start the timer automatically.
  --run-now     Run one battery check after installation.
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            exit 1
            ;;
    esac
done

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BATTERY_DIR="$CONFIG_HOME/battery-notify"
SYSTEMD_USER_DIR="$CONFIG_HOME/systemd/user"

CHECK_SCRIPT="$BATTERY_DIR/check.sh"
SERVICE_FILE="$SYSTEMD_USER_DIR/battery-notify.service"
TIMER_FILE="$SYSTEMD_USER_DIR/battery-notify.timer"

mkdir -p "$BATTERY_DIR" "$SYSTEMD_USER_DIR"

cat >"$CHECK_SCRIPT" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/battery-notify"
STATE_FILE="$CONFIG_DIR/.state"

LOW_THRESHOLD="${LOW_THRESHOLD:-20}"
CRITICAL_THRESHOLD="${CRITICAL_THRESHOLD:-10}"
FULL_THRESHOLD="${FULL_THRESHOLD:-98}"
RESET_FULL_THRESHOLD="${RESET_FULL_THRESHOLD:-95}"

notify_msg() {
    local urgency="$1"
    local title="$2"
    local body="$3"

    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u "$urgency" "$title" "$body" && return 0
    fi

    if [ "${USE_ROFI_FALLBACK:-0}" = "1" ] && command -v rofi >/dev/null 2>&1; then
        rofi -theme "$HOME/.config/rofi/rounded.rasi" -e "$title: $body" || true
    fi
}

mkdir -p "$CONFIG_DIR"

normalize_status() {
    case "$1" in
        Discharging|discharging) echo "Discharging" ;;
        Charging|charging|pending-charge) echo "Charging" ;;
        Full|full|fully-charged) echo "Full" ;;
        *) echo "$1" ;;
    esac
}

read_battery_from_sysfs() {
    local battery_path
    battery_path="$(find /sys/class/power_supply -maxdepth 1 -type d -name 'BAT*' | head -n1)"
    if [ -z "${battery_path:-}" ]; then
        return 1
    fi

    capacity="$(cat "$battery_path/capacity" 2>/dev/null || echo "")"
    status="$(cat "$battery_path/status" 2>/dev/null || echo "")"
    return 0
}

read_battery_from_upower() {
    local device
    device="$(upower -e 2>/dev/null | awk '/battery/ {print; exit}')"
    if [ -z "${device:-}" ]; then
        return 1
    fi

    local info
    info="$(upower -i "$device" 2>/dev/null || true)"
    capacity="$(printf '%s\n' "$info" | awk -F: '/percentage/ {gsub(/[%[:space:]]/, "", $2); print $2; exit}')"
    status="$(printf '%s\n' "$info" | awk -F: '/state/ {gsub(/^[[:space:]]+/, "", $2); print $2; exit}')"
    return 0
}

capacity=""
status=""
if ! read_battery_from_sysfs; then
    if command -v upower >/dev/null 2>&1; then
        read_battery_from_upower || exit 0
    else
        exit 0
    fi
fi
status="$(normalize_status "$status")"

if [ -z "$capacity" ] || ! [[ "$capacity" =~ ^[0-9]+$ ]]; then
    exit 0
fi

last_state="none"
if [ -f "$STATE_FILE" ]; then
    last_state="$(cat "$STATE_FILE" 2>/dev/null || echo "none")"
fi

new_state="$last_state"

if [ "$status" = "Discharging" ]; then
    if [ "$capacity" -le "$CRITICAL_THRESHOLD" ]; then
        if [ "$last_state" != "critical" ]; then
            notify_msg critical "Battery critical" "${capacity}% remaining. Plug in now."
        fi
        new_state="critical"
    elif [ "$capacity" -le "$LOW_THRESHOLD" ]; then
        if [ "$last_state" != "low" ] && [ "$last_state" != "critical" ]; then
            notify_msg normal "Battery low" "${capacity}% remaining."
        fi
        new_state="low"
    else
        new_state="none"
    fi
elif [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
    if [ "$capacity" -ge "$FULL_THRESHOLD" ]; then
        if [ "$last_state" != "full" ]; then
            notify_msg low "Battery charged" "Battery is at ${capacity}%."
        fi
        new_state="full"
    elif [ "$capacity" -lt "$RESET_FULL_THRESHOLD" ]; then
        new_state="none"
    fi
fi

printf '%s\n' "$new_state" >"$STATE_FILE"
EOF

cat >"$SERVICE_FILE" <<'EOF'
[Unit]
Description=Battery level checker with desktop notifications

[Service]
Type=oneshot
ExecStart=%h/.config/battery-notify/check.sh
EOF

cat >"$TIMER_FILE" <<'EOF'
[Unit]
Description=Run battery checker every minute

[Timer]
OnBootSec=30
OnUnitActiveSec=60

[Install]
WantedBy=timers.target
EOF

chmod +x "$CHECK_SCRIPT"

if ! command -v notify-send >/dev/null 2>&1; then
    echo "Warning: notify-send not found. Install libnotify (Arch: sudo pacman -S --needed libnotify)." >&2
fi

if [ "$ENABLE_NOW" -eq 1 ]; then
    if command -v systemctl >/dev/null 2>&1; then
        if systemctl --user daemon-reload \
            && systemctl --user enable --now battery-notify.timer; then
            echo "Timer enabled: battery-notify.timer"
        else
            echo "Could not enable timer automatically in this session." >&2
            echo "Run manually:" >&2
            echo "  systemctl --user daemon-reload" >&2
            echo "  systemctl --user enable --now battery-notify.timer" >&2
        fi
    else
        echo "systemctl not found. Enable the timer manually if you use systemd user services." >&2
    fi
fi

if [ "$RUN_NOW" -eq 1 ]; then
    "$CHECK_SCRIPT"
    echo "Ran one battery check."
fi

cat <<EOF
Installed:
  $CHECK_SCRIPT
  $SERVICE_FILE
  $TIMER_FILE
EOF
