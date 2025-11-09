#!/bin/bash

# Apple Watch App Telepítő - EGYSZERŰ VERZIÓ
# Csak a Watch appot telepíti a bootolt Watch-ra

set -e

echo "⌚️ WATCH APP TELEPÍTÉS"
echo "====================="

PROJECT_DIR="/Users/SEV0A/Iphone/GJSPO/DreamWeaver/Dream Vewawer"
cd "$PROJECT_DIR"

# A bootolt Watch ID
WATCH_ID="576BCE80-F430-44C8-B1F6-A5068B3995FE"

echo "⌚️ Apple Watch: $WATCH_ID"

# 1. Clean build
echo "🧹 Törlöm az előző buildeket..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Dream_Vewawer-*

# 2. Watch app build - HELYES SCHEME NÉVVEL
echo "⌚️ Watch App build..."
xcodebuild \
    -project "Dream Vewawer.xcodeproj" \
    -scheme "DreamWeaverWatch" \
    -destination "id=$WATCH_ID" \
    -sdk watchsimulator \
    -configuration Debug \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

if [ $? -ne 0 ]; then
    echo "❌ Watch app build FAILED!"
    exit 1
fi

echo "✅ Watch app build SUCCESS!"

# 3. App keresése
WATCH_APP=$(find ~/Library/Developer/Xcode/DerivedData -name "*.appex" -path "*watchsimulator*" | head -1)

if [ -z "$WATCH_APP" ]; then
    echo "❌ Watch .appex file nem található!"
    exit 1
fi

echo "📦 Watch app: $WATCH_APP"

# 4. Telepítés
echo "📦 Telepítés Watch-ra..."
xcrun simctl install "$WATCH_ID" "$WATCH_APP"

if [ $? -eq 0 ]; then
    echo "✅ TELEPÍTÉS SIKERES!"
    echo ""
    echo "🎉 A DreamWeaver app most már látható a Watch-on!"
    echo "💜 Keress egy lila hold ikont a Watch home screen-en"
    echo ""
    echo "🔄 Funkciók:"
    echo "   • Pulzus mérés"
    echo "   • Légzés követés" 
    echo "   • iPhone szinkronizáció"
    echo "   • Alvás tracking"
else
    echo "❌ Telepítés FAILED!"
    exit 1
fi