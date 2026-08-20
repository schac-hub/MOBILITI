# Fix Flutter Analyze and AGP 9.0 Compatibility

The goal is to fix all Dart analysis errors and resolve the Android build failures caused by the transition to Android Gradle Plugin (AGP) 9.0.

## User Review Required

> [!IMPORTANT]
> The project is using **AGP 9.0.1**, which introduces breaking changes in how Kotlin is supported. The `org.jetbrains.kotlin.android` plugin is now built-in and must be removed from the configuration. Additionally, some dependencies (like `stripe_android`) may fail because they lack an explicit `compileSdk` value required by AGP 9.0.

## Proposed Changes

### Android Configuration

#### [MODIFY] [settings.gradle.kts](file:///C:/Users/DIGIFEMMES-22LAB234/Downloads/MOBILITI-Schac/MOBILITI-Schac/android/settings.gradle.kts)
- Remove `id("org.jetbrains.kotlin.android")` from the `plugins` block as it is now built-in for AGP 9.0+.

#### [MODIFY] [build.gradle.kts](file:///C:/Users/DIGIFEMMES-22LAB234/Downloads/MOBILITI-Schac/MOBILITI-Schac/android/build.gradle.kts)
- Add a `subprojects` configuration to force `compileSdk` on all subprojects (like `stripe_android`) to satisfy AGP 9.0 requirements.

### Dart Code Analysis

#### [SCAN] All `.dart` files
- Run a deep analysis to find any hidden issues not caught by the initial `analyze_file` calls.
- Fix common lints: unused imports, deprecated members, etc.

## Verification Plan

### Automated Tests
- Run `flutter analyze` (if path issue is resolved) or manually inspect problematic files.
- Attempt a mock build or check if Gradle configuration is valid.

### Manual Verification
- Check that the `settings.gradle.kts` and `build.gradle.kts` files are correctly formatted for Kotlin DSL.
