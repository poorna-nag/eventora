---
description: How to publish Eventora app to Google Play Store
---

# Publishing Eventora to Google Play Store

## Prerequisites
1. Google Play Developer Account ($25 one-time fee) - Sign up at https://play.google.com/console
2. Completed app with all features working
3. Privacy Policy URL (required by Google)
4. App screenshots and promotional materials

## Phase 1: Prepare App Configuration

### 1. Change Application ID
**CRITICAL**: Change from `com.example.eventora` to a unique package name.

Edit `android/app/build.gradle.kts`:
- Change `applicationId = "com.example.eventora"` to something like `applicationId = "com.yourname.eventora"` or `applicationId = "com.yourdomain.eventora"`
- Also update `namespace = "com.example.eventora"` to match

### 2. Update Version Information
Edit `pubspec.yaml`:
- Change `version: 0.1.0` to `version: 1.0.0+1`
  - Format is `version: X.Y.Z+buildNumber`
  - First part (1.0.0) is version name
  - After + (1) is version code (must increment for each release)

### 3. Secure Your API Keys
**IMPORTANT**: Add `.env` to `.gitignore` to prevent pushing sensitive keys to GitHub:
```
echo ".env" >> .gitignore
```

## Phase 2: Create Release Signing Key

### 1. Generate Upload Keystore
Run this command in your project root:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

You'll be asked for:
- Keystore password (SAVE THIS - you'll need it!)
- Key password (can be same as keystore password)
- Your name, organization, city, state, country

**CRITICAL**: Save these passwords securely! If you lose them, you can never update your app again!

### 2. Create key.properties File
Create `android/key.properties` with:
```
storePassword=<password from previous step>
keyPassword=<password from previous step>
keyAlias=upload
storeFile=<path to upload-keystore.jks>
```

Example:
```
storePassword=mySecurePassword123
keyPassword=mySecurePassword123
keyAlias=upload
storeFile=/Users/poornanag/upload-keystore.jks
```

**IMPORTANT**: Add this to `.gitignore`:
```
echo "android/key.properties" >> .gitignore
```

### 3. Configure Signing in build.gradle.kts
Edit `android/app/build.gradle.kts`:

Add before `android {` block:
```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

Inside `android {` block, add `signingConfigs` before `buildTypes`:
```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}
```

Update `buildTypes` release section:
```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = true
        proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
    }
}
```

## Phase 3: Build Release App Bundle

### 1. Clean Build
// turbo
```bash
cd "/Users/poornanag/flutter projects/eventora"
flutter clean
```

### 2. Get Dependencies
// turbo
```bash
cd "/Users/poornanag/flutter projects/eventora"
flutter pub get
```

### 3. Build App Bundle (Recommended by Google)
```bash
cd "/Users/poornanag/flutter projects/eventora"
flutter build appbundle --release
```

The output will be at: `build/app/outputs/bundle/release/app-release.aab`

**Alternative**: Build APK (for testing or other stores):
```bash
flutter build apk --release
```

## Phase 4: Prepare Store Listing Materials

### 1. App Screenshots (Required)
- Minimum 2 screenshots (up to 8)
- JPEG or 24-bit PNG (no alpha)
- Minimum dimension: 320px
- Maximum dimension: 3840px
- Recommended: 1080 x 1920 (portrait) or 1920 x 1080 (landscape)

Take screenshots from your app using:
- Android emulator or real device
- Use `adb shell screencap` or device screenshot feature

### 2. Feature Graphic (Required)
- JPEG or 24-bit PNG (no alpha)
- Dimensions: 1024w x 500h

### 3. App Icon (Already configured via flutter_launcher_icons)
- 512 x 512 PNG
- 32-bit PNG (with alpha)

### 4. Privacy Policy (Required for apps with sensitive permissions)
- Must be hosted on a publicly accessible URL
- Should explain what data you collect and how you use it
- Your app uses: Camera, Storage, Location, Internet - so this is REQUIRED

### 5. App Description
Prepare:
- **Short description** (max 80 characters)
- **Full description** (max 4000 characters)
- Explain what Eventora does, key features, etc.

## Phase 5: Create Play Console Listing

### 1. Go to Play Console
Visit: https://play.google.com/console

### 2. Create New App
- Click "Create app"
- Enter app name: "Eventora"
- Select default language
- Choose "App" (not game)
- Choose "Free" or "Paid"
- Accept declarations

### 3. Set Up Store Listing
Fill in:
- App name
- Short description
- Full description
- App icon
- Feature graphic
- Screenshots
- App category (Events)
- Contact details
- Privacy policy URL

### 4. Content Rating
- Complete questionnaire
- Be honest about content
- Events app should be rated for all ages

### 5. Target Audience
- Select age groups
- Declare if app is designed for children

### 6. Data Safety
- Declare what data you collect
- Based on your app: Location, Personal info (name, email), Photos
- Explain security measures

### 7. App Access
- If your app requires login, provide test credentials
- Or indicate it's freely accessible

## Phase 6: Upload and Release

### 1. Create Release
- Go to "Production" track
- Click "Create new release"
- Upload your `app-release.aab` file

### 2. Release Notes
Add what's new in this version:
```
Initial release of Eventora - Discover and book amazing events!

Features:
- Browse local events
- Book tickets with integrated payment
- QR code ticket system
- Create and manage your own events
- User profiles and collections
```

### 3. Review and Rollout
- Review all information
- Click "Review release"
- Fix any errors or warnings
- Click "Start rollout to Production"

### 4. Wait for Review
- Google typically reviews within 1-3 days
- You'll receive email updates
- App may be rejected if issues found - fix and resubmit

## Phase 7: Post-Publication

### 1. Monitor Reviews
- Respond to user reviews
- Fix reported bugs

### 2. Update App
When releasing updates:
- Increment version in `pubspec.yaml` (e.g., `1.0.1+2`)
- Build new app bundle
- Upload to Play Console
- Add release notes

### 3. Analytics
- Monitor installs, crashes, ratings
- Use Play Console dashboard

## Important Notes

### Security Checklist
- [ ] Changed from `com.example.eventora` to unique package name
- [ ] `.env` file is in `.gitignore`
- [ ] `key.properties` is in `.gitignore`
- [ ] Upload keystore is backed up securely
- [ ] Passwords are saved securely (password manager)
- [ ] Test keys (Razorpay test key) replaced with production keys

### Legal Requirements
- [ ] Privacy Policy created and hosted
- [ ] Terms of Service (recommended)
- [ ] Content rating completed
- [ ] Data safety form completed
- [ ] App complies with Google Play policies

### Testing Before Release
- [ ] Test on multiple devices
- [ ] Test all features work in release mode
- [ ] Test payment gateway with real transactions
- [ ] Verify Firebase works in production
- [ ] Check app performance

## Troubleshooting

### Build Fails
- Run `flutter clean` and try again
- Check `key.properties` path is correct
- Verify keystore file exists

### Upload Rejected
- Check package name is unique
- Verify version code is higher than previous
- Ensure app bundle is signed correctly

### App Rejected by Google
- Read rejection email carefully
- Common issues: Privacy policy, permissions, content rating
- Fix issues and resubmit

## Additional Resources
- [Flutter Deployment Guide](https://docs.flutter.dev/deployment/android)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [App Signing Best Practices](https://developer.android.com/studio/publish/app-signing)
