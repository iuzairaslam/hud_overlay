# hud_overlay

[![pub version](https://img.shields.io/pub/v/hud_overlay.svg)](https://pub.dev/packages/hud_overlay)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![platform](https://img.shields.io/badge/platform-flutter-02569B)](https://flutter.dev)

A context-optional, accessibility-first loading overlay for Flutter.

Show, update, and dismiss loading state from anywhere — widgets, BLoC, Riverpod,
or a plain Dart service — with no `BuildContext` and no boilerplate.

## Features

- **Context-free** — drive overlays from any layer via the static `HudService`.
- **Native `Overlay`** — no root `Stack`, no global wrapper widget required.
- **Stateful** — loading, deterministic progress, success, error, and info.
- **Accessible** — screen-reader announcements, live regions, and a
  `progressBar` semantics role.
- **Customizable** — `HudTheme` with light/dark presets, blur, position,
  custom indicators, and full text styling.
- **Pure Dart** — zero non-SDK dependencies; runs on every Flutter platform.

## Install

```yaml
dependencies:
  hud_overlay: ^0.1.0
```

## Usage

### Widget

```dart
HudOverlay(
  isLoading: _isLoading,
  message: 'Loading…',
  child: MyForm(),
)
```

### Service (context-free)

Register `HudScope` once:

```dart
MaterialApp(
  builder: (context, child) => HudScope(child: child!),
  home: const HomePage(),
)
```

Then call from anywhere:

```dart
HudService.show(message: 'Saving…');
await save();
HudService.showSuccess(message: 'Saved!');
```

### Wrap a Future

```dart
await HudService.wrap(
  api.save(),
  message: 'Saving…',
  successMessage: 'Saved!',
  errorMessage: 'Failed',
);
```

## Theming

```dart
HudOverlay(
  isLoading: _isLoading,
  theme: HudTheme.dark().copyWith(blur: 8),
  child: child,
)
```

`HudTheme` configures the barrier, blur, indicator, card decoration, position,
text styles, animation, haptics, grace period, and minimum show duration.
`HudTheme.light()` and `HudTheme.dark()` provide ready-made presets.

## API

| Type | Purpose |
|---|---|
| `HudOverlay` | Widget that overlays a loading state on its `child`. |
| `HudService` | Static API: `show`, `showSuccess`, `showError`, `showInfo`, `dismiss`, `dismissAll`, `wrap`, `trackStream`. |
| `HudScope` | Registers the global overlay used by `HudService`. |
| `HudTheme` | Visual and behavioral configuration. |
| `HudController` | Low-level controller for advanced cases. |

See the [example](example/) app for a focused, runnable demo of every feature.

## License

[MIT](LICENSE)
