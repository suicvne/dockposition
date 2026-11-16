#!/bin/bash
set -e

# Set directory to install dir specified from install script
cd "$(dirname "$0")"

# Setup vars for the install script
LABEL="xyz.ignoresolutions.dockposition.LaunchAgent"
BIN="$HOME/.local/bin/dockposition"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
DOMAIN="gui/$(id -u)"

# Make dirs we need:
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/Library/LaunchAgents"

# Unregister existing instances:
launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true

# Compile, copy executable:
swift build -c release
install -m 755 \
    "$(swift build -c release --show-bin-path)/DockPosition" \
    "$BIN"

# Generate the launch agent:
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$BIN</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

# Register:
launchctl bootstrap "$DOMAIN" "$PLIST"
echo "DockPosition installed."