# DreamWeaver 🌙✨

**"See What Your Mind Creates"**

DreamWeaver is an iOS app that transforms your sleep data into living art. Using biosignal analysis (heart rate, movement, REM patterns), it generates beautiful, abstract dream visualizations that represent your subconscious state.

## Features

### Current Implementation (v1.0)
- 🎨 **Dream Visualization Engine**: Beautiful, animated dream representations based on biosignals
- 📊 **Sleep Tracking**: Simulated biosignal monitoring (heart rate, HRV, movement, REM phases)
- 📱 **Dream Dashboard**: View your dream history and sleep trends
- 🎯 **Dream Mood Analysis**: Automatic categorization (peaceful, calm, intense, chaotic)
- 🌈 **Dynamic Color Palettes**: Generated based on your sleep characteristics
- 💾 **SwiftData Integration**: Persistent storage of all your sleep sessions

### Coming Soon
- ⌚ **Apple Watch Integration**: Real biosignal tracking from Apple Watch
- 🏥 **HealthKit Integration**: Pull actual heart rate, HRV, and sleep data
- 🤖 **Advanced AI**: ML-based dream pattern recognition
- 📝 **Dream Journal**: Add notes and titles to your dreams
- 📤 **Social Sharing**: Share your dream art with friends
- 📈 **Trend Analysis**: Long-term sleep quality and dream pattern insights

## How to Run

### Requirements
- Xcode 15.0 or later
- iOS 17.0 or later
- iPhone Simulator or physical iPhone

### Quick Start
1. Open `Dream Vewawer.xcodeproj` in Xcode
2. Select your target device (iPhone 15 Pro simulator recommended)
3. Press **Cmd+R** to build and run
4. Explore the app:
   - Tap "Start Dream Mode" to begin a sleep tracking session
   - Let it run for a few seconds (simulated tracking)
   - Stop tracking to generate your first dream visualization
   - View your dream history and explore the animated visualizations

## Architecture

### Models
- **SleepData**: Core data model storing sleep sessions with biosignals
  - Heart rate & HRV
  - Movement intensity
  - REM & deep sleep percentages
  - Ambient noise levels
  - Generated dream characteristics (mood, colors)

### Views
- **ContentView**: Main dashboard with dream history
- **SleepTrackingView**: Sleep session recording interface
- **DreamVisualizationView**: Animated dream playback
- **DreamDetailView**: Detailed sleep metrics and biosignals

### Services
- **HealthKitManager**: Ready for Apple Watch integration (placeholder)

## Dream Generation Algorithm

The app uses a sophisticated algorithm to generate dream characteristics:

```swift
// Dream Mood Calculation
if HRV < 40 && movement > 0.6 → "chaotic"
if HRV > 60 && movement < 0.3 → "peaceful"
if REM > 25% && movement > 0.5 → "intense"
else → "calm"

// Color Palette Selection
peaceful → Blues & Light Blues
chaotic → Reds & Oranges
intense → Purples & Magentas
calm → Greens & Teals
```

## Future Development

### Phase 2: Apple Watch Integration
- Real-time heart rate monitoring during sleep
- Motion detection using accelerometer
- Background processing for all-night tracking

### Phase 3: Advanced AI
- On-device ML model for dream pattern recognition
- Personalized dream style learning
- Predictive sleep quality insights

### Phase 4: Social Features
- Private dream feed
- Dream art gallery
- Anonymous dream sharing

## Technical Stack

- **Language**: Swift 5.9+
- **Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Animations**: SwiftUI Animations, Metal/SceneKit (future)
- **Health Data**: HealthKit (ready for integration)
- **ML**: Core ML (planned)

## Privacy

All sleep data is stored locally on your device. No data is sent to external servers. When Apple Watch integration is added, you'll control what data is collected and it will remain on your device.

## Design Inspiration

Based on research in:
- Sleep stage classification using biosignals
- Convolutional Neural Networks for sleep analysis
- Real-time sleep physiology modulation
- Wearable biosignal monitoring

## License

This is a prototype/concept app for educational purposes.

---

**Built with ❤️ for dreamers everywhere**
