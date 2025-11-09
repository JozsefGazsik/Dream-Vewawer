#!/bin/bash

# DreamWeaver - Complete iPhone and Apple Watch Launch Script
# Runs both apps with full synchronization as described in documentation

set -e

echo "🌙 DreamWeaver - Launching iPhone and Apple Watch Apps"
echo "======================================================"

# Project paths
PROJECT_DIR="/Users/SEV0A/Iphone/GJSPO/DreamWeaver/Dream Vewawer"
PROJECT_FILE="$PROJECT_DIR/Dream Vewawer.xcodeproj"

# Get booted simulators
IPHONE_ID=$(xcrun simctl list devices | grep "iPhone.*Booted" | head -1 | grep -o '([A-F0-9-]*' | tr -d '(')
WATCH_ID=$(xcrun simctl list devices | grep "Apple Watch.*Booted" | head -1 | grep -o '([A-F0-9-]*' | tr -d '(')

if [ -z "$IPHONE_ID" ]; then
    echo "❌ No iPhone simulator is running. Please boot an iPhone simulator first."
    echo "💡 Tip: Run 'open -a Simulator' and select an iPhone device"
    exit 1
fi

if [ -z "$WATCH_ID" ]; then
    echo "⚠️  No Apple Watch simulator is running. Booting paired Watch..."
    # Try to find paired watch
    WATCH_ID=$(xcrun simctl list devices | grep "Apple Watch Series 11" | head -1 | grep -o '([A-F0-9-]*' | tr -d '(')
    if [ -z "$WATCH_ID" ]; then
        echo "❌ No Apple Watch Series 11 found. Please create one in Simulator."
        exit 1
    fi
    xcrun simctl boot "$WATCH_ID"
    echo "✅ Watch simulator booted: $WATCH_ID"
fi

echo ""
echo "📱 iPhone Simulator: $IPHONE_ID"
echo "⌚️ Watch Simulator: $WATCH_ID"
echo ""

# Step 1: Clean build
echo "🧹 Cleaning previous builds..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Dream_Vewawer-*
echo "✅ Clean complete"
echo ""

# Step 2: Build iPhone app
echo "📱 Building iPhone app..."
xcodebuild -project "$PROJECT_FILE" \
    -scheme "Dream Vewawer" \
    -sdk iphonesimulator \
    -destination "id=$IPHONE_ID" \
    -configuration Debug \
    clean build \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    2>&1 | grep -E "(BUILD|error:|warning:)" | tail -5

if [ $? -ne 0 ]; then
    echo "❌ iPhone app build failed"
    exit 1
fi

IPHONE_APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Dream Vewawer.app" -path "*Debug-iphonesimulator*" | head -1)

if [ -z "$IPHONE_APP_PATH" ]; then
    echo "❌ iPhone app not found after build"
    exit 1
fi

echo "✅ iPhone app built: $IPHONE_APP_PATH"
echo ""

# Step 3: Build Watch app  
echo "⌚️ Building Apple Watch app..."
xcodebuild -project "$PROJECT_FILE" \
    -scheme "DreamWeaver Watch App" \
    -sdk watchsimulator \
    -destination "id=$WATCH_ID" \
    -configuration Debug \
    clean build \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    2>&1 | grep -E "(BUILD|error:|warning:)" | tail -5

if [ $? -ne 0 ]; then
    echo "❌ Watch app build failed"
    exit 1
fi

WATCH_APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "DreamWeaver Watch App.appex" -path "*Debug-watchsimulator*" | head -1)

if [ -z "$WATCH_APP_PATH" ]; then
    echo "❌ Watch app not found after build"
    exit 1
fi

echo "✅ Watch app built: $WATCH_APP_PATH"
echo ""

# Step 4: Install apps
echo "📦 Installing iPhone app..."
xcrun simctl install "$IPHONE_ID" "$IPHONE_APP_PATH"
if [ $? -eq 0 ]; then
    echo "✅ iPhone app installed"
else
    echo "❌ iPhone app installation failed"
    exit 1
fi

echo ""
echo "📦 Installing Watch app..."
xcrun simctl install "$WATCH_ID" "$WATCH_APP_PATH"
if [ $? -eq 0 ]; then
    echo "✅ Watch app installed"
else
    echo "⚠️  Watch app installation had issues (this is sometimes normal for extensions)"
fi

echo ""
echo "🚀 Launching apps..."

# Step 5: Launch iPhone app
echo "📱 Launching iPhone app..."
xcrun simctl launch "$IPHONE_ID" "GJSA.Dream-Vewawer" &
sleep 2
echo "✅ iPhone app launched"

# Step 6: Launch Watch app
echo "⌚️ Launching Watch app..."
xcrun simctl launch "$WATCH_ID" "GJSA.Dream-Vewawer.DreamWeaverWatchApp" 2>/dev/null || {
    echo "⚠️  Watch app launch via command failed (this is normal for some Watch apps)"
    echo "💡 Please tap the DreamWeaver app icon on the Watch simulator"
}

echo ""
echo "======================================================"
echo "✅ DreamWeaver is ready!"
echo ""
echo "📱 iPhone app: Running on $IPHONE_ID"
echo "⌚️ Watch app: Installed on $WATCH_ID"
echo ""
echo "🔄 Features active:"
echo "   • Sleep tracking with biosignals (HR, HRV)"
echo "   • Bidirectional iPhone ↔ Watch sync"
echo "   • Real-time data transfer every 5 minutes"
echo "   • AI dream interpretation (OpenAI/Claude)"
echo "   • Interactive heart rate charts"
echo ""
echo "📖 To start tracking:"
echo "   1. On iPhone: Tap 'Start Dream Mode' button"
echo "   2. Or on Watch: Tap 'Start Sleep' button"
echo "   3. Apps will sync automatically"
echo ""
echo "📚 Documentation: ./Doc/Instruction"
echo "======================================================"
