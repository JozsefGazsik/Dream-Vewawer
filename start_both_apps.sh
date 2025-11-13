#!/bin/bash

# DreamWeaver - iPhone és Watch App Együttes Indítás
# Mindkét app-ot elindítja és összekapcsolja

set -e

echo "🌙 DreamWeaver - iPhone + Watch App Indítás"
echo "==========================================="

PROJECT_DIR="/Users/SEV0A/Iphone/GJSPO/DreamWeaver/Dream Vewawer"
cd "$PROJECT_DIR"

# Fix Watch és iPhone ID-k  
WATCH_ID="FBAC26F7-0661-41E5-98B0-1ACD524AC029"  # Apple Watch SE 3 New (44mm) - watchOS 26.1
IPHONE_ID="F7BCCE4F-8C56-4C92-8878-3BBE2F169FD3"

echo "📱 iPhone ID: $IPHONE_ID"
echo "⌚️ Watch ID: $WATCH_ID"

# Szimulátorok bootolása
echo ""
echo "🚀 Szimulátorok bootolása..."
xcrun simctl boot "$IPHONE_ID" 2>/dev/null || echo "📱 iPhone már fut"
xcrun simctl boot "$WATCH_ID" 2>/dev/null || echo "⌚️ Watch már fut"

sleep 3

# Clean build
echo ""
echo "🧹 Build cache törlése..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Dream_Vewawer-*

# iPhone app build és indítás
echo ""
echo "📱 iPhone app build és indítás..."
xcodebuild -project "Dream Vewawer.xcodeproj" \
    -scheme "Dream Vewawer" \
    -destination "id=$IPHONE_ID" \
    -sdk iphonesimulator \
    -configuration Debug \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    > /tmp/iphone_build.log 2>&1

if [ $? -eq 0 ]; then
    echo "✅ iPhone app build sikeres"
    
    # iPhone app telepítés és indítás
    IPHONE_APP=$(find ~/Library/Developer/Xcode/DerivedData -name "Dream Vewawer.app" -path "*Debug-iphonesimulator*" | head -1)
    if [ -n "$IPHONE_APP" ]; then
        xcrun simctl install "$IPHONE_ID" "$IPHONE_APP"
        xcrun simctl launch "$IPHONE_ID" "GJSA.Dream-Vewawer" &
        echo "✅ iPhone app elindítva"
    fi
else
    echo "❌ iPhone app build hiba"
    tail -10 /tmp/iphone_build.log
fi

sleep 2

###############################################
# Watch tartalmazó iPhone container build
# A watchOS appot a container (watchapp2-container) telepítése
# fogja automatikusan párosítani a Watch szimulátorral.
###############################################
echo ""
echo "🧩 Watch container build (iPhone target + beágyazott Watch)"
CONTAINER_SCHEME="DreamWeaverIphoneAI"
xcodebuild -project "Dream Vewawer.xcodeproj" \
    -scheme "$CONTAINER_SCHEME" \
    -destination "id=$IPHONE_ID" \
    -configuration Debug \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    > /tmp/watch_container_build.log 2>&1 || WATCH_CONTAINER_STATUS=$?

if [ "${WATCH_CONTAINER_STATUS:-0}" -eq 0 ]; then
    echo "✅ Watch container build sikeres"
    CONTAINER_APP=$(find ~/Library/Developer/Xcode/DerivedData -name "DreamWeaverIphoneAI.app" -path "*Debug-iphonesimulator*" | head -1)
    if [ -n "$CONTAINER_APP" ]; then
        echo "📦 Container telepítése iPhone szimulátorra (Watch tartalommal)"
        xcrun simctl install "$IPHONE_ID" "$CONTAINER_APP"
        echo "🚀 Container indítása (watch tartalom auto-települ)"
        xcrun simctl launch "$IPHONE_ID" "GJSA.DreamWeaverIphoneAI" 2>/dev/null || echo "⚠️ Container indítás nem sikerült automatikusan"
        echo "⌚️ Ellenőrzés: Watch app ikon meg kell jelenjen a Watch szimulátoron"
    else
        echo "❌ Nem található a container app (DreamWeaverIphoneAI.app)"
    fi
else
    echo "❌ Watch container build hiba"
    tail -20 /tmp/watch_container_build.log
fi

echo ""
echo "==========================================="
echo "✅ DreamWeaver KÉSZ!"
echo ""
echo "📱 iPhone-on: Kattints 'Start Dream Mode'"
echo "⌚️ Watch-on: FONTOS INSTRUKCIÓK!"
echo ""
echo "🔍 WATCH APP MEGTALÁLÁSA (Container telepítés után):"
echo "   1. Nyomd meg a Digital Crown-t a Home Screen-hez"
echo "   2. Keresd a '🌙' DreamWeaver ikont"
echo "   3. Ha nem jelenik meg, várj 5–10 másodpercet a párosításhoz"
echo "   4. Ha továbbra sem látható: Zárd be és nyisd újra a Watch szimulátort"
echo ""
echo "💡 TIPPEK: A watchOS appot nem közvetlenül kell"
echo "   telepíteni; az iPhone container automatikusan"
echo "   továbbítja a Watch-ra a beágyazott alkalmazást."
echo ""
echo "🔄 A két app automatikusan szinkronizál!"
echo "💓 Pulzus és légzés mérés aktív"
echo "🎨 AI álom vizualizáció bekapcsolva"
echo "==========================================="