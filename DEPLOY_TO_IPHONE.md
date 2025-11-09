# Deploy DreamWeaver to Your Physical iPhone 📱

## Prerequisites

✅ Mac with Xcode installed  
✅ iPhone with USB cable  
✅ Apple ID (free account works!)  
✅ iOS 17.0 or later on your iPhone

---

## Step-by-Step Deployment Guide

### Step 1: Connect Your iPhone

1. **Plug in your iPhone** to your Mac using a USB cable
2. **Unlock your iPhone** (enter passcode)
3. If prompted on iPhone, tap **"Trust This Computer"**
4. Enter your iPhone passcode to confirm trust

---

### Step 2: Open Project in Xcode

1. Navigate to:
   ```
   /Users/SEV0A/Iphone/GJSPO/DreamWeaver/Dream Vewawer/
   ```

2. Double-click **`Dream Vewawer.xcodeproj`** to open in Xcode

---

### Step 3: Select Your iPhone as Target

1. At the top of Xcode, click the **device selector** (next to the Play button)
2. Look for your iPhone name in the list (e.g., "József's iPhone")
3. Select your physical iPhone (it will have your device name)

💡 *Your iPhone should appear automatically if connected and trusted*

---

### Step 4: Configure Signing (One-Time Setup)

1. In Xcode's left sidebar, click the **blue project icon** at the top
2. Select **"Dream Vewawer"** under TARGETS
3. Click the **"Signing & Capabilities"** tab
4. Under **"Signing"**, make these changes:

   **Option A - Using Your Apple ID (Recommended for personal use):**
   
   ✅ Check **"Automatically manage signing"**
   
   In **"Team"** dropdown:
   - If you see your name/Apple ID → Select it ✅
   - If not → Click "Add an Account..."
   
   **To Add Apple ID:**
   - Click **"Add an Account..."**
   - Sign in with your **Apple ID** (iCloud email)
   - Enter your **password**
   - Complete **two-factor authentication** if prompted
   - Your account will now appear in the Team dropdown
   - Select your personal team (it will say "Personal Team")

   **Option B - If you have a paid Apple Developer account:**
   - Select your developer team from the dropdown

5. Xcode will automatically provision your device

⚠️ **Common Issue - Bundle Identifier Conflict:**

If you see an error like "Failed to register bundle identifier":

1. Change the **Bundle Identifier**:
   - Find "Bundle Identifier" field (usually shows: `com.example.Dream-Vewawer`)
   - Change it to something unique, like:
     ```
     com.yourname.DreamVewawer
     ```
     (Replace `yourname` with your actual name or initials)

2. Click outside the field to save
3. Xcode will automatically re-register

---

### Step 5: Trust Developer on iPhone (First Time Only)

⚠️ **IMPORTANT:** After first install, you need to trust yourself as a developer

1. **Build and Run** the app (press **⌘R** or click Play ▶️)
2. Xcode will install the app on your iPhone
3. **On your iPhone:**
   - Open **Settings** app
   - Scroll down and tap **"General"**
   - Tap **"VPN & Device Management"** (or "Device Management")
   - Under **"Developer App"**, tap your **Apple ID email**
   - Tap **"Trust [Your Email]"**
   - Tap **"Trust"** in the popup dialog
   - ✅ You're now trusted!

4. **Go back to your Home Screen** and tap the DreamWeaver app icon

---

### Step 6: Run the App! 🚀

1. In Xcode, press **⌘R** (or click the Play button ▶️)
2. Xcode will:
   - Build the app
   - Install it on your iPhone
   - Launch it automatically
3. The app should open on your iPhone! 🎉

---

## Using DreamWeaver on Your iPhone

### First Use:

1. **Start Dream Mode** - Tap the blue button
2. Place iPhone on nightstand (or just hold it for testing)
3. Let it track for 10-30 seconds (or longer for realistic testing)
4. **Stop Tracking** - Red button
5. **View Your Dream** - Tap on the dream card to see the visualization!

### For Real Sleep Tracking:

1. Charge your iPhone to 100% before bed
2. Place it on your nightstand (screen down to save battery)
3. Start Dream Mode before sleeping
4. The app will simulate biosignals overnight
5. Stop in the morning to see your dream visualization!

---

## Troubleshooting

### ❌ "Could not launch [app name]"

**Solution:**
- Make sure you **trusted the developer** (Step 5 above)
- Check Settings → General → VPN & Device Management

---

### ❌ "Failed to code sign"

**Solutions:**
1. Make sure you're signed in with your Apple ID in Xcode
2. Change the Bundle Identifier to something unique
3. Try toggling "Automatically manage signing" off and back on

---

### ❌ "No devices found"

**Solutions:**
1. Unplug and replug your iPhone
2. Unlock your iPhone
3. Trust the computer again
4. Restart Xcode
5. Check cable (try a different USB port or cable)

---

### ❌ "iOS version too old"

**Solution:**
- Update your iPhone to iOS 17.0 or later
- Settings → General → Software Update

---

### ❌ App crashes on launch

**Solutions:**
1. In Xcode, go to Product → Clean Build Folder (⇧⌘K)
2. Rebuild and run (⌘R)
3. Check Console in Xcode for error messages

---

## Free Apple ID Limitations

With a **free Apple ID** (Personal Team):

✅ Can install on your own devices  
✅ Full app functionality  
✅ Can use for development and testing  
❌ Apps expire after **7 days** (need to reinstall)  
❌ Can't publish to App Store  
❌ Limited to 3 apps installed at once  

**Workaround for 7-day expiration:**
- Just rebuild and deploy again from Xcode (takes 30 seconds)
- Your data (dream history) will be preserved!

---

## Paid Developer Account ($99/year)

If you want to:
- Install apps for a full year without reinstalling
- Publish to the App Store
- Get advanced capabilities

You can enroll at: https://developer.apple.com/programs/

---

## Build Commands (Advanced)

If you prefer command line:

```bash
# Navigate to project
cd "/Users/SEV0A/Iphone/GJSPO/DreamWeaver/Dream Vewawer"

# Find your device ID
xcrun xctrace list devices

# Build and install (replace YOUR-DEVICE-ID)
xcodebuild -project "Dream Vewawer.xcodeproj" \
  -scheme "Dream Vewawer" \
  -destination 'id=YOUR-DEVICE-ID' \
  clean build
```

---

## Next Steps: Apple Watch Deployment

Once you get an Apple Watch:

1. Pair it with your iPhone
2. Follow the **APPLE_WATCH_ROADMAP.md** guide
3. Add watchOS target to the project
4. Deploy to both devices simultaneously
5. Enable real biosignal tracking! ⌚

---

## Tips for Best Experience

🌙 **For Testing:**
- Track for 30 seconds to 2 minutes
- Try different times to generate varied biosignals
- Build up a collection of dreams

🛌 **For Real Sleep Tracking:**
- Fully charge iPhone before bed
- Enable Do Not Disturb
- Place face-down on nightstand
- Start tracking right before sleep
- Stop when you wake up

📊 **Data Privacy:**
- All data stays on your iPhone
- No cloud sync
- No analytics or tracking
- Completely private

---

## Summary - Quick Deploy Checklist

- [ ] iPhone connected via USB
- [ ] iPhone unlocked and computer trusted
- [ ] Xcode open with Dream Vewawer project
- [ ] Your iPhone selected in device menu
- [ ] Signed in with Apple ID
- [ ] "Automatically manage signing" enabled
- [ ] Unique Bundle Identifier (if needed)
- [ ] Press ⌘R to build and run
- [ ] Trust developer in iPhone Settings
- [ ] Launch app and enjoy! 🎉

---

**Enjoy tracking your dreams on your real iPhone!** 🌟✨

*"Your mind paints while you sleep. DreamWeaver reveals the masterpiece."*
