# Flutter Setup Instructions for Windows

## 📥 Installation Steps

### Step 1: Download Complete
Flutter is being downloaded to: `C:\flutter`

### Step 2: Add to System PATH

**Option A: Permanent (Recommended)**
1. Press `Win + X` → Select "System"
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "User variables", find "Path"
5. Click "Edit" → "New"
6. Add: `C:\flutter\bin`
7. Click OK on all windows
8. **Close and reopen PowerShell**

**Option B: Current Session Only (Quick Test)**
Run in PowerShell:
```powershell
$env:Path += ";C:\flutter\bin"
```

### Step 3: Verify Installation
```powershell
flutter doctor
```

### Step 4: Accept Android Licenses (if needed)
```powershell
flutter doctor --android-licenses
```

### Step 5: Build Your APK
```powershell
cd d:\yoga_app\flutter_app
flutter build apk --release
```

---

## 📱 APK Location
After build completes:
```
d:\yoga_app\flutter_app\build\app\outputs\flutter-apk\app-release.apk
```

Transfer this file to your phone and install!

---

## ⚠️ Common Issues

**If "flutter" not recognized:**
- Close and reopen PowerShell after adding to PATH
- Or use full path: `C:\flutter\bin\flutter.bat build apk --release`

**If Android SDK not found:**
- Install Android Studio from: https://developer.android.com/studio
- Run: `flutter doctor` to see what's missing

**If build fails:**
- Run: `flutter clean`
- Then: `flutter pub get`
- Then: `flutter build apk --release`
