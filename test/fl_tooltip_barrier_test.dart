import 'package:fl_tooltip/fl_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'tooltip_test_harness.dart';

const Color _barrierColor = Color(0x99000000);
const EdgeInsets _holePadding = EdgeInsets.all(8);

FlTooltipEntryOptions _spotlightOptions(
  Widget content, {
  bool dismissible = false,
  bool allowTargetInteraction = false,
  WidgetBuilder? decorationBuilder,
}) {
  return FlTooltipEntryOptions(
    useDryLayout: false,
    // Above the target, clear of the spotlight.
    alignment: Alignment.topCenter,
    direction: AxisDirection.up,
    barrier: FlTooltipEntryBarrier(
      color: _barrierColor,
      dismissible: dismissible,
      spotlight: FlTooltipSpotlight(
        padding: _holePadding,
        allowTargetInteraction: allowTargetInteraction,
        decorationBuilder: decorationBuilder,
      ),
    ),
    content: content,
  );
}

void main() {
  testWidgets('should keep the barrier over the whole overlay while the target moves', (tester) async {
    final harness = await pumpTooltipHarness(tester, options: _spotlightOptions);
    final screen = Offset.zero & screenSizeOf(tester);

    for (var i = 1; i <= 10; i++) {
      await harness.moveTargetTo(tester, Offset(-25.0 * i, 15.0 * i));

      expect(tester.getRect(barrierLook), screen);
    }
  });

  testWidgets('should keep the spotlight on the target on every frame while the target moves', (tester) async {
    final harness = await pumpTooltipHarness(tester, options: _spotlightOptions);
    await expectSpotlightOnTarget(tester);

    for (var i = 1; i <= 10; i++) {
      await harness.moveTargetTo(tester, Offset(-25.0 * i, 15.0 * i));

      await expectSpotlightOnTarget(tester);
      await expectDimmedAt(tester, holeRectOf(tester, _holePadding).topLeft - const Offset(4, 4));
    }
  });

  testWidgets('should not rebuild the barrier or the tooltip content while the target moves', (tester) async {
    var barrierBuilds = 0;
    final harness = await pumpTooltipHarness(
      tester,
      options: (content) => FlTooltipEntryOptions(
        useDryLayout: false,
        barrier: FlTooltipEntryBarrier.custom(
          dismissible: false,
          builder: (context, color) {
            barrierBuilds++;
            return ColoredBox(color: color);
          },
          spotlight: const FlTooltipSpotlight(padding: _holePadding),
        ),
        content: content,
      ),
    );
    final contentBuildsBefore = harness.contentBuilds;
    final barrierBuildsBefore = barrierBuilds;

    for (var i = 1; i <= 10; i++) {
      await harness.moveTargetTo(tester, Offset(-25.0 * i, 15.0 * i));
    }

    expect(barrierBuilds, barrierBuildsBefore);
    expect(harness.contentBuilds, contentBuildsBefore);
  });

  testWidgets('should not let gestures through the spotlight or the barrier when the barrier is not dismissible', (
    tester,
  ) async {
    final harness = await pumpTooltipHarness(tester, options: _spotlightOptions);

    await tester.tapAt(tester.getCenter(target));
    await tester.tapAt(const Offset(20, 20));
    await tester.dragFrom(tester.getCenter(target), const Offset(0, -100));
    await tester.pumpAndSettle();

    expect(harness.targetTaps, 0);
    expect(harness.behindTaps, 0);
    expect(harness.isShowing, isTrue);
  });

  testWidgets('should not let gestures through a custom barrier look that does not take gestures', (tester) async {
    final harness = await pumpTooltipHarness(
      tester,
      options: (content) => FlTooltipEntryOptions(
        useDryLayout: false,
        barrier: FlTooltipEntryBarrier.custom(
          dismissible: false,
          builder: (context, color) => IgnorePointer(child: ColoredBox(color: color)),
          spotlight: const FlTooltipSpotlight(padding: _holePadding),
        ),
        content: content,
      ),
    );

    await tester.tapAt(tester.getCenter(target));
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(harness.targetTaps, 0);
    expect(harness.behindTaps, 0);
  });

  testWidgets('should let gestures in the spotlight reach the target when the spotlight allows target interaction', (
    tester,
  ) async {
    final harness = await pumpTooltipHarness(
      tester,
      options: (content) => _spotlightOptions(content, allowTargetInteraction: true),
    );

    await tester.tapAt(tester.getCenter(target));
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(harness.targetTaps, 1);
    expect(harness.behindTaps, 0);
  });

  testWidgets('should let gestures in the spotlight reach the target after the target moved', (tester) async {
    final harness = await pumpTooltipHarness(
      tester,
      options: (content) => _spotlightOptions(content, allowTargetInteraction: true),
    );
    await harness.moveTargetTo(tester, const Offset(-200, 120));
    await tester.pumpAndSettle();

    await tester.tapAt(tester.getCenter(target));
    await tester.pumpAndSettle();

    expect(harness.targetTaps, 1);
  });

  testWidgets('should dismiss the tooltip on a tap in the spotlight when the barrier is dismissible', (tester) async {
    final harness = await pumpTooltipHarness(tester, options: (content) => _spotlightOptions(content, dismissible: true));

    await tester.tapAt(tester.getCenter(target));
    await tester.pumpAndSettle();

    expect(harness.isShowing, isFalse);
    expect(harness.targetTaps, 0);
  });

  testWidgets('should keep the spotlight decoration over the spotlight while the target moves', (tester) async {
    const decorationKey = ValueKey('decoration');
    final harness = await pumpTooltipHarness(
      tester,
      options: (content) => _spotlightOptions(
        content,
        decorationBuilder: (_) => const DecoratedBox(
          key: decorationKey,
          decoration: BoxDecoration(border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2))),
        ),
      ),
    );
    expect(tester.getRect(find.byKey(decorationKey)), holeRectOf(tester, _holePadding));

    for (var i = 1; i <= 5; i++) {
      await harness.moveTargetTo(tester, Offset(-30.0 * i, 20.0 * i));

      expect(tester.getRect(find.byKey(decorationKey)), holeRectOf(tester, _holePadding));
    }
  });

  testWidgets('should hide the barrier while the target is not on screen', (tester) async {
    final harness = await pumpTooltipHarness(
      tester,
      options: _spotlightOptions,
      separateTargetKey: true,
    );

    harness.targetInTree.value = false;
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(harness.behindTaps, 1);
  });
}
