# Authentication Configuration Guide

## Prerequisites

- Flutter SDK 3.0+
- Supabase account
- Google Cloud Console project

---

## 1. Supabase Setup

### Create Project
1. Go to [supabase.com](https://supabase.com)
2. Create new project
3. Note your **Project URL** and **Anon Key**

### Enable Email Auth
1. Go to **Authentication → Providers → Email**
2. Enable email provider
3. Configure settings:
   - ✅ Enable email confirmations (recommended)
   - ✅ Enable password recovery

### Enable Google Auth
1. Go to **Authentication → Providers → Google**
2. Toggle **Enable Google provider**
3. Add your Google OAuth credentials (see below)
4. Save

### Configure Redirect URLs
1. Go to **Authentication → URL Configuration**
2. Add to **Redirect URLs**:
   ```
   http://localhost:3000
   http://localhost:3000/**
   http://localhost:8585/auth/callback
   ```

---

## 2. Google Cloud Console Setup

### Create OAuth Credentials

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Create or select project
3. Enable **Google+ API** and **People API**
4. Go to **APIs & Services → Credentials**
5. Create OAuth 2.0 Client IDs:

#### Web Client (Required for all platforms)
- Application type: **Web application**
- Authorized JavaScript origins:
  ```
  http://localhost
  http://localhost:3000
  ```
- Authorized redirect URIs:
  ```
  https://YOUR_PROJECT_ID.supabase.co/auth/v1/callback
  ```

#### Android Client
- Application type: **Android**
- Package name: `com.example.frontend` (check your AndroidManifest.xml)
- SHA-1 certificate fingerprint (get from keytool)

#### iOS Client
- Application type: **iOS**
- Bundle ID: `com.example.frontend` (check your Info.plist)

---

## 3. Flutter Project Configuration

### Environment Variables

Create `.env` file in `frontend/` directory:

```env
# Supabase Configuration
SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here

# Google Sign In (Web Client ID)
GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

> ⚠️ **Important**: Add `.env` to `.gitignore`!

### Android Configuration

Create `android/app/src/main/res/values/strings.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="default_web_client_id">YOUR_WEB_CLIENT_ID.apps.googleusercontent.com</string>
</resources>
```

### iOS Configuration

Update `ios/Runner/Info.plist`:

```xml
<!-- URL Scheme for Google Sign In -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_IOS_CLIENT_ID</string>
    </array>
  </dict>
</array>

<!-- Google Sign In Client ID -->
<key>GIDClientID</key>
<string>YOUR_IOS_CLIENT_ID.apps.googleusercontent.com</string>
```

---

## 4. Dependencies

Ensure `pubspec.yaml` includes:

```yaml
dependencies:
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Dependency Injection
  get_it: ^7.6.4
  
  # Routing
  go_router: ^14.6.2
  
  # Functional Programming
  fpdart: ^1.1.0
  
  # Backend & Auth
  supabase_flutter: ^2.8.2
  google_sign_in: ^6.2.2
  url_launcher: ^6.2.4
  
  # Environment Variables
  flutter_dotenv: ^5.1.0
```

Run:
```bash
flutter pub get
```

---

## 5. App Initialization

In `lib/main.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  // Setup dependency injection
  await configureDependencies();
  
  runApp(const MyApp());
}
```

---

## 6. Verification Checklist

### Supabase Dashboard
- [ ] Email provider enabled
- [ ] Google provider enabled with credentials
- [ ] Redirect URLs configured

### Google Cloud Console
- [ ] Web OAuth client created
- [ ] Android OAuth client created (with SHA-1)
- [ ] iOS OAuth client created
- [ ] People API enabled

### Flutter Project
- [ ] `.env` file created with credentials
- [ ] `strings.xml` created for Android
- [ ] `Info.plist` updated for iOS
- [ ] All dependencies installed

---

## 7. Testing

### Run on Web
```bash
flutter run -d chrome --web-port=3000
```

### Run on Android
```bash
flutter run -d android
```

### Run on Windows
```bash
flutter run -d windows
```

### Quick Auth Test
1. Open app
2. Click "Continue with Google"
3. Complete Google sign in
4. Verify redirect to home screen
5. Check Supabase Dashboard → Authentication → Users
