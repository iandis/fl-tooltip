import 'package:fl_tooltip/fl_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'tooltip_test_harness.dart';

FlTooltipEntryOptions _options(
  Widget content, {
  FlTooltipEntryBarrier? barrier = const FlTooltipEntryBarrier(),
  Alignment alignment = Alignment.topCenter,
}) {
  return FlTooltipEntryOptions(
    useDryLayout: false,
    alignment: alignment,
    direction: AxisDirection.up,
    alternativeDirections: const {AxisDirection.down},
    barrier: barrier,
    content: content,
  );
}

void main() {
  testWidgets('should keep the tooltip on the target while the target moves', (tester) async {
    final harness = await pumpTooltipHarness(tester, options: _options);
    final start = tester.getCenter(content) - tester.getCenter(target);

    for (var i = 1; i <= 10; i++) {
      await harness.moveTargetTo(tester, Offset(-20.0 * i, 10.0 * i));

      expect(tester.getCenter(content) - tester.getCenter(target), start);
    }
  });

  testWidgets('should keep the tooltip inside the overlay when the target moves next to its edge', (tester) async {
    final harness = await pumpTooltipHarness(tester, options: _options);
    final screen = Offset.zero & screenSizeOf(tester);

    // The target ends up at the overlay's right edge, where a centered tooltip wouldn't fit.
    await harness.moveTargetTo(tester, Offset(screen.width - 80 - 360, 0));
    await tester.pump(kFrame);

    final contentRect = tester.getRect(content);
    expect(contentRect.right, lessThanOrEqualTo(screen.right));
    expect(contentRect.bottom, lessThanOrEqualTo(tester.getRect(target).top));
  });

  testWidgets('should put the tooltip on its alternative side when the target moves too close to the edge', (
    tester,
  ) async {
    // Anchored to the target's center, so that the tooltip is above the target's center on one side and below it on
    // the other.
    final harness = await pumpTooltipHarness(
      tester,
      options: (content) => _options(content, alignment: Alignment.center),
    );
    expect(tester.getCenter(content).dy, lessThan(tester.getCenter(target).dy));

    // The target ends up at the overlay's top edge, with no room for the tooltip above it.
    await harness.moveTargetTo(tester, const Offset(0, -255));
    await tester.pump(kFrame);

    expect(tester.getCenter(content).dy, greaterThan(tester.getCenter(target).dy));
    expect(tester.getRect(content).top, greaterThanOrEqualTo(0));
  });

  testWidgets('should not rebuild the tooltip content while the target moves', (tester) async {
    final harness = await pumpTooltipHarness(tester, options: (content) => _options(content, barrier: null));
    final contentBuildsBefore = harness.contentBuilds;

    for (var i = 1; i <= 10; i++) {
      await harness.moveTargetTo(tester, Offset(-20.0 * i, 10.0 * i));
    }

    expect(harness.contentBuilds, contentBuildsBefore);
  });

  testWidgets('should not throw when a target set with targetKey leaves the tree while the tooltip shows', (
    tester,
  ) async {
    final harness = await pumpTooltipHarness(tester, options: _options, separateTargetKey: true);

    harness.targetInTree.value = false;
    await tester.pumpAndSettle();
    harness.targetInTree.value = true;
    await tester.pumpAndSettle();
    harness.targetInTree.value = false;
    await tester.pumpAndSettle();
    // Something else showing in the same overlay rebuilds the tooltip's entry while its target is gone.
    final otherEntry = OverlayEntry(builder: (_) => const SizedBox.shrink());
    addTearDown(otherEntry.dispose);
    Overlay.of(tester.element(find.byType(Material).first)).insert(otherEntry);
    await tester.pumpAndSettle();
    otherEntry.remove();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
