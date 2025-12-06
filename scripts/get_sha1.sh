#!/bin/bash
# Script to get SHA-1 certificate for Firebase Google Sign-In setup

echo "Getting SHA-1 certificate for Firebase..."
echo ""

# Try to get SHA-1 using Gradle
if [ -d "android" ]; then
    cd android
    echo "Using Gradle to get SHA-1..."
    ./gradlew signingReport 2>/dev/null | grep -A 2 "Variant: debug" | grep "SHA1:" | head -1
    cd ..
else
    echo "Android directory not found. Trying debug keystore..."
    
    # Try to get from debug keystore
    KEYSTORE_PATH="$HOME/.android/debug.keystore"
    
    if [ -f "$KEYSTORE_PATH" ]; then
        echo "Found debug keystore at: $KEYSTORE_PATH"
        keytool -list -v -keystore "$KEYSTORE_PATH" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep -A 1 "SHA1:" | grep -v "^--"
    else
        echo "Debug keystore not found at: $KEYSTORE_PATH"
        echo ""
        echo "To get SHA-1 manually, run:"
        echo "  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android"
        echo ""
        echo "Or use Gradle:"
        echo "  cd android && ./gradlew signingReport"
    fi
fi

echo ""
echo "Copy the SHA-1 value above and add it to Firebase Console:"
echo "  Firebase Console → Project Settings → Your apps → Android app → Add fingerprint"

