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
