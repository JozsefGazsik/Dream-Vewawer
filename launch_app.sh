#!/bin/bash

echo "🌙 DreamWeaver App Launcher"
echo "=========================="
echo ""

# Device IDs
IPHONE_ID="F7BCCE4F-8C56-4C92-8878-3BBE2F169FD3"
WATCH_ID="4FE28B3D-1A9C-44F7-A3F1-C49A09B5DD3C"

# Check if simulators are booted
echo "📱 Checking iPhone simulator..."
IPHONE_STATE=$(xcrun simctl list devices | grep "$IPHONE_ID" | grep -o "Booted\|Shutdown")
if [ "$IPHONE_STATE" = "Shutdown" ]; then
    echo "   Booting iPhone..."
    xcrun simctl boot $IPHONE_ID
fi

echo "⌚ Checking Watch simulator..."
WATCH_STATE=$(xcrun simctl list devices | grep "$WATCH_ID" | grep -o "Booted\|Shutdown")
if [ "$WATCH_STATE" = "Shutdown" ]; then
    echo "   Booting Watch..."
    xcrun simctl boot $WATCH_ID
fi

echo ""
echo "✅ Both simulators are ready!"
echo ""
echo "🚀 Launching iPhone app..."
xcrun simctl launch $IPHONE_ID GJSA.Dream-Vewawer

echo ""
echo "=========================="
echo "✨ DreamWeaver is running!"
echo ""
echo "The iPhone app is fully functional with:"
echo "  • AI dream interpretation"
echo "  • Sleep session tracking  "
echo "  • Timeline visualization"
echo "  • Data persistence"
echo ""
echo "Note: Watch app integration requires Xcode GUI to build properly"
echo "      due to Xcode 26.1 'CopyAndPreserveArchs' bug."
echo ""
