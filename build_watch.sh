#!/bin/bash

# Clean build folder
rm -rf ~/Library/Developer/Xcode/DerivedData/Dream_Vewawer-*

# Build with workaround for CopyAndPreserveArchs bug
xcodebuild \
  -scheme "DreamWeaver Watch App" \
  -destination 'platform=watchOS Simulator,id=4FE28B3D-1A9C-44F7-A3F1-C49A09B5DD3C' \
  -configuration Debug \
  build \
  VALIDATE_WORKSPACE=NO \
  ONLY_ACTIVE_ARCH=YES \
  ENABLE_BITCODE=NO

if [ $? -eq 0 ]; then
    echo "✅ Build succeeded!"
    
    # Find the built app
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "DreamWeaver Watch App.app" -o -name "DreamWeaver Watch App.appex" | head -1)
    
    if [ -n "$APP_PATH" ]; then
        echo "📦 Found app at: $APP_PATH"
        
        # Install to Watch simulator
        echo "📲 Installing to Watch..."
        xcrun simctl install 4FE28B3D-1A9C-44F7-A3F1-C49A09B5DD3C "$APP_PATH"
        
        if [ $? -eq 0 ]; then
            echo "✅ Installation succeeded!"
            echo "🚀 Launching app..."
            xcrun simctl launch 4FE28B3D-1A9C-44F7-A3F1-C49A09B5DD3C GJSA.Dream-Vewawer.DreamWeaverWatchApp
        else
            echo "❌ Installation failed"
        fi
    else
        echo "❌ Could not find built app"
    fi
else
    echo "❌ Build failed"
fi
