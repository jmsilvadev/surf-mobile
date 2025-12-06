# Surf Mobile

Flutter mobile application for Surf School Management System.

## Features

- Firebase Authentication (Email/Password and Google Sign-In)
- Class Calendar View
- My Registrations
- Equipment Rentals

## Setup

### Prerequisites

- Flutter SDK (>=3.0.0)
- Firebase project configured
- Backend API running (default: http://localhost:8080)

### Firebase Setup

**📖 For detailed Firebase setup instructions, see [FIREBASE_SETUP.md](FIREBASE_SETUP.md)**

Quick steps:
1. Create a Firebase project at https://console.firebase.google.com
2. Add Android app to Firebase project (package name: `com.oceandojo.surf`)
3. Download `google-services.json` and place in `android/app/`
4. Get SHA-1 certificate and add to Firebase (required for Google Sign-In)
5. Enable Authentication methods in Firebase Console:
   - Email/Password
   - Google Sign-In

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Configure environment variables:
   - Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
   - Edit `.env` and set your API base URL:
   ```
   API_BASE_URL=http://localhost:8080
   ```
   - For production, update with your production API URL:
   ```
   API_BASE_URL=https://api.surf-backend.com
   ```

3. Configure Firebase:
   - Add your Firebase configuration files (see above)

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── class_model.dart
│   ├── rental_model.dart
│   └── class_student_model.dart
├── screens/                  # UI screens
│   ├── login_screen.dart
│   ├── main_screen.dart
│   ├── calendar_screen.dart
│   ├── registrations_screen.dart
│   └── rentals_screen.dart
└── services/                 # Business logic
    ├── auth_service.dart
    └── api_service.dart
```

## API Integration

The app connects to the Surf Backend API. Make sure the backend is running and accessible at the configured URL.

### Endpoints Used

- `GET /api/classes` - Fetch all classes
- `GET /api/students/{student_id}/classes` - Fetch student registrations
- `GET /api/rentals` - Fetch all rentals
- `GET /api/rentals` (filtered by student_id) - Fetch student rentals

## Environment Variables

The application uses environment variables for configuration. Create a `.env` file in the root directory:

```
API_BASE_URL=http://localhost:8080
```

The `.env` file is ignored by git. Use `.env.example` as a template.

## Notes

- Student ID is currently hardcoded as a placeholder. In production, this should be fetched from Firebase Auth user metadata or a user profile API endpoint.
- The API base URL is configured via the `API_BASE_URL` environment variable in the `.env` file.

