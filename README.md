## FlTooltip

Flutter package for showing tooltip using Flutter's Overlay widget.

## Getting Started

1. Add dependency to `pubspec.yaml`

```yaml
dependencies:
  fl_tooltip: <latest-version>
```

2. Import the package

```dart
import 'package:fl_tooltip/fl_tooltip.dart';
```

3. Wrap the target widget with `FlTooltip`

```dart
final FlTooltipKey tooltipKey = FlTooltipKey();

FlTooltip(
  key: tooltipKey,
  options: FlTooltipEntryOptions(
    ...
  ),
  content: SomeTooltipContent(),
  child: SomeWidget(),
)
```

4. Show the tooltip

```dart
void showTooltip() {
  tooltipKey.currentState?.showTooltip();
}
```

## Creating FlTooltipEntry without FlTooltip
It's possible to show tooltip without using `FlTooltip` widget. This is useful when you want to show tooltip directly from a method, for example, tooltip for tutorials.

In order to do that, we just need to wrap the target widget with `FlTooltipTarget`.
```dart
final FlTooltipTargetKey targetKey = FlTooltipTargetKey();

FlTooltipTarget(
  key: targetKey, // <- this is required
  child: SomeWidget(),
)

FlTooltipOverlayEntry? entry;
void showTooltip() {
  entry = FlTooltipEntry.showTooltip({
    targetKey: targetKey,
    options: FlTooltipEntryOptions(
      ...
    ),
  });
}

void dismissTooltip() {
  entry?.dismiss();
  entry = null;
}
```

## Customizing FlTooltip Themes
`FlTooltipTheme` are customizable via [ThemeExtension](https://api.flutter.dev/flutter/material/ThemeExtension-class.html).
Example:
```dart
MaterialApp(
  theme: ThemeData(
    extensions: <ThemeExtension<dynamic>>[
      FlTooltipTheme(
        ...
      ),
    ],
  ),
)
```