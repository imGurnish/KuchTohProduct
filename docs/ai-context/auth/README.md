# Authentication System Documentation

This directory contains comprehensive documentation for Mindspace's authentication system implementation.

## Overview

The authentication system is built using **Supabase** as the backend provider and follows **Clean Architecture** principles with the BLoC pattern for state management.

## Documentation Structure

| File | Description |
|------|-------------|
| [ARCHITECTURE.md](./ARCHITECTURE.md) | System architecture and data flow |
| [IMPLEMENTATION.md](./IMPLEMENTATION.md) | Detailed implementation guide |
| [PLATFORM_SUPPORT.md](./PLATFORM_SUPPORT.md) | Platform-specific configurations |
| [CONFIGURATION.md](./CONFIGURATION.md) | Environment setup and configuration |

## Quick Links

### Features Implemented
- ✅ Email/Password Sign In
- ✅ Email/Password Sign Up
- ✅ Google Sign In (Web, Android, iOS, Windows, Linux)
- ✅ Email Verification
- ✅ Password Reset
- ✅ Session Persistence
- ✅ Auto-logout on token expiry

### Tech Stack
- **Backend**: Supabase Auth
- **State Management**: flutter_bloc
- **Routing**: go_router
- **DI**: get_it
- **Platform OAuth**: google_sign_in (mobile), Supabase OAuth (web/desktop)

## Directory Structure

```
lib/features/auth/
├── data/
│   ├── datasources/
│   │   ├── auth_remote_data_source.dart
│   │   └── desktop_oauth_helper.dart
│   ├── models/
│   │   └── user_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── user.dart
│   └── repositories/
│       └── auth_repository.dart
└── presentation/
    ├── bloc/
    │   └── auth_bloc.dart
    └── screens/
        ├── welcome_screen.dart
        ├── login_screen.dart
        ├── signup_screen.dart
        ├── email_verification_screen.dart
        └── password_recovery_screen.dart
```
