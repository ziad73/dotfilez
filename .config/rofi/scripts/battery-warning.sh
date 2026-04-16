#!/bin/bash

capacity="$1"

rofi -theme "~/.config/rofi/rounded.rasi" \
    -e "⚠️  Battery Low: ${capacity}%"
