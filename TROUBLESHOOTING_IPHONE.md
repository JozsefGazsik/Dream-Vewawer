# Troubleshooting: Can't See the App on iPhone

## What You Should See on Your iPhone 🎨

When the app launches successfully, your iPhone screen should display:

### Main Dashboard:
```
┌─────────────────────────────┐
│      DreamWeaver            │
├─────────────────────────────┤
│                             │
│         🌙 ⭐               │
│   (Yellow moon icon)        │
│                             │
│ "See What Your Mind Creates"│
│                             │
│ ┌─────────────────────────┐ │
│ │  🛏️ Start Dream Mode   │ │
│ │                         │ │
│ │ Track your sleep and    │ │
│ │ visualize your dreams   │ │
│ │                      ➡️ │ │
│ └─────────────────────────┘ │
│                             │
│ (Purple/blue gradient       │
│  background)                │
│                             │
└─────────────────────────────┘
```

## If You Don't See This:

### Option 1: Check Your iPhone
1. **Pick up your iPhone** (the physical device)
2. The app should be on the screen
3. If the screen is black, **tap the screen** or **press the side button**

### Option 2: App Minimized
1. On iPhone, **swipe up from bottom** (or double-click home button)
2. Look for **DreamWeaver** in the app switcher
3. Tap it to bring it back

### Option 3: App Didn't Launch
If you see an error or the app closed:

1. **On your iPhone**, find the **DreamWeaver app icon** on your home screen
2. **Tap it** to launch manually

### Option 4: Trust Developer Issue
If tapping the icon shows "Untrusted Developer":

1. Go to **Settings** on iPhone
2. Tap **General**
3. Tap **VPN & Device Management** (or "Device Management")
4. Under "Developer App", tap your **email address**
5. Tap **"Trust [Your Email]"**
6. Confirm by tapping **Trust**
7. Go back to home screen and **tap DreamWeaver icon**

### Option 5: Relaunch from Xcode
In Xcode:
1. Click the **Stop button** (■) at the top
2. Click the **Play button** (▶️) again
3. Watch your iPhone - the app should launch

## What to Do Once You See the App:

### Step 1: Start Tracking
Tap the big blue button: **"Start Dream Mode"**

### Step 2: You'll See the Tracking Screen
```
┌─────────────────────────────┐
│     Sleep Tracking          │
├─────────────────────────────┤
│                             │
│         🌙                  │
│    (Big moon icon)          │
│                             │
│  Tracking Your Dreams...    │
│                             │
│      00:00:15               │
│    (Running timer)          │
│                             │
│   ❤️ 65 bpm    🚶 45%      │
│                             │
│                             │
│  ┌────────────────────┐    │
│  │  ⏹ Stop Tracking   │    │
│  └────────────────────┘    │
│                             │
└─────────────────────────────┘
```

### Step 3: Let It Run
- Wait **10-30 seconds** (or longer)
- Watch the heart rate and movement % change
- This simulates sleep tracking

### Step 4: Stop Tracking
- Tap the **red "Stop Tracking" button**
- You'll return to the dashboard

### Step 5: View Your Dream! 🎨
Back on dashboard, you'll see:
```
┌─────────────────────────────┐
│     Last Dream              │
│  (Just now)                 │
│  ┌─────────────────────────┐│
│  │                         ││
│  │  [Colorful gradient]    ││
│  │                         ││
│  │  Calm                   ││
│  │  8h 0m  •  22% REM  ▶️  ││
│  └─────────────────────────┘│
└─────────────────────────────┘
```

### Step 6: Tap to See Full Visualization
- **Tap the dream card**
- You'll see the detail screen with metrics
- Tap **"Play Dream Visualization"**
- Watch the animated dream with particles! ✨

## Still Having Issues?

### Check Console Output in Xcode:
1. In Xcode, click the **console icon** (bottom right)
2. Look for any error messages in red
3. Share them if you need help

### Quick Restart:
1. In Xcode: Press **⌘+.** (Command + Period) to stop
2. Press **⌘+R** to rebuild and run
3. Watch your iPhone for the app to launch

---

**TIP**: Keep your iPhone unlocked while testing so you can see the app immediately!
