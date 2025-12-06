# Firebase Certificates

## Debug Keystore Certificates

### SHA-1 Fingerprint
```
6E:8B:D4:3C:7A:36:21:19:25:1C:3B:BA:22:0D:78:30:D1:06:38:84
```

### SHA-256 Fingerprint
```
03:88:65:E0:3C:23:5D:72:63:DD:79:2E:8D:4F:A7:A0:25:C6:B8:F8:5B:F7:6A:15:8B:8E:FD:A4:9B:59:19:60
```

### Signature Algorithm
```
SHA256withRSA
```

## Package Name
```
com.oceandojo.surf
```

## Firebase Project
- Project ID: `surf-174de`
- Project Number: `918773160950`

## How to Add to Firebase

1. Go to Firebase Console → Project Settings
2. Scroll to "Your apps" section
3. Click on Android app (`com.oceandojo.surf`)
4. Click "Add fingerprint"
5. Add SHA-1: `6E:8B:D4:3C:7A:36:21:19:25:1C:3B:BA:22:0D:78:30:D1:06:38:84`
6. (Optional) Add SHA-256: `03:88:65:E0:3C:23:5D:72:63:DD:79:2E:8D:4F:A7:A0:25:C6:B8:F8:5B:F7:6A:15:8B:8E:FD:A4:9B:59:19:60`
7. Click "Save"

## Notes

- SHA-1 is required for Google Sign-In to work
- SHA-256 is recommended for additional security
- These certificates are for the debug keystore (development)
- For production, you'll need to generate certificates from your release keystore

