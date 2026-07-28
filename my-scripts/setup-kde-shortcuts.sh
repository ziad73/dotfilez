#!/bin/bash
# Apply KDE Plasma shortcuts (like i3wm)

# Meta+Q = Close current window
kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Window Close" "Meta+Q,Alt+F4,Close Window"

# Meta+P = Show logout/shutdown/suspend menu
kwriteconfig6 --file kglobalshortcutsrc --group ksmserver --key "Log Out" "Meta+P,Ctrl+Alt+Del,Show Logout Screen"

# Move Activity Switcher to Meta+Ctrl+Q (frees Meta+Q for close)
kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "manage activities" "Meta+Ctrl+Q,Meta+Ctrl+Q,Show Activity Switcher"

# Reload
kquitapp6 kglobalaccel 2>/dev/null
sleep 1
kglobalaccel6 &>/dev/null & disown

echo "KDE shortcuts applied:"
echo "  Meta+Q → Close window"
echo "  Meta+P → Power options"
echo "  Meta+Ctrl+Q → Activity Switcher"
