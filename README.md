# SnapHealth App

Flutter mobile app for iOS and Android. Open source under the MIT License.

## Setup

1. Install Flutter 3.x and run from this folder:

```
flutter pub get
```

2. Copy the dart-defines file and add your Supabase keys:

```
cp .env.dart-defines.example .env.dart-defines
```

Edit .env.dart-defines with your Supabase project URL and publishable key from the Supabase dashboard.

3. Make sure the backend is running (see backend/README.md).

4. Run on a device or emulator:

```
flutter run --dart-define-from-file=.env.dart-defines
```

For a physical device on the same WiFi network, add your machine IP to .env.dart-defines:

```
API_URL=http://192.168.1.x:3000/api
```

Release builds require API_URL over HTTPS.

## Optional defines

- API_URL - backend base URL (defaults to localhost in debug)
- SENTRY_DSN - error tracking (leave empty to disable)

## What the app does

- Sign in with email or social login via Supabase
- Onboarding collects health conditions, goals, diet, allergies
- Camera scan sends the image to the backend and shows streaming results
- On-device barcode scan can skip AI for known products
- History, insights, streaks, challenges, and leaderboards

## Project structure

- lib/features - screens grouped by feature
- lib/core/api - HTTP and SSE clients
- lib/core/models - Freezed data models
- lib/core/providers - Riverpod state
- lib/core/theme - design tokens (app_theme.dart)
- lib/widgets - shared UI components

## Build

```
flutter build apk --release --dart-define-from-file=.env.dart-defines
flutter build ios --release --dart-define-from-file=.env.dart-defines
```

Project history: Originally developed as a private personal project and released publicly in July 2026 after removing private configuration and sensitive data. The public repository uses a cleaned, squashed history.

## License

MIT License. See LICENSE.
