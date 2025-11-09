#!/bin/bash

# DreamWeaver App Launcher Script
# This script builds and launches both iPhone and Watch apps on their respective simulators

set -e

# Configuration
PROJECT_DIR="/Users/SEV0A/Iphone/GJSPO/DreamWeaver/Dream Vewawer"
IPHONE_SIM="F7BCCE4F-8C56-4C92-8878-3BBE2F169FD3"
WATCH_SIM="4FE28B3D-1A9C-44F7-A3F1-C49A09B5DD3C"
IPHONE_BUNDLE="GJSA.Dream-Vewawer"
WATCH_BUNDLE="GJSA.Dream-Vewawer.DreamWeaverWatchApp"

echo "🏗️  Building apps..."

# Build iPhone app
cd "$PROJECT_DIR"
xcodebuild -scheme "Dream Vewawer" \
    -configuration Debug \
    -destination "platform=iOS Simulator,id=$IPHONE_SIM" \
    -quiet || { echo "❌ iPhone app build failed"; exit 1; }

# Build Watch app
xcodebuild -scheme "DreamWeaverWatch" \
    -configuration Debug \
    -destination "platform=watchOS Simulator,id=$WATCH_SIM" \
    -quiet || { echo "❌ Watch app build failed"; exit 1; }

echo "✅ Build complete"

# Kill any existing instances
pkill -f "$WATCH_BUNDLE" 2>/dev/null || true
pkill -f "$IPHONE_BUNDLE" 2>/dev/null || true
sleep 1

echo "🚀 Launching apps..."

# Launch Watch app first (must be running for WatchConnectivity to detect it)
WATCH_PID=$(xcrun simctl launch --console-pty "$WATCH_SIM" "$WATCH_BUNDLE" 2>&1 | cut -d':' -f2 | tr -d ' ')
echo "  📱 Watch app launched (PID: $WATCH_PID)"
sleep 2

# Launch iPhone app
IPHONE_PID=$(xcrun simctl launch --console-pty "$IPHONE_SIM" "$IPHONE_BUNDLE" 2>&1 | cut -d':' -f2 | tr -d ' ')
echo "  📱 iPhone app launched (PID: $IPHONE_PID)"

echo ""
echo "✨ Both apps are running!"
echo "   - Watch app on Apple Watch Series 11"
echo "   - iPhone app on iPhone 16e"
echo ""
echo "💡 The apps should now be able to communicate via WatchConnectivity"
echo ""
echo "To stop apps: pkill -f 'Dream'"
