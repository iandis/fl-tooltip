import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fl_tooltip/fl_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// One frame at 60 Hz.
const Duration kFrame = Duration(milliseconds: 16);

/// The target the tooltip points at.
final Finder target = find.byKey(_targetKey);

/// The tooltip's content.
final Finder content = find.byKey(_contentKey);

/// The barrier's default look.
final Finder barrierLook = find.descendant(of: find.byType(FlTooltipEntry), matching: find.byType(ColoredBox));

const Key _targetKey = ValueKey('target');
const Key _contentKey = ValueKey('content');
const Key _screenKey = ValueKey('screen');
const Key _appKey = ValueKey('app');

/// The size of the test screen, which is the size of the [Overlay] the tooltip is in.
Size screenSizeOf(WidgetTester tester) => tester.view.physicalSize / tester.view.devicePixelRatio;

/// A tooltip on a target that the test moves with [targetOffset], over a widget that counts the taps it gets.
class TooltipHarness {
  TooltipHarness._(this.tooltipKey, this.targetOffset);

  final FlTooltipKey tooltipKey;

  /// Moves the target by painting it somewhere else, the way a route transition or a scroll does: neither the target
  /// nor the tooltip is rebuilt or laid out again.
  final ValueNotifier<Offset> targetOffset;

  int targetTaps = 0;
  int behindTaps = 0;
  int contentBuilds = 0;

  /// Whether the target is in the tree. See [pumpTooltipHarness].
  late final ValueNotifier<bool> targetInTree;

  bool get isShowing => tooltipKey.currentState!.isShowing;

  /// Moves the target to [offset] and draws a frame.
  Future<void> moveTargetTo(WidgetTester tester, Offset offset) async {
    targetOffset.value = offset;
    await tester.pump(kFrame);
  }
}

/// Pumps a tooltip with [options] on an 80 × 80 target at [targetPosition], and shows it.
///
/// With [separateTargetKey], the [FlTooltip] wraps the whole screen and points at the target through
/// [FlTooltip.targetKey], so that the target can leave the tree (see [TooltipHarness.targetInTree]) while the tooltip
/// shows.
Future<TooltipHarness> pumpTooltipHarness(
  WidgetTester tester, {
  required FlTooltipEntryOptions Function(Widget content) options,
  Offset targetPosition = const Offset(360, 260),
  bool separateTargetKey = false,
}) async {
  final harness = TooltipHarness._(FlTooltipKey(), ValueNotifier<Offset>(Offset.zero));
  harness.targetInTree = ValueNotifier<bool>(true);
  addTearDown(harness.targetOffset.dispose);
  addTearDown(harness.targetInTree.dispose);
  final FlTooltipTargetKey? targetKey = separateTargetKey ? FlTooltipTargetKey() : null;

  final tooltipContent = Builder(
    builder: (context) {
      harness.contentBuilds++;
      return const SizedBox(key: _contentKey, width: 120, height: 40);
    },
  );
  final Widget targetBox = GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => harness.targetTaps++,
    child: const ColoredBox(key: _targetKey, color: Color(0xFF2E7D32), child: SizedBox(width: 80, height: 80)),
  );

  Widget positionedTarget(Widget child) {
    return Positioned(
      left: targetPosition.dx,
      top: targetPosition.dy,
      child: ValueListenableBuilder<Offset>(
        valueListenable: harness.targetOffset,
        builder: (_, offset, child) => Transform.translate(offset: offset, child: child),
        child: child,
      ),
    );
  }

  Widget screen = Stack(
    children: [
      Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => harness.behindTaps++,
          child: const ColoredBox(color: Color(0xFFFFF3E0)),
        ),
      ),
      if (targetKey == null)
        positionedTarget(FlTooltip(key: harness.tooltipKey, options: options(tooltipContent), child: targetBox))
      else
        positionedTarget(
          ValueListenableBuilder<bool>(
            valueListenable: harness.targetInTree,
            builder: (_, inTree, child) => inTree ? child! : const SizedBox(width: 80, height: 80),
            child: FlTooltipTarget(key: targetKey, child: targetBox),
          ),
        ),
    ],
  );
  if (targetKey != null) {
    screen = FlTooltip(key: harness.tooltipKey, targetKey: targetKey, options: options(tooltipContent), child: screen);
  }

  await tester.pumpWidget(
    RepaintBoundary(
      key: _screenKey,
      child: MaterialApp(
        home: RepaintBoundary(key: _appKey, child: Material(child: screen)),
      ),
    ),
  );
  harness.tooltipKey.currentState!.showTooltip();
  await tester.pumpAndSettle();
  return harness;
}

/// The hole a [FlTooltipSpotlight] with [padding] cuts around the target.
Rect holeRectOf(WidgetTester tester, EdgeInsets padding) => padding.inflateRect(tester.getRect(target));

/// Expects the screen to show the target as the app under the tooltip shows it, at its center and just inside its
/// edges: the spotlight is there, so the barrier neither dims nor blurs it.
Future<void> expectSpotlightOnTarget(WidgetTester tester) async {
  final targetRect = tester.getRect(target);
  final (screenImage, appImage) = (await tester.runAsync(
    () async => (
      await _Pixels.of(tester.renderObject<RenderRepaintBoundary>(find.byKey(_screenKey))),
      await _Pixels.of(tester.renderObject<RenderRepaintBoundary>(find.byKey(_appKey))),
    ),
  ))!;
  const inset = 4.0;
  for (final point in [
    targetRect.center,
    Offset(targetRect.left + inset, targetRect.center.dy),
    Offset(targetRect.right - inset, targetRect.center.dy),
    Offset(targetRect.center.dx, targetRect.top + inset),
    Offset(targetRect.center.dx, targetRect.bottom - inset),
  ]) {
    expect(
      screenImage.at(point).isCloseTo(appImage.at(point)),
      isTrue,
      reason: 'The screen should show the target ($targetRect) at $point as the app does (${appImage.at(point)}), '
          'not ${screenImage.at(point)}.',
    );
  }
}

/// Expects the barrier to dim the screen at [point]: the screen is much darker there than the app under the tooltip.
Future<void> expectDimmedAt(WidgetTester tester, Offset point) async {
  final (screenImage, appImage) = (await tester.runAsync(
    () async => (
      await _Pixels.of(tester.renderObject<RenderRepaintBoundary>(find.byKey(_screenKey))),
      await _Pixels.of(tester.renderObject<RenderRepaintBoundary>(find.byKey(_appKey))),
    ),
  ))!;
  final onScreen = screenImage.at(point);
  final inApp = appImage.at(point);
  expect(
    onScreen.sum < inApp.sum * 0.7,
    isTrue,
    reason: 'The barrier should dim the screen at $point ($inApp), not show $onScreen.',
  );
}

/// The pixels of a [RenderRepaintBoundary], one per logical pixel.
class _Pixels {
  const _Pixels._(this._bytes, this._width, this._height);

  static Future<_Pixels> of(RenderRepaintBoundary boundary) async {
    final ui.Image image = await boundary.toImage();
    final ByteData bytes = (await image.toByteData())!;
    final pixels = _Pixels._(bytes, image.width, image.height);
    image.dispose();
    return pixels;
  }

  final ByteData _bytes;
  final int _width;
  final int _height;

  _Rgba at(Offset point) {
    final x = point.dx.floor().clamp(0, _width - 1);
    final y = point.dy.floor().clamp(0, _height - 1);
    final i = (y * _width + x) * 4;
    return _Rgba(_bytes.getUint8(i), _bytes.getUint8(i + 1), _bytes.getUint8(i + 2));
  }
}

class _Rgba {
  const _Rgba(this.r, this.g, this.b);

  final int r;
  final int g;
  final int b;

  int get sum => r + g + b;

  /// Within anti-aliasing differences. A barrier dims what it covers far more than this.
  bool isCloseTo(_Rgba other) =>
      (r - other.r).abs() <= 24 && (g - other.g).abs() <= 24 && (b - other.b).abs() <= 24;

  @override
  String toString() => 'rgb($r, $g, $b)';
}
