#!/bin/bash

LABEL="xyz.ignoresolutions.dockposition.LaunchAgent"
BIN="$HOME/.local/bin/dockposition"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

launchctl bootout "gui/$(id -u)/$LABEL"

rm -f "$PLIST"
rm -f "$BIN"