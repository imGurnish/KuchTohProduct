# Platform-Specific Authentication

## Overview

| Platform | Email Auth | Google Sign In | Method |
|----------|------------|----------------|--------|
| Web | ✅ | ✅ | Supabase OAuth redirect |
| Android | ✅ | ✅ | google_sign_in package |
| iOS | ✅ | ✅ | google_sign_in package |
| Windows | ✅ | ✅ | Local HTTP server + browser |
| Linux | ✅ | ✅ | Local HTTP server + browser |
| macOS | ✅ | ✅ | Local HTTP server + browser |

---

## Web Platform

### How It Works
1. User clicks "Continue with Google"
2. `signInWithOAuth(OAuthProvider.google)` redirects to Google
3. Google redirects back to app with session
4. `AuthStateChange` listener picks up the session

### Configuration Required
- Add redirect URLs in Supabase Dashboard
- Add JavaScript origins in Google Cloud Console

### Code Path
```
WelcomeScreen
  → AuthBloc.add(AuthGoogleSignInRequested)
  → AuthRepository.signInWithGoogle()
  → AuthRemoteDataSource._signInWithGoogleOAuth()
  → supabaseClient.auth.signInWithOAuth()
  → [Browser Redirect]
  → AuthStateChange listener
  → AuthBloc emits AuthAuthenticated
```

---

## Android Platform

### How It Works
1. User clicks "Continue with Google"
2. `google_sign_in` shows native Google account picker
3. Returns ID token
4. `signInWithIdToken()` exchanges for Supabase session

### Configuration Required

#### 1. `android/app/src/main/res/values/strings.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="default_web_client_id">YOUR_WEB_CLIENT_ID.apps.googleusercontent.com</string>
</resources>
```

#### 2. SHA-1 Fingerprint
Get your debug SHA-1:
```bash
keytool -list -v -alias androiddebugkey \
  -keystore ~/.android/debug.keystore \
  -storepass android -keypass android
```

Add this SHA-1 to your Android OAuth client in Google Cloud Console.

### Code Path
```
WelcomeScreen
  → AuthBloc.add(AuthGoogleSignInRequested)
  → AuthRepository.signInWithGoogle()
  → AuthRemoteDataSource._signInWithGoogleMobile()
  → GoogleSignIn().signIn()
  → googleUser.authentication
  → supabaseClient.auth.signInWithIdToken()
  → AuthBloc emits AuthAuthenticated
```

---

## iOS Platform

### How It Works
Same as Android - uses `google_sign_in` package.

### Configuration Required

#### 1. `ios/Runner/Info.plist`
Add URL scheme for Google Sign In:
```xml
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
```

#### 2. `ios/Runner/Info.plist` (continued)
Add Google Sign In client ID:
```xml
<key>GIDClientID</key>
<string>YOUR_IOS_CLIENT_ID.apps.googleusercontent.com</string>
```

### Code Path
Same as Android.

---

## Windows/Linux Platform

### How It Works
1. User clicks "Continue with Google"
2. App starts local HTTP server on port 8585
3. Opens browser for Google OAuth
4. Google redirects to `http://localhost:8585/auth/callback`
5. Local server captures auth code
6. `exchangeCodeForSession()` completes auth

### Why This Approach?
- `google_sign_in` package doesn't support desktop natively
- Supabase OAuth redirect can't return to native app
- Local server acts as redirect target

### Configuration Required

#### 1. Supabase Dashboard - URL Configuration
Add to Redirect URLs:
```
http://localhost:8585/auth/callback
```

### Code Path
```
WelcomeScreen
  → AuthBloc.add(AuthGoogleSignInRequested)
  → AuthRepository.signInWithGoogle()
  → AuthRemoteDataSource._signInWithGoogleDesktop()
  → DesktopOAuthHelper.signInWithGoogle()
  → HttpServer.bind(localhost, 8585)
  → supabaseClient.auth.getOAuthSignInUrl()
  → launchUrl() [Opens Browser]
  → [User authenticates in browser]
  → [Browser redirects to localhost:8585/auth/callback?code=...]
  → HttpServer receives request
  → supabaseClient.auth.exchangeCodeForSession(code)
  → AuthBloc emits AuthAuthenticated
```

### Desktop OAuth Flow Diagram

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│  Flutter App │         │   Browser    │         │    Google    │
└──────┬───────┘         └──────┬───────┘         └──────┬───────┘
       │                        │                        │
       │ Start HTTP Server      │                        │
       │ on port 8585           │                        │
       │───────────────────────►│                        │
       │                        │                        │
       │ Open OAuth URL         │                        │
       │───────────────────────►│                        │
       │                        │                        │
       │                        │ Redirect to Google     │
       │                        │───────────────────────►│
       │                        │                        │
       │                        │ User logs in           │
       │                        │◄───────────────────────│
       │                        │                        │
       │                        │ Redirect to localhost  │
       │◄───────────────────────│ with ?code=...        │
       │                        │                        │
       │ Exchange code          │                        │
       │ for session            │                        │
       │                        │                        │
       │ Auth Complete!         │                        │
       ▼                        ▼                        ▼
```

---

## macOS Platform

Same as Windows/Linux - uses `DesktopOAuthHelper`.

### Additional Configuration

#### 1. Entitlements
Ensure `macos/Runner/DebugProfile.entitlements` allows network access:
```xml
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.network.server</key>
<true/>
```

---

## Troubleshooting

### Web: "redirect_uri_mismatch"
- Add `http://localhost:3000` to Google Cloud Console → Authorized JavaScript Origins
- Add redirect URLs to Supabase Dashboard

### Android: "No ID token found"
- Ensure `default_web_client_id` is set in `strings.xml`
- Add SHA-1 fingerprint to Google Cloud Console

### Desktop: "No authorization code received"
- Ensure Supabase redirect URL includes `http://localhost:8585/auth/callback`
- Check if another app is using port 8585

### Desktop: "code challenge does not match"
- Must use `getOAuthSignInUrl()` instead of manual PKCE
- Supabase SDK manages code verifier internally
