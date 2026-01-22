# Environment Setup

This project uses environment variables to securely store sensitive API keys and configuration values.

## Initial Setup

1. **Copy the example environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Fill in your API keys in the `.env` file:**
   - `RAZORPAY_KEY`: Your Razorpay payment gateway key (get from [Razorpay Dashboard](https://dashboard.razorpay.com/app/keys))
   - Firebase configuration values (get from [Firebase Console](https://console.firebase.google.com/) > Project Settings > General > Your apps)

3. **Generate the environment configuration:**
   ```bash
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

## Important Notes

- **Never commit `.env` file to Git** - It's already added to `.gitignore`
- The `.env.example` file is safe to commit and serves as a template for other developers
- After updating `.env`, run `dart run build_runner build --delete-conflicting-outputs` to regenerate the configuration

## Required Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `RAZORPAY_KEY` | Razorpay payment gateway API key | `rzp_test_xxxxx` or `rzp_live_xxxxx` |
| `FIREBASE_ANDROID_API_KEY` | Firebase Android API key | `AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX` |
| `FIREBASE_ANDROID_APP_ID` | Firebase Android App ID | `1:123456789:android:xxxxx` |
| `FIREBASE_MESSAGING_SENDER_ID` | Firebase Messaging Sender ID | `123456789` |
| `FIREBASE_PROJECT_ID` | Firebase Project ID | `your-project-id` |
| `FIREBASE_STORAGE_BUCKET` | Firebase Storage Bucket | `your-project.firebasestorage.app` |
| `FIREBASE_IOS_API_KEY` | Firebase iOS API key | `AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX` |
| `FIREBASE_IOS_APP_ID` | Firebase iOS App ID | `1:123456789:ios:xxxxx` |
| `FIREBASE_IOS_CLIENT_ID` | Firebase iOS Client ID | `123456789-xxxxx.apps.googleusercontent.com` |
| `FIREBASE_IOS_BUNDLE_ID` | iOS Bundle ID | `com.example.eventora` |

## Troubleshooting

If you encounter build errors:
1. Clean the project: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Regenerate env config: `dart run build_runner build --delete-conflicting-outputs`
4. Run the app: `flutter run`
