part of fl_tooltip;

typedef TailBuilder = Path Function(
  Offset point1,
  Offset point2,
  Offset point3,
);

typedef BarrierBuilder = Widget Function(
  BuildContext context,
  Color barrierColor,
);

@immutable
class FlTooltipEntryOptions with Diagnosticable {
  const FlTooltipEntryOptions({
    this.useDryLayout = false,
    this.positionOptions = const <FlTooltipPosition>{
      FlTooltipPosition(direction: AxisDirection.down, alignment: Alignment.center),
    },
    this.transitionsBuilder,
    this.margin,
    this.contentPadding,
    this.edgePadding,
    this.elevation,
    this.borderRadius,
    this.tailLength,
    this.tailBaseWidth,
    this.tailBuilder,
    this.barrier = const FlTooltipEntryBarrier(),
    this.dismissOptions,
    this.backgroundColor,
    this.textDirection,
    this.shadow,
    this.showWhenUnlinked = false,
    required this.content,
  }) : assert(positionOptions != const <FlTooltipPosition>{}, '`positionOptions` must not be empty');

  /// Whether the tooltip points at the target's natural size instead of the size the target is laid out at.
  ///
  /// The tooltip is anchored to the center of the target. That center is the target's top left plus half of:
  /// - when false (the default), the target's laid out size, [RenderBox.size]: the box the target takes up on screen;
  /// - when true, the size the target would be with the room its parent gives it, without being stretched to fill it:
  ///   [RenderBox.getDryLayout] with the target's own constraints, loosened (its natural size). Nothing is actually
  ///   laid out for it.
  ///
  /// The two only differ when the target's parent stretches it past its natural size, and the target doesn't fill
  /// the room it's given by itself. For example, with `Row(children: [Expanded(child: FlTooltip(child: Text('Label')))])`,
  /// the target's box is as wide as the row: when false, the tooltip points at the middle of the row; when true, at
  /// the middle of "Label".
  ///
  /// A target that fills the room it's given (e.g. a [Row] with the default [MainAxisSize.max], an [Align], a
  /// `TextField`) fills it when it's measured too, so true points at the same place as false. A text that wraps, or
  /// that is cut short with an ellipsis, is measured the way it's drawn.
  ///
  /// For example, a `TextField` has no natural width: it always fills the width it's given.
  /// - With `Column(children: [FlTooltip(child: TextField())])`, both point at the middle of the field, which is as
  ///   wide as the column.
  /// - With `FlTooltip(child: SizedBox(width: 200, child: TextField()))`, both point at the middle of the 200 wide
  ///   field.
  ///
  /// When true, the target's content is assumed to sit at the top left of its box, so a stretched target that centers
  /// or right-aligns its content (e.g. `Expanded(child: FlTooltip(child: Center(child: Text('Label'))))` with a [Row]
  /// that doesn't fill its width) gets the wrong anchor. Leave this false for such a target.
  ///
  /// For a target that isn't stretched (e.g. an [Icon], a fixed-size button), both give the same anchor.
  final bool useDryLayout;

  /// Where the tooltip may go around its target, in order of preference. Must not be empty: showing the tooltip
  /// throws otherwise. A position that is the same as an earlier one, by value, is left out, both when placing the
  /// tooltip and when comparing two [FlTooltipEntryOptions]. Debug mode also reports it (see [FlTooltipPosition] on
  /// equality).
  ///
  /// The tooltip goes to the first one it fits in. It fits in one when, kept inside the [Overlay]'s edges (less
  /// [margin] and [edgePadding]), it doesn't have to be pushed back over the point it points at
  /// ([FlTooltipPosition.alignment]). When it fits in none, it goes to the first one, kept inside the [Overlay]'s edges
  /// as far as it can be. Each one has its own [FlTooltipPosition.alignment] and [FlTooltipPosition.position], so the
  /// tooltip can point at a different point of the target on each side.
  ///
  /// The tooltip is placed again whenever the target moves, so it can switch to another one while it shows (e.g. while
  /// the target scrolls towards the overlay's edge).
  ///
  /// Use a set literal (`{...}`), which keeps the order it's written in. Defaults to below the target's center:
  /// `{FlTooltipPosition(direction: AxisDirection.down, alignment: Alignment.center)}`.
  ///
  /// For example, above the target, or below it when there's no room above:
  ///
  /// ```dart
  /// positionOptions: const {
  ///   FlTooltipPosition(direction: AxisDirection.up, alignment: Alignment.topCenter),
  ///   FlTooltipPosition(direction: AxisDirection.down, alignment: Alignment.bottomCenter),
  /// },
  /// ```
  ///
  /// To the right of the target, else to its left, else below it:
  ///
  /// ```dart
  /// positionOptions: const {
  ///   FlTooltipPosition(direction: AxisDirection.right, alignment: Alignment.centerRight),
  ///   FlTooltipPosition(direction: AxisDirection.left, alignment: Alignment.centerLeft),
  ///   FlTooltipPosition(direction: AxisDirection.down, alignment: Alignment.bottomCenter),
  /// },
  /// ```
  ///
  /// Below the target, hanging to the right of the middle of its bottom edge, as with a menu opened from the target's
  /// left edge:
  ///
  /// ```dart
  /// positionOptions: const {
  ///   FlTooltipPosition(direction: AxisDirection.down, alignment: Alignment.bottomCenter, position: 1.0),
  /// },
  /// ```
  final Set<FlTooltipPosition> positionOptions;

  final FlTooltipTransitionsBuilder? transitionsBuilder;

  /// The margin applied to the Tooltip, including the container and the tail.
  final EdgeInsetsGeometry? margin;

  /// The padding applied to [content].
  final EdgeInsetsGeometry? contentPadding;

  /// The padding applied to the Tooltip's [BoxConstraints].
  final EdgeInsetsGeometry? edgePadding;

  final double? elevation;

  final BorderRadiusGeometry? borderRadius;

  final double? tailLength;

  final double? tailBaseWidth;

  final TailBuilder? tailBuilder;

  final FlTooltipEntryBarrier? barrier;

  final FlTooltipDismissOptions? dismissOptions;

  /// {@macro fl_tooltip.FlTooltipTheme.backgroundColor}
  final Color? backgroundColor;

  final TextDirection? textDirection;

  final Shadow? shadow;

  final bool showWhenUnlinked;

  /// The content of the tooltip. Content must be collapsed so it does not
  /// exceed it's constraints. The content's intrinsic `size` is used to first
  /// to get the quadrant of the tooltip. It is then layed out with those
  /// quadrant constraints limiting its size.
  ///
  /// Note that the tooltip may not go to the first of [positionOptions]: it goes to the first one it fits in.
  final Widget content;

  static FlTooltipTransitionsBuilder _effectiveTransitionsBuilderOf(
    BuildContext context,
  ) {
    return FlTooltipTheme.maybeOf(context)?.transitionsBuilder ?? FlTooltipThemeData._defaultTransitionsBuilder;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlTooltipEntryOptions &&
          other.useDryLayout == useDryLayout &&
          _positionOptionsEqual(other.positionOptions, positionOptions) &&
          other.transitionsBuilder == transitionsBuilder &&
          other.margin == margin &&
          other.contentPadding == contentPadding &&
          other.edgePadding == edgePadding &&
          other.elevation == elevation &&
          other.borderRadius == borderRadius &&
          other.tailLength == tailLength &&
          other.tailBaseWidth == tailBaseWidth &&
          other.tailBuilder == tailBuilder &&
          other.barrier == barrier &&
          other.dismissOptions == dismissOptions &&
          other.backgroundColor == backgroundColor &&
          other.textDirection == textDirection &&
          other.shadow == shadow &&
          other.showWhenUnlinked == showWhenUnlinked;

  @override
  int get hashCode => Object.hashAll([
        useDryLayout,
        _positionOptionsHash(positionOptions),
        transitionsBuilder,
        margin,
        contentPadding,
        edgePadding,
        elevation,
        borderRadius,
        tailLength,
        tailBaseWidth,
        tailBuilder,
        barrier,
        dismissOptions,
        backgroundColor,
        textDirection,
        shadow,
        showWhenUnlinked,
      ]);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty('useDryLayout', value: useDryLayout, ifTrue: 'dry layout'))
      ..add(IterableProperty<FlTooltipPosition>('positionOptions', positionOptions))
      ..add(DiagnosticsProperty<FlTooltipTransitionsBuilder>(
        'transitionsBuilder',
        transitionsBuilder,
      ))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('margin', margin))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>(
        'contentPadding',
        contentPadding,
      ))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('edgePadding', edgePadding))
      ..add(DoubleProperty('elevation', elevation))
      ..add(DiagnosticsProperty<BorderRadiusGeometry>(
        'borderRadius',
        borderRadius,
      ))
      ..add(DoubleProperty('tailLength', tailLength))
      ..add(DoubleProperty('tailBaseWidth', tailBaseWidth))
      ..add(DiagnosticsProperty<TailBuilder>('tailBuilder', tailBuilder))
      ..add(DiagnosticsProperty<FlTooltipEntryBarrier>('barrier', barrier))
      ..add(DiagnosticsProperty<FlTooltipDismissOptions>(
        'dismissOptions',
        dismissOptions,
      ))
      ..add(DiagnosticsProperty<Color>('backgroundColor', backgroundColor))
      ..add(DiagnosticsProperty<TextDirection>('textDirection', textDirection))
      ..add(DiagnosticsProperty<Shadow>('shadow', shadow))
      ..add(FlagProperty(
        'showWhenUnlinked',
        value: showWhenUnlinked,
        ifTrue: 'show when unlinked',
        ifFalse: 'hide when unlinked',
      ));
  }
}

/// The barrier shown behind a tooltip, covering the [Overlay] the tooltip is in.
///
/// The barrier stays on its [Overlay]: it doesn't move when the target does. A [spotlight] cuts a hole in it around
/// the target, and the hole follows the target on every frame.
@immutable
class FlTooltipEntryBarrier with Diagnosticable {
  /// A barrier filled with [color], blurring what's behind it when [blurSigma] is greater than 0.
  const FlTooltipEntryBarrier({
    this.color,
    this.blurSigma = 0.0,
    this.dismissible = true,
    this.spotlight,
  })  : assert(blurSigma >= 0.0),
        builder = null;

  /// A barrier drawn by [builder], at the size of the [Overlay].
  ///
  /// [builder] gets the effective barrier color. It draws the barrier's look only: the hole around the target comes
  /// from [spotlight], which is cut out of whatever [builder] draws, including a [BackdropFilter].
  const FlTooltipEntryBarrier.custom({
    this.color,
    this.dismissible = true,
    required BarrierBuilder this.builder,
    this.spotlight,
  }) : blurSigma = 0.0;

  /// {@macro fl_tooltip.FlTooltipTheme.barrierColor}
  final Color? color;

  /// How much the barrier blurs what's behind it. 0 means no blur.
  ///
  /// Only used by the default constructor.
  final double blurSigma;

  /// Whether a tap or a drag on the barrier dismisses the tooltip, as set by [FlTooltipDismissOptions].
  final bool dismissible;

  /// Draws the barrier, if it was created with [FlTooltipEntryBarrier.custom].
  final BarrierBuilder? builder;

  /// The hole around the target, if any.
  final FlTooltipSpotlight? spotlight;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Color>('color', color))
      ..add(DoubleProperty('blurSigma', blurSigma, defaultValue: 0.0))
      ..add(ObjectFlagProperty<BarrierBuilder>.has('builder', builder))
      ..add(DiagnosticsProperty<FlTooltipSpotlight>('spotlight', spotlight))
      ..add(FlagProperty(
        'dismissible',
        value: dismissible,
        ifTrue: 'barrier dismissible',
        ifFalse: 'barrier not dismissible',
      ));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlTooltipEntryBarrier &&
          other.color == color &&
          other.blurSigma == blurSigma &&
          other.builder == builder &&
          other.spotlight == spotlight &&
          other.dismissible == dismissible;

  @override
  int get hashCode => Object.hashAll([
        color,
        blurSigma,
        builder,
        spotlight,
        dismissible,
      ]);
}

/// A hole in a [FlTooltipEntryBarrier] around the tooltip's target.
///
/// The hole is cut while the frame is composited, from where the target is on that frame, so it stays on the target
/// while the target moves (a route transition, a scroll) without rebuilding or repainting anything.
@immutable
class FlTooltipSpotlight with Diagnosticable {
  const FlTooltipSpotlight({
    this.padding = EdgeInsets.zero,
    this.shape = const RoundedRectangleBorder(),
    this.decorationBuilder,
    this.allowTargetInteraction = false,
  });

  /// The space between the target's bounds and the hole's.
  final EdgeInsetsGeometry padding;

  /// The shape of the hole, laid out over the target's bounds grown by [padding].
  final ShapeBorder shape;

  /// Builds a widget over the hole, at the hole's size, such as a ring around it. It moves with the target, and it
  /// doesn't take gestures.
  final WidgetBuilder? decorationBuilder;

  /// Whether gestures in the hole reach the target.
  ///
  /// When false, the hole takes gestures like the rest of the barrier does, including dismissing the tooltip when the
  /// barrier is [FlTooltipEntryBarrier.dismissible].
  final bool allowTargetInteraction;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding))
      ..add(DiagnosticsProperty<ShapeBorder>('shape', shape))
      ..add(ObjectFlagProperty<WidgetBuilder>.has('decorationBuilder', decorationBuilder))
      ..add(FlagProperty(
        'allowTargetInteraction',
        value: allowTargetInteraction,
        ifTrue: 'target interactive',
        ifFalse: 'target not interactive',
      ));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlTooltipSpotlight &&
          other.padding == padding &&
          other.shape == shape &&
          other.decorationBuilder == decorationBuilder &&
          other.allowTargetInteraction == allowTargetInteraction;

  @override
  int get hashCode => Object.hash(padding, shape, decorationBuilder, allowTargetInteraction);
}
