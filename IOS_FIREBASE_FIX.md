# iOS Firebase Configuration Update

## Issue
The iOS app is failing to launch because Firebase doesn't have an iOS app registered with bundle ID `com.poornanag.eventora`.

## Solution: Add New iOS App to Firebase

### Steps:

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/project/eventora-d7ef2/settings/general

2. **Add iOS App**
   - Scroll to "Your apps" section
   - Click "Add app" → Select iOS icon (Apple logo)
   - Enter iOS bundle ID: `com.poornanag.eventora`
   - Enter app nickname: "Eventora iOS (Production)"
   - Click "Register app"

3. **Download GoogleService-Info.plist**
   - Download the new `GoogleService-Info.plist` file
   - Replace the existing file at:
     `/Users/poornanag/flutter projects/eventora/ios/Runner/GoogleService-Info.plist`

4. **Rebuild and Run**
   ```bash
   cd "/Users/poornanag/flutter projects/eventora"
   flutter clean
   flutter run
   ```

## Alternative: Test on Android

If you want to test quickly without updating Firebase iOS:

1. **Start Android Emulator**
   - Open Android Studio
   - Start an Android emulator

2. **Run the app**
   ```bash
   flutter run
   ```

## Alternative: Revert to Old Bundle ID (Not Recommended)

If you want to keep the old bundle ID for now:

1. Edit `ios/Runner.xcodeproj/project.pbxproj`
2. Change all `com.poornanag.eventora` back to `com.example.eventora`
3. Update `GoogleService-Info.plist` BUNDLE_ID back to `com.example.eventora`

**Note**: This is NOT recommended for Play Store publication as `com.example.*` package names may be rejected.

## Recommended Action

**Add the new iOS app to Firebase** (Option 1) - This ensures both Android and iOS use the correct production package names.
