# DreamWeaver - Quick Start Guide 🌙

## ✅ App Successfully Built!

Your DreamWeaver app is now ready to run on the iPhone simulator!

## 🚀 How to Run

1. **Open in Xcode:**
   - Double-click `Dream Vewawer.xcodeproj` to open in Xcode
   
2. **Select Simulator:**
   - Click on the device selector (top toolbar)
   - Choose any iPhone simulator (iPhone 17 Pro, iPhone 16, etc.)
   
3. **Run the App:**
   - Press **Cmd+R** or click the Play button (▶️)
   - Wait for the simulator to launch and the app to install

## 📱 Using the App

### First Launch
You'll see the **DreamWeaver Dashboard** with:
- A moon icon and tagline "See What Your Mind Creates"
- "Start Dream Mode" button
- Empty dream history

### Start Your First Dream Session
1. Tap **"Start Dream Mode"**
2. You'll see the sleep tracking interface with:
   - A large moon icon
   - Real-time timer
   - Simulated heart rate (bpm)
   - Movement percentage
3. Let it run for 10-30 seconds (simulates sleep tracking)
4. Tap **"Stop Tracking"**

### View Your Dream Visualization
After stopping:
- You'll return to the dashboard
- Your first dream appears in the "Last Dream" card
- Tap the card to see:
  - Full animated dream visualization
  - Dream mood (peaceful, calm, intense, or chaotic)
  - Sleep metrics (duration, REM%, deep sleep%)
  - Biosignals (heart rate, HRV, movement)

### Explore the Visualization
- Tap "Play Dream Visualization" in the detail view
- Watch the animated dream with:
  - Color-coded mood particles
  - Pulsating dream orb
  - Smooth animations based on your "biosignals"

## 🎨 What Makes Each Dream Unique

The app generates dreams based on simulated biosignals:

| Biosignal | Effect on Dream |
|-----------|----------------|
| **Heart Rate Variability (HRV)** | Higher HRV = more peaceful colors |
| **Movement Intensity** | More movement = more particles & chaos |
| **REM Percentage** | Higher REM = more intense dreams |
| **Ambient Noise** | Affects color brightness |

## 🎯 Features Currently Working

✅ Dream visualization with animated particles  
✅ Sleep session tracking (simulated)  
✅ Dream mood classification (4 types)  
✅ Beautiful UI with gradient backgrounds  
✅ Dream history with SwiftData persistence  
✅ Detailed biosignal metrics  
✅ Color-coded dream palettes  

## 🔮 Next Steps for Development

### Phase 1: Real Data Integration
- [ ] Add HealthKit permissions to Info.plist
- [ ] Integrate real heart rate from Apple Watch
- [ ] Add motion tracking using accelerometer
- [ ] Background sleep tracking

### Phase 2: Enhanced Visualizations
- [ ] More complex particle systems
- [ ] SceneKit 3D visualizations
- [ ] Custom shapes based on dream patterns
- [ ] Sound effects and haptic feedback

### Phase 3: Social & Journal Features
- [ ] Dream journal with notes
- [ ] Dream pattern analysis over time
- [ ] Export dream art as video
- [ ] Share to social media

### Phase 4: Apple Watch App
- [ ] Companion Watch app
- [ ] Bedside mode interface
- [ ] Morning summary notification
- [ ] Watch complications

## 📝 Technical Details

**Architecture:**
- SwiftUI for all UI
- SwiftData for persistence
- Combine for reactive updates
- HealthKit integration ready (placeholder)

**Minimum Requirements:**
- iOS 17.0+
- Xcode 15.0+
- iPhone or iPad

**Code Structure:**
```
Dream Vewawer/
  Models/
    SleepData.swift          - Data model
  Views/
    ContentView.swift        - Main dashboard
    SleepTrackingView.swift  - Tracking interface
    DreamVisualizationView.swift - Animation view
    DreamDetailView.swift    - Detail screen
  Services/
    HealthKitManager.swift   - HealthKit wrapper
```

## 🎭 Dream Mood Types

| Mood | Colors | When It Occurs |
|------|--------|---------------|
| **Peaceful** | Blues & Light Blues | Low movement + High HRV |
| **Calm** | Greens & Teals | Balanced biosignals |
| **Intense** | Purples & Magentas | High REM + High movement |
| **Chaotic** | Reds & Oranges | Low HRV + High movement |

## 💡 Tips

- Run multiple sleep sessions to build up your dream history
- Each session generates unique colors and animations
- The visualization animates continuously - watch for patterns
- Try different tracking durations to see varied results

## 🐛 Troubleshooting

**App won't build?**
- Make sure you have the latest Xcode
- Clean build folder (Cmd+Shift+K)
- Try a different simulator

**Simulator is slow?**
- Restart the simulator
- Choose a newer device (iPhone 17 Pro)
- Reduce animation complexity if needed

**No dreams appearing?**
- Make sure to stop the tracking session
- Check that SwiftData is working (should auto-save)

---

**Enjoy exploring your dream world! 🌟**

*"Your mind paints while you sleep. DreamWeaver reveals the masterpiece."*
