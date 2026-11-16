# dockposition

`dockposition` is a macOS userspace agent that listens for CoreGraphics display reconfiguration notifications and repositions Dock.app accordingly.

I made this because I move my MacBook Pro between docked/undocked states. When docked, my left oriented dock remains stuck to a single display. I end up having to manually change the orientation to "bottom" and then having to change it back when I'm done. 

## Behavior
The agent synchronizes the dock position as follows, by default, based on the following configurations:

* Internal display only -> `left`
* External display connected -> `bottom`
* Clamshell mode -> `bottom`

## Requirements
Requires macOS 13 or higher.
Requires Swift 5.9 or higher.

## Configuration
There is no formal "configuration" for this application. Instead, there are two `let` variables in `DockPosition.swift` that allow you to dictate the orientations chosen:

* `gInternalOnlyOrientation` defaults to `"left"`
* `gExternalConnectedOrientation` defaults to `"bottom"`

## Permissions
The only permission required is the "System Automation" permission. This is because we use AppleScript to change the Dock's orientation in real time instead of using the old `defaults write` method paired with `killall Dock`. You should only need to grant this permission once when the application first launches.

## Installation
To install, you must first build the agent from source. This practice is automated via the `install.sh` script. Feel free to inspect this script prior to execution, but it performs the following steps for you:

* Builds the application through `swift` for release configuration. 
* Installs the built executable to `~/.local/bin`. 
* Generates a LaunchAgent plist file and places it into `~/Library/LaunchAgents/xyz.ignoresolutions.dockposition.LaunchAgent.plist`.
* Consults `launchctl` to start the launch agent.
    * The application is now installed, will be launched, and will subsequently launch on login.

## Uninstall
To uninstall, run the `uninstall.sh` script. This script unregisters the generated LaunchAgent via `launchctl`, removes the plist file, and removes the built executable.

## Troubleshooting
Check if the agent is running:

```
launchctl print gui/$(id -u)/xyz.ignoresolutions.dockposition.LaunchAgent
```

Monitor logs from the userspace agent:
```
log stream --predicate 'subsystem == "xyz.ignoresolutions.dockposition"'
```

## License

`dockposition` is licensed under the MIT License.
See [LICENSE](LICENSE) for details.