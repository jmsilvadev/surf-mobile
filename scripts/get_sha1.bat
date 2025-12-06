@echo off
REM Script to get SHA-1 certificate for Firebase Google Sign-In setup (Windows)

echo Getting SHA-1 certificate for Firebase...
echo.

REM Try to get SHA-1 using Gradle
if exist android (
    cd android
    echo Using Gradle to get SHA-1...
    gradlew.bat signingReport 2>nul | findstr /C:"SHA1:"
    cd ..
) else (
    echo Android directory not found. Trying debug keystore...
    
    REM Try to get from debug keystore
    set KEYSTORE_PATH=%USERPROFILE%\.android\debug.keystore
    
    if exist "%KEYSTORE_PATH%" (
        echo Found debug keystore at: %KEYSTORE_PATH%
        keytool -list -v -keystore "%KEYSTORE_PATH%" -alias androiddebugkey -storepass android -keypass android 2>nul | findstr /C:"SHA1:"
    ) else (
        echo Debug keystore not found at: %KEYSTORE_PATH%
        echo.
        echo To get SHA-1 manually, run:
        echo   keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
        echo.
        echo Or use Gradle:
        echo   cd android ^&^& gradlew.bat signingReport
    )
)

echo.
echo Copy the SHA-1 value above and add it to Firebase Console:
echo   Firebase Console -^> Project Settings -^> Your apps -^> Android app -^> Add fingerprint

pause

