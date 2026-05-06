# Agent Instructions

## Goal

Build a Flutter app for Android, Windows, and web from one shared codebase. Use platform-specific code only behind plugins or small adapters.

## Default Stack

- Framework: Flutter
- Language: Dart
- UI: Material 3
- State/DI: Riverpod
- Routing: go_router
- HTTP: dio for real APIs; use Dart/Flutter built-ins for simple cases
- Local data: Drift/SQLite only when structured offline data is needed
- Serialization: json_serializable or freezed when typed generated models are useful
- Tests: flutter_test, integration_test, and unit tests for domain logic

Use Rust only for isolated performance-critical or shared-core modules. Do not put normal app logic in Rust.

## Project Structure

Prefer feature-first organization:

```text
lib/
  app/        # app setup, router, theme
  core/       # shared infrastructure
  features/
    feature_name/
      data/
      domain/
      presentation/
```

- `presentation`: widgets, screens, UI providers/controllers
- `domain`: business types, validation, pure logic
- `data`: API clients, DTOs, database access, repositories
- `core`: shared infrastructure only

Keep files close to the feature that owns them. Avoid global utility dumping grounds.

## Platform Rules

The app must support Android, Windows, and web. Before adding any package, confirm support for all three targets or isolate it behind a platform adapter.

Always consider:

- Android back button and permissions
- Windows window size, keyboard, mouse, and file paths
- Web refresh, URLs, deep links, CORS, browser storage, and responsive layout

ChromeOS support should come through the Android app and/or web app unless explicitly required otherwise.

## Coding Conventions

- Prefer simple, readable Dart over clever abstractions.
- Keep widgets and providers small.
- Use clear names and immutable state.
- Keep async UI states explicit: loading, data, empty, error.
- Keep API/storage details out of widgets.
- Translate low-level failures into user-safe messages at the UI boundary.
- Add comments only for non-obvious rationale, caveats, or invariants.
- Avoid premature abstraction and unused dependencies.

## UI Conventions

Build the real app screen first, not a marketing landing page. Use responsive layouts that work on phone, tablet, desktop, and browser widths.

Prefer adaptive layouts, accessible tap targets, keyboard-friendly desktop/web behavior, and restrained functional styling. Avoid text overflow, duplicated platform screens, and card-heavy layouts when lists, tables, or split panes are clearer.

## Verification

Before finishing a change, run what applies:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

For platform-sensitive work, also run or build the affected targets:

```bash
flutter run -d chrome
flutter run -d windows
flutter run -d android
flutter build web --release
flutter build windows --release
flutter build appbundle --release
```

