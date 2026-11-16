#!/bin/bash

LABEL="xyz.ignoresolutions.dockposition.LaunchAgent"
BIN="$HOME/.local/bin/dockposition"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

echo launchctl bootout "gui/$(id -u)/$LABEL"

echo rm -f "$PLIST"
echo rm -f "$BIN"