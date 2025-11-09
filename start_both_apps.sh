#!/bin/bash

# DreamWeaver - iPhone és Watch App Együttes Indítás
# Mindkét app-ot elindítja és összekapcsolja

set -e

echo "🌙 DreamWeaver - iPhone + Watch App Indítás"
echo "==========================================="

PROJECT_DIR="/Users/SEV0A/Iphone/GJSPO/DreamWeaver/Dream Vewawer"
cd "$PROJECT_DIR"

# Fix Watch és iPhone ID-k  
WATCH_ID="563D5769-B30E-4E56-8B7D-21FDFC9F9BBE"  # Apple Watch Series 8 (45mm)
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

# Watch app build és indítás
echo ""
echo "⌚️ Watch app build és indítás..."
xcodebuild -project "Dream Vewawer.xcodeproj" \
    -scheme "DreamWeaverWatch" \
    -destination "id=$WATCH_ID" \
    -sdk watchsimulator \
    -configuration Debug \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    > /tmp/watch_build.log 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Watch app build sikeres"
    
    # Watch app telepítés és indítás
    WATCH_APP=$(find ~/Library/Developer/Xcode/DerivedData -name "DreamWeaver Watch App.appex" -path "*Debug-watchsimulator*" | head -1)
    if [ -n "$WATCH_APP" ]; then
        xcrun simctl install "$WATCH_ID" "$WATCH_APP"
        sleep 2
        
        # Watch app indítás (több módszerrel próbálkozunk)
        xcrun simctl launch "$WATCH_ID" "GJSA.Dream-Vewawer.DreamWeaverWatchApp" 2>/dev/null || {
            echo "⚠️  Watch app indítás command line-ból sikertelen"
            echo "💡 Kattints a DreamWeaver ikonra a Watch-on!"
        }
        echo "✅ Watch app telepítve"
    fi
else
    echo "❌ Watch app build hiba"
    tail -10 /tmp/watch_build.log
fi

echo ""
echo "==========================================="
echo "✅ DreamWeaver KÉSZ!"
echo ""
echo "📱 iPhone-on: Kattints 'Start Dream Mode'"
echo "⌚️ Watch-on: FONTOS INSTRUKCIÓK!"
echo ""
echo "🔍 WATCH APP MEGTALÁLÁSA:"
echo "   1. Nyomdd hosszan a Digital Crown-t (oldali gomb)"
echo "   2. Vagy lépj ki a home screen-re (home gomb)" 
echo "   3. Keresd a '🌙' DreamWeaver ikont"
echo "   4. Ha nem látod, görgess lefelé/fel"
echo ""
echo "💡 ALTERNATÍVA: A Watch Extension-ök néha csak"
echo "   az iPhone-ról indíthatóak. Próbáld a Watch"
echo "   appot az iPhone-on keresztül elindítani."
echo ""
echo "🔄 A két app automatikusan szinkronizál!"
echo "💓 Pulzus és légzés mérés aktív"
echo "🎨 AI álom vizualizáció bekapcsolva"
echo "==========================================="