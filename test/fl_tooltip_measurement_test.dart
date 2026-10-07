import 'package:fl_tooltip/fl_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const Key _contentKey = ValueKey('content');
const Key _targetKey = ValueKey('target');

/// Shows a tooltip below [target], laid out by [layout], with [useDryLayout] (or the default when null).
Future<void> _showTooltip(
  WidgetTester tester, {
  required Widget target,
  required Widget Function(Widget tooltip) layout,
  bool? useDryLayout,
  FlTooltipEntryBarrier? barrier,
}) async {
  final tooltipKey = FlTooltipKey();
  const content = SizedBox(key: _contentKey, width: 100, height: 30);
  final FlTooltipEntryOptions options = useDryLayout == null
      ? FlTooltipEntryOptions(barrier: barrier, content: content)
      : FlTooltipEntryOptions(useDryLayout: useDryLayout, barrier: barrier, content: content);
  await tester.pumpWidget(
    MaterialApp(
      home: Material(
        child: layout(
          FlTooltip(key: tooltipKey, options: options, child: KeyedSubtree(key: _targetKey, child: target)),
        ),
      ),
    ),
  );
  tooltipKey.currentState!.showTooltip();
  await tester.pumpAndSettle();
}

/// A tooltip target stretched to the width of a 300 wide row.
Widget _stretched(Widget tooltip) {
  return Center(child: SizedBox(width: 300, child: Row(children: [Expanded(child: tooltip)])));
}

/// A tooltip target at the top of a column, as wide as the screen.
Widget _inColumn(Widget tooltip) {
  return Padding(padding: const EdgeInsets.only(top: 200), child: Column(children: [tooltip]));
}

double _bubbleCenterX(WidgetTester tester) => tester.getCenter(find.byKey(_contentKey)).dx;

void main() {
  test('should point at the size the target is laid out at by default', () {
    expect(const FlTooltipEntryOptions(content: SizedBox()).useDryLayout, isFalse);
  });

  testWidgets('should point at the middle of a stretched target by default', (tester) async {
    await _showTooltip(tester, target: const Text('Label'), layout: _stretched);

    expect(_bubbleCenterX(tester), tester.getCenter(find.byKey(_targetKey)).dx);
  });

  testWidgets('should point at the middle of a stretched target content with useDryLayout', (tester) async {
    await _showTooltip(tester, target: const Text('Label'), layout: _stretched, useDryLayout: true);

    final targetLeft = tester.getTopLeft(find.byKey(_targetKey)).dx;
    // The text's box is stretched too: "Label" itself is as wide as the text's intrinsic width.
    final labelWidth = tester.renderObject<RenderBox>(find.text('Label')).getMaxIntrinsicWidth(double.infinity);
    expect(_bubbleCenterX(tester), moreOrLessEquals(targetLeft + labelWidth / 2, epsilon: 0.5));
    expect(_bubbleCenterX(tester), lessThan(tester.getCenter(find.byKey(_targetKey)).dx));
  });

  testWidgets('should measure a text field as it is laid out with useDryLayout', (tester) async {
    await _showTooltip(tester, target: const TextField(), layout: _inColumn, useDryLayout: true);

    expect(tester.takeException(), isNull);
    expect(_bubbleCenterX(tester), tester.getCenter(find.byKey(_targetKey)).dx);
  });

  testWidgets('should measure a row with an expanded child as it is laid out with useDryLayout', (tester) async {
    await _showTooltip(
      tester,
      target: const Row(children: [Icon(Icons.info), Expanded(child: Text('Label'))]),
      layout: _inColumn,
      useDryLayout: true,
    );

    expect(tester.takeException(), isNull);
    expect(_bubbleCenterX(tester), tester.getCenter(find.byKey(_targetKey)).dx);
  });

  testWidgets('should measure a text cut short with an ellipsis as it is drawn with useDryLayout', (tester) async {
    await _showTooltip(
      tester,
      target: Text('A label much longer than its room ' * 4, maxLines: 1, overflow: TextOverflow.ellipsis),
      layout: _stretched,
      useDryLayout: true,
    );

    expect(_bubbleCenterX(tester), moreOrLessEquals(tester.getCenter(find.byKey(_targetKey)).dx, epsilon: 0.5));
  });

  testWidgets('should size the spotlight decoration like the spotlight with useDryLayout', (tester) async {
    const decorationKey = ValueKey('decoration');
    const padding = EdgeInsets.all(8);
    final width = ValueNotifier<double>(300);
    addTearDown(width.dispose);
    await _showTooltip(
      tester,
      // Stretched to the box, but naturally only as big as "Label".
      target: const Text('Label'),
      layout: (tooltip) => Center(
        child: ValueListenableBuilder<double>(
          valueListenable: width,
          builder: (_, width, child) => SizedBox(width: width, height: 40, child: child),
          child: tooltip,
        ),
      ),
      useDryLayout: true,
      barrier: FlTooltipEntryBarrier(
        dismissible: false,
        spotlight: FlTooltipSpotlight(
          padding: padding,
          decorationBuilder: (_) => const SizedBox.expand(key: decorationKey),
        ),
      ),
    );
    expect(tester.getRect(find.byKey(decorationKey)), padding.inflateRect(tester.getRect(find.byKey(_targetKey))));

    // The target gets narrower while the tooltip shows.
    width.value = 200;
    await tester.pumpAndSettle();

    expect(tester.getRect(find.byKey(decorationKey)), padding.inflateRect(tester.getRect(find.byKey(_targetKey))));
  });
}
