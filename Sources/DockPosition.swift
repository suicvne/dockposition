// DockPosition
// Copyright (c) 2026 Mike Santiago
//
// Modifies dock orientation based on display state.
// The dock orientations are compiled into the executable.
// Change these by modifying gInternalOnlyOrientation and gExternalConnectedOrientation.

// Imports:
import Foundation;
import CoreGraphics;
import OSLog;
import Darwin;

// "Configuration"
let gInternalOnlyOrientation = "left";
let gExternalConnectedOrientation = "bottom";

// Pending update:
var PendingUpdate: DispatchWorkItem?;

// Logging:
let Log = Logger(subsystem: "xyz.ignoresolutions.dockposition.agent", category: "Runtime");

// Darwin signals:
signal(SIGTERM, SIG_IGN);
signal(SIGINT, SIG_IGN);
let TerminationSrc = DispatchSource.makeSignalSource(signal: SIGTERM, queue: .main);
let InterruptionSrc = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main);

// configures dock orientation via automation permission/AppleScript.
// prevents us from having to write via `defaults` and then kill the dock.
func SetDockOrientationFromAppleScript(_ Orientation: String) {
    let Source = """
    tell application "System Events"
       tell dock preferences
          if screen edge is not \(Orientation) then
             set screen edge to \(Orientation)
          end if
       end tell
    end tell
    """;

    Log.info("Changing dock orientation to \(Orientation)");

    var Error: NSDictionary?;
    NSAppleScript(source: Source)?.executeAndReturnError(&Error);

    if let Error = Error {
        Log.error("Failed to set Dock Orientation through AppleScript. Reason: \(Error)");
    }
}

func Execute(_ executable: String, _ arguments: [String]) -> Bool {
    // spawn sub process.
    let SelfProc = Process();
    SelfProc.executableURL = URL(fileURLWithPath: executable);
    SelfProc.arguments = arguments;

    do {
        try SelfProc.run();
        SelfProc.waitUntilExit();
        return SelfProc.terminationStatus == 0;
    } catch { return false; }
}

func UpdateDock() {
    // 32 length array for storage of our CGGetOnlineDisplayList call.
    var Displays = [CGDirectDisplayID](repeating: 0, count: 32);
    var DisplayCount: UInt32 = 0;

    guard CGGetOnlineDisplayList(UInt32(Displays.count), 
        &Displays, &DisplayCount) == .success else 
    {
        // failed to get list of online displays.
        return;
    }

    // Check if there's an external display connected.
    let HasExternal = Displays.prefix(Int(DisplayCount)).contains {
        CGDisplayIsBuiltin($0) == 0
    };

    // Check preferred and current orientations
    let DockOrientation = HasExternal ? gExternalConnectedOrientation : gInternalOnlyOrientation;
    SetDockOrientationFromAppleScript(DockOrientation);

    /*
    let Current = 
        UserDefaults.standard
        .persistentDomain(forName: "com.apple.dock")?["orientation"] as? String ?? gExternalConnectedOrientation;
    
    // Guard: Ensure that we're not trying to change to orientation we already are in.
    guard Current != DockOrientation else { return; }

    // Modify defaults and then kill dock:
    if Execute("/usr/bin/defaults", [
        "write", "com.apple.dock", "orientation", "-string", DockOrientation
    ]) {
        // kill dock after so it takes effect:
        _ = Execute("/usr/bin/killall", ["Dock"]);
    }
    */
}

// Schedules the update after the display changes.
func ScheduleUpdate() {
    PendingUpdate?.cancel();

    PendingUpdate = DispatchWorkItem {
        UpdateDock();
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: PendingUpdate!);
}

// ============================= Main ============================= 

// Signals:
func Shutdown() {
    Log.info("DockPosition agent: shutting down");
    PendingUpdate?.cancel();
    exit(EXIT_SUCCESS);
}
TerminationSrc.setEventHandler(handler: Shutdown);
InterruptionSrc.setEventHandler(handler: Shutdown);
TerminationSrc.resume();
InterruptionSrc.resume();

// Setup the reconfiguration callback:
let Result = CGDisplayRegisterReconfigurationCallback({
    _, flags, _ in

    // Can't be in beginning stages of display reconfiguration.
    guard !flags.contains(.beginConfigurationFlag) else {
        return;
    }

    // Schedule an update on main thread:
    DispatchQueue.main.async { ScheduleUpdate(); }

}, nil);

// Ensure reconfiguration callback registration was a success:
guard Result == .success else {
    fatalError("Unable to register display callback");
}

// Update the dock and then run the main loop.
// Persists this application.
Log.info("Starting DockPosition agent");
UpdateDock();
RunLoop.main.run();

// ============================= Main ============================= 