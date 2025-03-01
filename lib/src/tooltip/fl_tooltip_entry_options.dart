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
    this.useDryLayout = true,
    this.alignment = Alignment.center,
    this.direction = AxisDirection.down,
    this.alternativeDirections = const <AxisDirection>{},
    this.transitionsBuilder,
    this.margin,
    this.contentPadding,
    this.edgePadding,
    this.position = 0.0,
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
  });

  /// Whether to compute child's size using [RenderBox.computeDryLayout].
  final bool useDryLayout;

  final Alignment alignment;

  final AxisDirection direction;

  /// Defines alternatives for [direction] when the tooltip cannot fit its content
  /// given the constraints of the parent widget. This will fallback to [direction]
  /// when none of the alternatives can fit.
  final Set<AxisDirection> alternativeDirections;

  final FlTooltipTransitionsBuilder? transitionsBuilder;

  /// The margin applied to the Tooltip, including the container and the tail.
  final EdgeInsetsGeometry? margin;

  /// The padding applied to [content].
  final EdgeInsetsGeometry? contentPadding;

  /// The padding applied to the Tooltip's [BoxConstraints].
  final EdgeInsetsGeometry? edgePadding;

  /// {@template fl_tooltip.FlTooltipEntryOptions.position}
  /// The position of [content] along the tail's axis.
  /// It ranges from -1.0 to 1.0, where 0.0 is the center.
  ///
  /// When [direction] is vertical, the greater [position] value is,
  /// the more [content] is positioned to the right.
  ///
  /// When [direction] is horizontal, the greater [position] value is,
  /// the more [content] is positioned to the bottom.
  /// {@endtemplate}
  final double position;

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
  /// Note that [direction] is not the final [AxisDirection]
  /// but may be placed opposite.
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
          other.alignment == alignment &&
          other.direction == direction &&
          setEquals(other.alternativeDirections, alternativeDirections) &&
          other.transitionsBuilder == transitionsBuilder &&
          other.margin == margin &&
          other.contentPadding == contentPadding &&
          other.edgePadding == edgePadding &&
          other.position == position &&
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
        alignment,
        direction,
        alternativeDirections,
        transitionsBuilder,
        margin,
        contentPadding,
        edgePadding,
        position,
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
      ..add(DiagnosticsProperty<Alignment>('alignment', alignment))
      ..add(DiagnosticsProperty<AxisDirection>('direction', direction))
      ..add(DiagnosticsProperty<Set<AxisDirection>>(
        'alternativeDirections',
        alternativeDirections,
      ))
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
      ..add(DoubleProperty('position', position))
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

@immutable
class FlTooltipEntryBarrier with Diagnosticable {
  const FlTooltipEntryBarrier({
    this.color,
    this.dismissible = true,
    this.builder = _defaultBarrierBuilder,
  });

  /// {@macro fl_tooltip.FlTooltipTheme.barrierColor}
  final Color? color;

  final bool dismissible;

  final BarrierBuilder builder;

  static Widget _defaultBarrierBuilder(BuildContext context, Color skrimColor) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: ColoredBox(color: skrimColor),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Color>('color', color))
      ..add(DiagnosticsProperty<BarrierBuilder>(
        'builder',
        builder,
      ))
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
          other.builder == builder &&
          other.dismissible == dismissible;

  @override
  int get hashCode => Object.hashAll([
        color,
        builder,
        dismissible,
      ]);
}
