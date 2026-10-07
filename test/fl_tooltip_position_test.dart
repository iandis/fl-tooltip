import 'package:fl_tooltip/fl_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'tooltip_test_harness.dart';

FlTooltipEntryOptions Function(Widget content) _at(Set<FlTooltipPosition> positionOptions) {
  return (content) => FlTooltipEntryOptions(positionOptions: positionOptions, barrier: null, content: content);
}

void main() {
  testWidgets('should go below the target center by default', (tester) async {
    await pumpTooltipHarness(
      tester,
      options: (content) => FlTooltipEntryOptions(barrier: null, content: content),
    );

    expect(tester.getCenter(content).dx, tester.getCenter(target).dx);
    expect(tester.getRect(content).top, greaterThan(tester.getCenter(target).dy));
  });

  testWidgets('should go to the first position option the tooltip fits in', (tester) async {
    final harness = await pumpTooltipHarness(
      tester,
      options: _at(const {
        FlTooltipPosition(direction: AxisDirection.left, alignment: Alignment.centerLeft),
        FlTooltipPosition(direction: AxisDirection.right, alignment: Alignment.centerRight),
        FlTooltipPosition(direction: AxisDirection.down, alignment: Alignment.bottomCenter),
      }),
    );

    // The target ends up at the overlay's left edge: no room on its left, room both on its right and below it.
    await harness.moveTargetTo(tester, const Offset(-350, 0));
    await tester.pump(kFrame);

    expect(tester.getRect(content).left, greaterThanOrEqualTo(tester.getRect(target).right));
    expect(tester.getCenter(content).dy, moreOrLessEquals(tester.getCenter(target).dy, epsilon: 0.5));
  });

  testWidgets('should go to the first position option when the tooltip fits in none', (tester) async {
    final harness = await pumpTooltipHarness(
      tester,
      options: _at(const {
        FlTooltipPosition(direction: AxisDirection.left, alignment: Alignment.centerLeft),
        FlTooltipPosition(direction: AxisDirection.up, alignment: Alignment.topCenter),
      }),
    );

    // The target ends up at the overlay's top left corner: no room on its left, nor above it.
    await harness.moveTargetTo(tester, const Offset(-350, -250));
    await tester.pump(kFrame);

    // On the left of the target's center line, pushed back inside the overlay, rather than above it.
    expect(tester.getCenter(content).dy, moreOrLessEquals(tester.getCenter(target).dy, epsilon: 0.5));
    expect(tester.getRect(content).left, greaterThanOrEqualTo(0));
  });

  testWidgets('should shift the tooltip right of the point it points at with a position of 1.0', (tester) async {
    await pumpTooltipHarness(
      tester,
      options: _at(const {
        FlTooltipPosition(direction: AxisDirection.down, alignment: Alignment.bottomCenter, position: 1.0),
      }),
    );

    // Its left edge is at the middle of the target's bottom edge.
    expect(tester.getRect(content).left, greaterThanOrEqualTo(tester.getCenter(target).dx));
    expect(tester.getRect(content).top, greaterThanOrEqualTo(tester.getRect(target).bottom));
  });

  testWidgets('should shift the tooltip left of the point it points at with a position of -1.0', (tester) async {
    await pumpTooltipHarness(
      tester,
      options: _at(const {
        FlTooltipPosition(direction: AxisDirection.down, alignment: Alignment.bottomCenter, position: -1.0),
      }),
    );

    // Its right edge is at the middle of the target's bottom edge.
    expect(tester.getRect(content).right, lessThanOrEqualTo(tester.getCenter(target).dx));
  });

  testWidgets('should throw when showing a tooltip without position options', (tester) async {
    final tooltipKey = await _pumpWithPositionOptions(tester, <FlTooltipPosition>{});

    expect(() => tooltipKey.currentState!.showTooltip(), throwsA(_isEmptyPositionOptionsError));
    await tester.pump();
    expect(find.byType(FlTooltipEntry), findsNothing);
  });

  test('should throw when creating a tooltip entry without position options', () {
    expect(
      () => FlTooltipEntry.createEntry(
        targetKey: FlTooltipTargetKey(),
        // An empty const set doesn't even compile.
        // ignore: prefer_const_literals_to_create_immutables
        options: FlTooltipEntryOptions(positionOptions: <FlTooltipPosition>{}, content: const SizedBox()),
      ),
      throwsA(_isEmptyPositionOptionsError),
    );
  });

  testWidgets('should throw when the position options of a showing tooltip become empty', (tester) async {
    final positionOptions = ValueNotifier<Set<FlTooltipPosition>>(
      const {FlTooltipPosition(direction: AxisDirection.down, alignment: Alignment.bottomCenter)},
    );
    addTearDown(positionOptions.dispose);
    final tooltipKey = FlTooltipKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ValueListenableBuilder<Set<FlTooltipPosition>>(
            valueListenable: positionOptions,
            builder: (_, positionOptions, __) => FlTooltip(
              key: tooltipKey,
              options: FlTooltipEntryOptions(positionOptions: positionOptions, content: const SizedBox()),
              child: const SizedBox(width: 40, height: 40),
            ),
          ),
        ),
      ),
    );
    tooltipKey.currentState!.showTooltip();
    await tester.pumpAndSettle();

    positionOptions.value = <FlTooltipPosition>{};
    // The tooltip's entry is rebuilt with the new options after the next frame.
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), _isEmptyPositionOptionsError);
  });

  testWidgets('should leave out a position that is the same as an earlier one, and report it', (tester) async {
    // Two equal non-const positions: the set literal keeps both.
    // ignore: prefer_const_constructors
    final below = FlTooltipPosition(direction: AxisDirection.down, alignment: Alignment.bottomCenter);
    // ignore: prefer_const_constructors
    final alsoBelow = FlTooltipPosition(direction: AxisDirection.down, alignment: Alignment.bottomCenter);
    const above = FlTooltipPosition(direction: AxisDirection.up, alignment: Alignment.topCenter);
    final tooltipKey = await _pumpWithPositionOptions(tester, {below, alsoBelow, above});
    tooltipKey.currentState!.showTooltip();
    await tester.pumpAndSettle();

    expect(
      tester.takeException(),
      isA<FlutterError>()
          .having((it) => it.message, 'message', contains('holds the same position twice'))
          .having((it) => it.message, 'message', contains('Position 2 has the same direction, alignment and position')),
    );
    // The tooltip still shows, below the target: the first, preferred position.
    final tooltipEntry = find.byType(FlTooltipEntry);
    expect(tooltipEntry, findsOneWidget);
    expect(
      tester.getTopLeft(find.descendant(of: tooltipEntry, matching: find.byType(SizedBox)).first).dy,
      greaterThanOrEqualTo(tester.getBottomLeft(find.byKey(_target)).dy),
    );
  });

  test('should compare position options by value', () {
    const content = SizedBox();
    FlTooltipEntryOptions optionsWith(List<AxisDirection> directions) {
      return FlTooltipEntryOptions(
        positionOptions: {
          // ignore: prefer_const_constructors
          for (final direction in directions) FlTooltipPosition(direction: direction, alignment: Alignment.center),
        },
        content: content,
      );
    }

    final upThenDown = optionsWith([AxisDirection.up, AxisDirection.down]);

    expect(upThenDown, optionsWith([AxisDirection.up, AxisDirection.down]));
    expect(upThenDown.hashCode, optionsWith([AxisDirection.up, AxisDirection.down]).hashCode);
    // The order is the order of preference.
    expect(upThenDown, isNot(optionsWith([AxisDirection.down, AxisDirection.up])));
  });

  test('should compare position options without their duplicates', () {
    const content = SizedBox();
    // ignore: prefer_const_constructors
    final below = FlTooltipPosition(direction: AxisDirection.down, alignment: Alignment.bottomCenter);
    // ignore: prefer_const_constructors
    final alsoBelow = FlTooltipPosition(direction: AxisDirection.down, alignment: Alignment.bottomCenter);
    const above = FlTooltipPosition(direction: AxisDirection.up, alignment: Alignment.topCenter);

    final withDuplicate = FlTooltipEntryOptions(positionOptions: {below, alsoBelow, above}, content: content);
    final withoutDuplicate = FlTooltipEntryOptions(positionOptions: {below, above}, content: content);

    expect(withDuplicate, withoutDuplicate);
    expect(withDuplicate.hashCode, withoutDuplicate.hashCode);
  });
}

const Key _target = ValueKey('target');

final Matcher _isEmptyPositionOptionsError =
    isA<FlutterError>().having((it) => it.message, 'message', contains('`positionOptions` must not be empty'));

/// Pumps a tooltip with [positionOptions], built without `const` so that Dart doesn't check the set itself.
Future<FlTooltipKey> _pumpWithPositionOptions(WidgetTester tester, Set<FlTooltipPosition> positionOptions) async {
  final tooltipKey = FlTooltipKey();
  await tester.pumpWidget(
    MaterialApp(
      home: Center(
        child: FlTooltip(
          key: tooltipKey,
          options:
              FlTooltipEntryOptions(positionOptions: positionOptions, content: const SizedBox(width: 60, height: 20)),
          child: const SizedBox(key: _target, width: 40, height: 40),
        ),
      ),
    ),
  );
  return tooltipKey;
}
