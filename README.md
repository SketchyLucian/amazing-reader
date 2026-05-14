# Minimal Book Reader

A small Flutter reader app with local PDF support for Android, Windows, and web.

## Project docs

- [Documentation index](docs/README.md)
- [MVP UI/UX plan](docs/ui-ux-plan.md)

## Development

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

Windows plugin builds require Windows Developer Mode so Flutter can create
plugin symlinks.

## Performance notes

Use Flutter release builds when checking reader smoothness or battery behavior;
debug builds add substantial framework overhead.

```bash
flutter build web --release
flutter build windows --release
flutter build apk --release
```

For non-web release builds, `pdfrx` can remove unused WASM modules from native
artifacts after dependency resolution:

```bash
dart run pdfrx:remove_wasm_modules
```

Run `flutter pub get` again to restore the package cache before switching back
to web builds or development workflows that need the removed modules.
