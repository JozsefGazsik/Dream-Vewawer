#!/bin/bash

# Apple Watch App Telepítő Script
# Ez TÉNYLEGESEN telepíti a Watch appot

set -e

echo "⌚️ Apple Watch App Telepítése..."
echo "================================"

PROJECT_DIR="/Users/SEV0A/Iphone/GJSPO/DreamWeaver/Dream Vewawer"
cd "$PROJECT_DIR"

# Szimulátorok ellenőrzése
echo "📱 Szimulátorok ellenőrzése..."
WATCH_ID=$(xcrun simctl list devices | grep "Apple Watch.*Booted" | head -1 | grep -o '([A-F0-9-]*' | tr -d '(' || echo "")

if [ -z "$WATCH_ID" ]; then
    echo "❌ Nincs Apple Watch szimlátor. Indítom..."
    # Keressük meg a Watch-ot
    WATCH_ID=$(xcrun simctl list devices | grep "Apple Watch Series 11" | head -1 | grep -o '([A-F0-9-]*' | tr -d '(' || echo "")
    
    if [ -z "$WATCH_ID" ]; then
        echo "❌ Nincs Apple Watch Series 11. Létrehozom..."
        # iPhone párosítása keresése
        IPHONE_ID=$(xcrun simctl list devices | grep "iPhone 16e" | head -1 | grep -o '([A-F0-9-]*' | tr -d '(' || echo "")
        
        if [ -z "$IPHONE_ID" ]; then
            echo "❌ iPhone 16e szimlátor sem található!"
            exit 1
        fi
        
        echo "📱 iPhone találva: $IPHONE_ID"
        echo "⌚️ Apple Watch létrehozása és párosítása..."
        
        # Watch létrehozása
        WATCH_ID=$(xcrun simctl create "Apple Watch Series 11 46mm" "com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-11-46mm" "com.apple.CoreSimulator.SimRuntime.watchOS-11-1")
        echo "⌚️ Watch létrehozva: $WATCH_ID"
        
        # Párosítás
        xcrun simctl pair "$WATCH_ID" "$IPHONE_ID"
        echo "🔗 Párosítás kész"
    fi
    
    # Watch bootolása
    xcrun simctl boot "$WATCH_ID"
    echo "✅ Watch elindítva: $WATCH_ID"
    sleep 3
else
    echo "✅ Watch már fut: $WATCH_ID"
fi

echo ""

# 1. TISZTÍTÁS
echo "🧹 Build tisztítása..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Dream_Vewawer-*
xcodebuild clean -project "Dream Vewawer.xcodeproj" -scheme "DreamWeaver Watch App"

# 2. WATCH APP BUILD
echo "⌚️ Watch App build..."
xcodebuild \
    -project "Dream Vewawer.xcodeproj" \
    -scheme "DreamWeaver Watch App" \
    -destination "id=$WATCH_ID" \
    -sdk watchsimulator \
    -configuration Debug \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    PROVISIONING_PROFILE_SPECIFIER=""

if [ $? -ne 0 ]; then
    echo "❌ Watch app build sikertelen!"
    exit 1
fi

echo "✅ Watch app build sikeres"

# 3. TELEPÍTÉS
echo "📦 Watch app keresése..."
WATCH_APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "DreamWeaver Watch App.appex" -path "*Debug-watchsimulator*" | head -1)

if [ -z "$WATCH_APP_PATH" ]; then
    echo "❌ Watch app nem található!"
    exit 1
fi

echo "📍 Watch app talált: $WATCH_APP_PATH"

echo "📦 Telepítés Apple Watch-ra..."
xcrun simctl install "$WATCH_ID" "$WATCH_APP_PATH"

if [ $? -eq 0 ]; then
    echo "✅ Watch app sikeresen telepítve!"
else
    echo "⚠️ Telepítési hiba - próbálom másként..."
    
    # Alternatív módszer: Xcode build and run
    echo "🔄 Xcode-os telepítés..."
    xcodebuild \
        -project "Dream Vewawer.xcodeproj" \
        -scheme "DreamWeaver Watch App" \
        -destination "id=$WATCH_ID" \
        -sdk watchsimulator \
        -configuration Debug \
        install \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO
fi

# 4. ELLENŐRZÉS
echo ""
echo "🔍 Telepített appok ellenőrzése..."
xcrun simctl listapps "$WATCH_ID" | grep -i dream || echo "❌ App nem található a listában"

# 5. INDÍTÁS
echo ""
echo "🚀 Watch app indítása..."
xcrun simctl launch "$WATCH_ID" "GJSA.Dream-Vewawer.DreamWeaverWatchApp" || {
    echo "⚠️ Automatikus indítás nem sikerült"
    echo "💡 Kézzel indítsd el:"
    echo "   1. Nyisd meg a Watch szimulátort"
    echo "   2. Keresd meg a DreamWeaver appot (lila hold ikon)"
    echo "   3. Érintsd meg az ikont"
}

echo ""
echo "================================"
echo "✅ KÉSZ!"
echo ""
echo "⌚️ Watch app telepítve: $WATCH_ID"
echo "🎯 Funkciók:"
echo "   • Pulzusmérés (HealthKit)"
echo "   • Légzésszám mérés"  
echo "   • HRV (szívritmus variabilitás)"
echo "   • Sleep tracking start/stop"
echo "   • iPhone szinkronizáció"
echo ""
echo "📖 Használat:"
echo "   1. Watch-on: 'Start Sleep' gomb"
echo "   2. iPhone-on: automatikus szinkronizáció"
echo "   3. Valós idejű adatátvitel 5 percenként"
echo "================================"