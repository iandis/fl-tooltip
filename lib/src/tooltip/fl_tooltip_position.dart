part of fl_tooltip;

/// One place a tooltip can go around its target: on which side of the target ([direction]), pointing at which point
/// of the target ([alignment]), and shifted how far along that side ([position]).
///
/// [FlTooltipEntryOptions.positionOptions] lists the places a tooltip may go, in order of preference.
///
/// For example, above the target, with its tail pointing at the middle of the target's top edge:
///
/// ```dart
/// const FlTooltipPosition(direction: AxisDirection.up, alignment: Alignment.topCenter)
/// ```
///
/// Create it with `const` where you can. [FlTooltipPosition] doesn't override `==`, so that a set of them can be
/// `const` (Dart doesn't allow a `const` set of a class that overrides `==`). So a set literal keeps two equal
/// non-`const` positions as two elements, while equal `const` ones are the same instance. fl_tooltip itself compares
/// positions by value: a position that is the same as an earlier one in [FlTooltipEntryOptions.positionOptions] is
/// left out, both when placing the tooltip and when comparing two [FlTooltipEntryOptions], and debug mode reports it.
@immutable
class FlTooltipPosition with Diagnosticable {
  const FlTooltipPosition({
    required this.direction,
    required this.alignment,
    this.position = 0.0,
  });

  /// The side of the target the tooltip goes on, as seen from the point it points at ([alignment]).
  ///
  /// The tail points back at that point:
  /// - [AxisDirection.up]: the tooltip is above that point, its tail pointing down at it;
  /// - [AxisDirection.down]: the tooltip is below that point, its tail pointing up at it;
  /// - [AxisDirection.left]: the tooltip is to the left of that point, its tail pointing right at it;
  /// - [AxisDirection.right]: the tooltip is to the right of that point, its tail pointing left at it.
  ///
  /// For example, below the target:
  ///
  /// ```dart
  /// const FlTooltipPosition(direction: AxisDirection.down, alignment: Alignment.bottomCenter)
  /// ```
  final AxisDirection direction;

  /// The point of the target the tooltip's tail points at, from the target's top left ([Alignment.topLeft]) to its
  /// bottom right ([Alignment.bottomRight]).
  ///
  /// Match it to [direction] to put the tooltip next to the target. With [Alignment.center], the tooltip starts at the
  /// target's center, so it covers the half of the target on [direction]'s side:
  /// - [AxisDirection.up]: [Alignment.topCenter], the middle of the target's top edge;
  /// - [AxisDirection.down]: [Alignment.bottomCenter], the middle of the target's bottom edge;
  /// - [AxisDirection.left]: [Alignment.centerLeft], the middle of the target's left edge;
  /// - [AxisDirection.right]: [Alignment.centerRight], the middle of the target's right edge.
  ///
  /// Any other point works too. For example, below the target's bottom right corner, for a target at the right edge of
  /// the screen:
  ///
  /// ```dart
  /// const FlTooltipPosition(direction: AxisDirection.down, alignment: Alignment.bottomRight)
  /// ```
  ///
  /// The target's size is the one [FlTooltipEntryOptions.useDryLayout] picks.
  final Alignment alignment;

  /// How far the tooltip is shifted along the side it's on, from -1.0 to 1.0, as a fraction of half the tooltip's own
  /// size. Values outside that range are clamped. The tail keeps pointing at [alignment].
  ///
  /// 0.0 (the default) centers the tooltip on the point it points at. Then:
  /// - when [direction] is [AxisDirection.up] or [AxisDirection.down], 1.0 shifts the tooltip right until its left edge
  ///   is at that point, and -1.0 shifts it left until its right edge is at that point;
  /// - when [direction] is [AxisDirection.left] or [AxisDirection.right], 1.0 shifts the tooltip down until its top
  ///   edge is at that point, and -1.0 shifts it up until its bottom edge is at that point.
  ///
  /// The tooltip still stays inside the overlay's edges.
  ///
  /// For example, below the target, hanging to the right of the middle of its bottom edge:
  ///
  /// ```dart
  /// const FlTooltipPosition(direction: AxisDirection.down, alignment: Alignment.bottomCenter, position: 1.0)
  /// ```
  final double position;

  static const FlTooltipPosition topCenter = FlTooltipPosition(direction: AxisDirection.up, alignment: Alignment.topCenter);
  static const FlTooltipPosition bottomCenter = FlTooltipPosition(direction: AxisDirection.down, alignment: Alignment.bottomCenter);
  static const FlTooltipPosition leftCenter = FlTooltipPosition(direction: AxisDirection.left, alignment: Alignment.centerLeft);
  static const FlTooltipPosition rightCenter = FlTooltipPosition(direction: AxisDirection.right, alignment: Alignment.centerRight);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<AxisDirection>('direction', direction))
      ..add(DiagnosticsProperty<Alignment>('alignment', alignment))
      ..add(DoubleProperty('position', position, defaultValue: 0.0));
  }
}

// Value equality for [FlTooltipPosition], which can't override `==` (see its docs).

bool _positionsEqual(FlTooltipPosition a, FlTooltipPosition b) {
  return a.direction == b.direction && a.alignment == b.alignment && a.position == b.position;
}

int _positionHash(FlTooltipPosition position) => Object.hash(position.direction, position.alignment, position.position);

/// [positionOptions] without the positions that are the same, by value, as an earlier one, in the same order: the
/// positions the tooltip actually considers. A set literal of non-`const` positions can hold the same one twice; the
/// first one is kept, which is the one preferred.
///
/// Returns [positionOptions] itself when it holds no duplicate.
Set<FlTooltipPosition> _deduplicatePositions(Set<FlTooltipPosition> positionOptions) {
  // Compares by value, and keeps the order the positions are added in.
  final LinkedHashSet<FlTooltipPosition> deduplicated = LinkedHashSet<FlTooltipPosition>(
    equals: _positionsEqual,
    hashCode: _positionHash,
  )..addAll(positionOptions);
  return deduplicated.length == positionOptions.length ? positionOptions : deduplicated;
}

/// Whether [a] and [b] hold the same positions, by value, in the same order, once their duplicates are left out (see
/// [_deduplicatePositions]): the order is the order of preference (see [FlTooltipEntryOptions.positionOptions]).
bool _positionOptionsEqual(Set<FlTooltipPosition> a, Set<FlTooltipPosition> b) {
  if (identical(a, b)) return true;
  final Set<FlTooltipPosition> dedupedA = _deduplicatePositions(a);
  final Set<FlTooltipPosition> dedupedB = _deduplicatePositions(b);
  if (dedupedA.length != dedupedB.length) return false;
  final Iterator<FlTooltipPosition> other = dedupedB.iterator;
  for (final FlTooltipPosition position in dedupedA) {
    other.moveNext();
    if (!_positionsEqual(position, other.current)) return false;
  }
  return true;
}

/// A hash of [positionOptions] that agrees with [_positionOptionsEqual].
int _positionOptionsHash(Set<FlTooltipPosition> positionOptions) {
  return Object.hashAll(_deduplicatePositions(positionOptions).map(_positionHash));
}

/// Throws when [positionOptions] is empty: the tooltip would have nowhere to go. This also throws in release mode.
///
/// An empty `const` set doesn't even compile (see [FlTooltipEntryOptions]), but a non-`const` one does.
void _checkPositionOptionsNotEmpty(Set<FlTooltipPosition> positionOptions) {
  if (positionOptions.isEmpty) {
    throw FlutterError('`positionOptions` must not be empty: the tooltip has nowhere to go.');
  }
}

/// Reports, through [FlutterError.reportError] and without throwing, the positions of [positionOptions] that are the
/// same, by value, as an earlier one: the tooltip leaves them out (see [_deduplicatePositions]) and still works.
///
/// Returns true, so that it's called in an `assert`: the check only runs in debug mode.
bool _debugReportDuplicatePositions(Set<FlTooltipPosition> positionOptions) {
  assert(() {
    final LinkedHashSet<FlTooltipPosition> kept = LinkedHashSet<FlTooltipPosition>(
      equals: _positionsEqual,
      hashCode: _positionHash,
    );
    final List<FlTooltipPosition> positions = positionOptions.toList();
    final List<DiagnosticsNode> duplicates = <DiagnosticsNode>[];
    for (int index = 0; index < positions.length; index++) {
      if (kept.add(positions[index])) continue;
      final FlTooltipPosition first = kept.lookup(positions[index])!;
      duplicates.add(ErrorDescription(
        'Position ${index + 1} has the same direction, alignment and position as position '
        '${positions.indexWhere((it) => identical(it, first)) + 1}, so it was left out.',
      ));
    }
    if (duplicates.isEmpty) return true;
    FlutterError.reportError(FlutterErrorDetails(
      exception: FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('`positionOptions` holds the same position twice.'),
        ...duplicates,
        ErrorHint(
          'A set literal keeps equal non-const FlTooltipPosition values as separate elements. Remove the duplicate, '
          'or create the positions with `const` so that equal ones are the same instance.',
        ),
      ]),
      library: 'fl_tooltip',
      context: ErrorDescription('while placing a tooltip'),
    ));
    return true;
  }());
  return true;
}
