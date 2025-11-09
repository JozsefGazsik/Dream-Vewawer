# DreamWeaver Watch App Solution

## Problem
The Watch app cannot run because:
1. Xcode 26.1 has a bug with `watchapp2` product type (CopyAndPreserveArchs error)
2. Using `.appex` (extension) instead doesn't work because:
   - Extensions cannot run standalone on Watch
   - WatchConnectivity doesn't recognize `.appex` as an installed Watch app
   - The iPhone app shows "Watch App Not Installed" even when it's installed

## Root Cause
Apple Watch apps require a specific bundle structure:
- **MyWatchApp.app** (container)
  - **PlugIns/**
    - **MyWatchAppExtension.appex** (the actual extension with code)

The current project only has the `.appex` without the `.app` container.

## Solution: Use Xcode GUI

Since the Xcode 26.1 command-line tools have the CopyAndPreserveArchs bug, you must use Xcode GUI:

### Steps:

1. **Open Xcode**
   - Project is already open

2. **Select the DreamWeaverWatch scheme**
   - Click the scheme dropdown at the top
   - Select "DreamWeaverWatch"

3. **Select Watch Simulator as destination**
   - Select "Apple Watch Series 11 (46mm)" from the destination dropdown

4. **Run the Watch app** (Cmd+R)
   - This will build and launch the Watch app properly
   - Keep it running

5. **Switch to iPhone scheme**
   - Select "Dream Vewawer" scheme
   - Select "iPhone 16e" as destination

6. **Run the iPhone app** (Cmd+R)
   - Both apps will now be running
   - WatchConnectivity should recognize the Watch app

### Why This Works
When you run from Xcode GUI, it:
- Uses internal build methods that avoid the CopyAndPreserveArchs bug
- Properly launches the Watch app and keeps it running
- Registers the app with WatchConnectivity framework
- Maintains the debugging connection

## Alternative: Wait for Xcode Update
Apple will likely fix the CopyAndPreserveArchs bug in a future Xcode update.

## Testing
Once both apps are running:
1. On iPhone: Open Sleep Tracking view
2. Should see "Watch App Connected" instead of "Not Installed"
3. Press "Start Dream Mode"
4. Watch app should receive the command and start tracking
5. Heart rate data should sync every 5 minutes
