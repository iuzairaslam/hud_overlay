# Changelog

## 0.1.1

- Fix `homepage`, `repository`, and `issue_tracker` URLs in `pubspec.yaml`.

## 0.1.0

Initial release.

### Core

- **Context-optional API** — `HudService` shows/dismisses overlays from
  anywhere (BLoC, Riverpod, service layers) with no `BuildContext`, while the
  `HudOverlay` widget covers any subtree when you prefer a context-aware API.
- **`HudScope`** hosts its own `Overlay`, so it works regardless of placement.
- **Loading states** — indeterminate spinner, deterministic `progress`, and
  success / error / info transitions.
- **Helpers** — `wrap()` shows a spinner for the lifetime of a `Future` and
  flips to success/error automatically; `trackStream()` drives determinate
  progress from a `Stream<double>`.
- **Named-key stacking** — multiple independent overlays via `key`, plus
  `dismissAll()`.
- **Navigation auto-dismiss** via `HudService.navigatorObserver` +
  `HudScope.autoDismissOnNavigation`.

### Customization

- **`HudTheme`** controls barrier color, blur (frosted glass), card decoration
  and padding, indicator, position (top/center/bottom), animation duration and
  curve, and `messageStyle` / `detailStyle` text styling.
- **Theme presets** — `HudTheme.light()` and `HudTheme.dark()` factory
  constructors, composable with `copyWith`.
- **Custom state widgets** — `successWidget`, `errorWidget`, `infoWidget`.
- **Secondary detail line** — `detail` on `HudOverlay`, `HudService.show`,
  `HudOverlayContent`, and `HudStatus`.
- **Cancel button** — `onCancel` + `cancelLabel`, styled via
  `HudTheme.cancelButtonStyle`.

### Behavior

- **Grace period** — `HudTheme.gracePeriod` delays the fade-in so very fast
  operations never flash; a dismiss during the grace window cancels silently.
- **Minimum show duration** — `HudTheme.minShowDuration` prevents flicker by
  keeping the overlay up for a minimum time once shown.
- **Length-based auto-dismiss** — when `autoDismiss` is omitted for
  success/error/info, the duration is derived from the message length (floored
  at 1.5 s, capped at 5 s).
- **Haptic feedback** — `HudTheme.enableHaptics` fires a light impact on
  success/info and a heavy impact on error.
- **Interactive (non-blocking) mode** — `HudTheme.interactive` lets touches
  pass through to the UI beneath the overlay.

### Accessibility

- First-class semantics: screen-reader announcements, `liveRegion`, and a
  `SemanticsRole.progressBar` (with value/min/max) for determinate progress.
