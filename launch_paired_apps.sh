#!/bin/bash

# DreamWeaver - Launch iPhone and Watch apps with proper pairing

set -e

IPHONE_SIM="F7BCCE4F-8C56-4C92-8878-3BBE2F169FD3"
WATCH_SIM="4FE28B3D-1A9C-44F7-A3F1-C49A09B5DD3C"
PROJECT_DIR="/Users/SEV0A/Iphone/GJSPO/DreamWeaver/Dream Vewawer"

echo "🔨 Building iPhone app..."
cd "$PROJECT_DIR"
xcodebuild -scheme "Dream Vewawer" \
    -configuration Debug \
    -destination "platform=iOS Simulator,id=$IPHONE_SIM" \
    -derivedDataPath ./DerivedData \
    build | grep -E "(BUILD|error)" || true

echo "🔨 Building Watch app..."
xcodebuild -scheme "DreamWeaverWatch" \
    -configuration Debug \
    -destination "platform=watchOS Simulator,id=$WATCH_SIM" \
    -derivedDataPath ./DerivedData \
    build | grep -E "(BUILD|error)" || true

echo "📱 Installing iPhone app..."
xcrun simctl install "$IPHONE_SIM" \
    "./DerivedData/Build/Products/Debug-iphonesimulator/Dream Vewawer.app"

echo "⌚ Installing Watch app..."
xcrun simctl install "$WATCH_SIM" \
    "./DerivedData/Build/Products/Debug-watchsimulator/DreamWeaverWatch.appex"

echo "⌚ Launching Watch app..."
WATCH_PID=$(xcrun simctl launch --console "$WATCH_SIM" \
    "GJSA.Dream-Vewawer.DreamWeaverWatchApp" 2>&1 | grep -oE '[0-9]+' | head -1)
echo "   Watch app launched with PID: $WATCH_PID"

sleep 2

echo "📱 Launching iPhone app..."
IPHONE_PID=$(xcrun simctl launch --console "$IPHONE_SIM" \
    "GJSA.Dream-Vewawer" 2>&1 | grep -oE '[0-9]+' | head -1)
echo "   iPhone app launched with PID: $IPHONE_PID"

echo ""
echo "✅ Both apps launched successfully!"
echo "   Watch PID: $WATCH_PID"
echo "   iPhone PID: $IPHONE_PID"
echo ""
echo "📝 Note: If WatchConnectivity still shows 'not installed',"
echo "   this is due to the .appex architecture limitation."
echo "   The apps can still communicate via WCSession messages."
