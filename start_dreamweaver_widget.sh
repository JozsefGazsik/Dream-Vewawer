#!/bin/bash

echo "🌙 DreamWeaver App Launch Script - Updated for Widget Configuration"
echo "================================================================="
echo ""

echo "📱 Starting iPhone Simulator..."
xcrun simctl boot F7BCCE4F-8C56-4C92-8878-3BBE2F169FD3 2>/dev/null || true
sleep 2

echo "⌚ Starting Apple Watch Simulator..."  
xcrun simctl boot 563D5769-B30E-4E56-8B7D-21FDFC9F9BBE 2>/dev/null || true
sleep 3

echo "🚀 Launching iPhone App..."
xcrun simctl launch F7BCCE4F-8C56-4C92-8878-3BBE2F169FD3 GJSA.Dream-Vewawer

echo "🔧 Attempting to launch Watch Widget..."
WIDGET_PID=$(xcrun simctl launch --console 563D5769-B30E-4E56-8B7D-21FDFC9F9BBE GJSA.Dream-Vewawer.DreamWeaverWatchApp 2>&1)
echo "Widget launch result: $WIDGET_PID"

echo ""
echo "🎯 IMPORTANT: How to Access Your DreamWeaver Watch App"
echo "======================================================"
echo ""
echo "The Watch app is now installed as a WIDGET instead of a regular app."
echo "This means it won't appear on the Watch home screen like normal apps."
echo ""
echo "📍 TO FIND AND USE YOUR DREAMWEAVER WATCH APP:"
echo ""
echo "1. 📱 ON YOUR iPhone SIMULATOR:"
echo "   • The iPhone app should now be running automatically"
echo "   • You can use it normally for dream tracking and visualization"
echo ""
echo "2. ⌚ ON YOUR Apple Watch SIMULATOR:"
echo "   • The app is installed as a WIDGET, not a regular app"
echo "   • Look for it in the WIDGETS section:"
echo ""
echo "   METHOD A - Smart Stack/Widget Gallery:"
echo "   • Swipe up from the bottom of the Watch face"
echo "   • Look for the 🌙 DreamWeaver widget"
echo "   • Tap on it to interact"
echo ""
echo "   METHOD B - Control Center/Dock:"
echo "   • Press and hold the Digital Crown"
echo "   • Look for DreamWeaver in the app list"
echo "   • Or swipe up from bottom for Control Center"
echo ""
echo "   METHOD C - Watch Face Complications:"
echo "   • Long press on the Watch face"
echo "   • Edit complications"
echo "   • Add DreamWeaver widget as a complication"
echo ""
echo "🔍 TROUBLESHOOTING:"
echo "• If you can't find the widget, try restarting both simulators"
echo "• Widget should show: 🌙 DREAM with 'TAP TO START' text"
echo "• Widget has yellow moon icon and orange/green status text"
echo ""
echo "✨ FEATURES:"
echo "• iPhone: Full dream tracking, AI interpretation, history"
echo "• Watch Widget: Quick start/stop dream tracking"
echo "• Real-time sync between devices via WatchConnectivity"
echo ""
echo "Simulators are ready! Check the Watch for widgets in Smart Stack."
echo "Widget apps appear in different locations than regular Watch apps."
