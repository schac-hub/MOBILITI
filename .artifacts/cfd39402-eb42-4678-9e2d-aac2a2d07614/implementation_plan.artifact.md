# Implementation Plan - Flutter Migration & Foundations

The user has requested to build the "Mobiliti" project using **Flutter (Dart)** instead of native Android (Compose). This plan covers the project setup, theming, and the implementation of the first three screens (Splash, Login, Profile) as Flutter widgets.

## User Review Required

> [!IMPORTANT]
> **Project Restructuring**: I will transform the existing native Android project into a Flutter project. This involves moving current Android files into an `android/` directory and adding Flutter configuration files (`pubspec.yaml`, `lib/`) to the root.

> [!WARNING]
> **Missing Design Images**: Design images (`input_file_8.png`, etc.) were not found in the project. I will implement the UI based on the detailed textual descriptions provided.

## Proposed Changes

### 1. Project Setup (Flutter)
- [NEW] `pubspec.yaml`: Add dependencies: `flutter_localizations`, `google_fonts`, `provider`, `google_maps_flutter`, `intl`.
- [NEW] `codemagic.yaml`: Configure Android APK build using standard Flutter commands.
- [NEW] `lib/main.dart`: Entry point of the Flutter application.

### 2. Theme (lib/core/theme/app_theme.dart)
- Implement a Material 3 `ThemeData`.
- **Colors**: Primary (#1B5E38), Accent (#4CAF50), Surface (#F0F7F0).
- **Typography**: Inter (via Google Fonts).
- **Shapes**: Rounded corners (12-16px) for cards and buttons.

### 3. Localization
- All UI strings will be implemented in **French**.

### 4. Screens (lib/features/...)
- [NEW] **Splash Screen**: White background, logo, "Commencer" button (h=52, r=14), "J'ai déjà un compte" link.
- [NEW] **Login Screen**: Phone input with 🇨🇮, Password, social login buttons (MTN, Orange, Wave).
- [NEW] **Profile Screen**: Header with photo, stats (Trajets, Note, CO2), badges, history, and 5-tab bottom navigation.

### 5. App Icon
- Use `app_icon_agent` to generate an adaptive icon representing "Green Mobility" and "Mobiliti".

## Verification Plan

### Automated Tests
- Run `flutter analyze` to verify code quality.
- Run `flutter build apk --debug` to verify the Android build process.

### Manual Verification
- Verify the UI layout and responsiveness for each screen in the Flutter framework.
