# Firebase Setup Guide

This guide will walk you through setting up Firebase for the Surf Mobile application.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter a project name (e.g., "Surf Mobile")
4. Follow the setup wizard:
   - Disable Google Analytics (optional, you can enable later)
   - Click **"Create project"**
   - Wait for the project to be created
   - Click **"Continue"**

## Step 2: Add Android App to Firebase

1. In your Firebase project dashboard, click the **Android icon** (or **"Add app"** → **Android**)
2. Fill in the Android app details:
   - **Android package name**: `com.oceandojo.surf`
     - ⚠️ **Important**: This must match the `applicationId` in `android/app/build.gradle.kts`
   - **App nickname** (optional): Surf Mobile
   - **Debug signing certificate SHA-1** (optional for now, needed for Google Sign-In)
3. Click **"Register app"**
4. Download the `google-services.json` file
5. Place the file in: `android/app/google-services.json`
   ```bash
   # Make sure the file is in the correct location
   android/app/google-services.json
   ```

## Step 3: Get SHA-1 Certificate (Required for Google Sign-In)

To enable Google Sign-In, you need to add your app's SHA-1 certificate fingerprint to Firebase.

### Option A: Get SHA-1 from debug keystore (Development)

```bash
# On Linux/Mac
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# On Windows
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Copy the SHA-1 fingerprint (looks like: `AA:BB:CC:DD:EE:FF:...`)

### Option B: Get SHA-1 using Gradle (Easier)

```bash
cd android
./gradlew signingReport
```

Look for the SHA-1 under `Variant: debug` → `SHA1:`.

### Add SHA-1 to Firebase

1. Go to Firebase Console → Your Project → **Project Settings**
2. Scroll down to **"Your apps"** section
3. Click on your Android app (`com.oceandojo.surf`)
4. Click **"Add fingerprint"**
5. Paste your SHA-1 certificate:
   ```
   6E:8B:D4:3C:7A:36:21:19:25:1C:3B:BA:22:0D:78:30:D1:06:38:84
   ```
6. (Optional) Add SHA-256 for additional security:
   ```
   03:88:65:E0:3C:23:5D:72:63:DD:79:2E:8D:4F:A7:A0:25:C6:B8:F8:5B:F7:6A:15:8B:8E:FD:A4:9B:59:19:60
   ```
7. Click **"Save"**

> **Note**: See `FIREBASE_CERTIFICATES.md` for certificate details.

## Step 4: Enable Authentication Methods

1. In Firebase Console, go to **Authentication** → **Get started**
2. Click on **"Sign-in method"** tab
3. Enable the following providers:

### Email/Password Authentication

1. Click on **"Email/Password"**
2. Toggle **"Enable"** to ON
3. Click **"Save"**

### Google Sign-In

1. Click on **"Google"**
2. Toggle **"Enable"** to ON
3. Enter a **Project support email** (your email)
4. Click **"Save"**

## Step 5: Verify Configuration

### Check Files

1. ✅ `android/app/google-services.json` exists
2. ✅ `android/app/build.gradle.kts` includes `id("com.google.gms.google-services")`
3. ✅ `android/settings.gradle.kts` includes the Google Services plugin

### Test the Setup

1. Run the app:
   ```bash
   flutter run
   ```

2. Try to sign in:
   - Email/Password should work
   - Google Sign-In should work (after SHA-1 is added)

## Troubleshooting

### Error: "google-services.json not found"

- Make sure `google-services.json` is in `android/app/` directory
- Verify the file name is exactly `google-services.json` (case-sensitive)

### Error: "Default FirebaseApp is not initialized"

- Make sure `google-services.json` is in the correct location
- Clean and rebuild:
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

### Google Sign-In not working

- Verify SHA-1 certificate is added to Firebase Console
- Make sure Google Sign-In is enabled in Firebase Authentication
- Check that the package name matches exactly

### Package name mismatch

If you need to change the package name:

1. Update `applicationId` in `android/app/build.gradle.kts`
2. Update package name in `android/app/src/main/kotlin/com/example/surf_mobile/MainActivity.kt`
3. Update package name in Firebase Console or create a new Android app

## Additional Resources

- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Firebase Authentication Setup](https://firebase.google.com/docs/auth/flutter/start)
- [Google Sign-In Setup](https://firebase.google.com/docs/auth/android/google-signin)

## Quick Checklist

- [ ] Firebase project created
- [ ] Android app added to Firebase
- [ ] `google-services.json` downloaded and placed in `android/app/`
- [ ] SHA-1 certificate added to Firebase
- [ ] Email/Password authentication enabled
- [ ] Google Sign-In enabled
- [ ] App runs without Firebase errors

