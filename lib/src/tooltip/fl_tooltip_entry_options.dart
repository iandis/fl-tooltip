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

class FlTooltipEntryOptions with Diagnosticable {
  const FlTooltipEntryOptions({
    this.useDryLayout = true,
    this.alignment = Alignment.center,
    this.direction = AxisDirection.down,
    this.transitionsBuilder,
    this.margin,
    this.contentPadding,
    this.position = 0.0,
    this.elevation,
    this.borderRadius,
    this.tailLength,
    this.tailBaseWidth,
    this.tailBuilder,
    this.barrierColor,
    this.barrierBuilder = _defaultBarrierBuilder,
    this.barrierDismissible = true,
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

  final FlTooltipTransitionsBuilder? transitionsBuilder;

  final EdgeInsetsGeometry? margin;

  final EdgeInsetsGeometry? contentPadding;

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

  /// {@macro fl_tooltip.FlTooltipTheme.barrierColor}
  final Color? barrierColor;

  final BarrierBuilder barrierBuilder;

  final bool barrierDismissible;

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

  static Widget _defaultBarrierBuilder(BuildContext context, Color skrimColor) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: ColoredBox(color: skrimColor),
    );
  }

  static FlTooltipTransitionsBuilder _effectiveTransitionsBuilderOf(
    BuildContext context,
  ) {
    return FlTooltipTheme.maybeOf(context)?.transitionsBuilder ??
        FlTooltipThemeData._defaultTransitionsBuilder;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlTooltipEntryOptions &&
          other.alignment == alignment &&
          other.direction == direction &&
          other.transitionsBuilder == transitionsBuilder &&
          other.margin == margin &&
          other.contentPadding == contentPadding &&
          other.position == position &&
          other.elevation == elevation &&
          other.borderRadius == borderRadius &&
          other.tailLength == tailLength &&
          other.tailBaseWidth == tailBaseWidth &&
          other.tailBuilder == tailBuilder &&
          other.barrierColor == barrierColor &&
          other.barrierBuilder == barrierBuilder &&
          other.barrierDismissible == barrierDismissible &&
          other.dismissOptions == dismissOptions &&
          other.backgroundColor == backgroundColor &&
          other.textDirection == textDirection &&
          other.shadow == shadow &&
          other.showWhenUnlinked == showWhenUnlinked;

  @override
  int get hashCode => Object.hashAll([
        alignment,
        direction,
        transitionsBuilder,
        margin,
        contentPadding,
        position,
        elevation,
        borderRadius,
        tailLength,
        tailBaseWidth,
        tailBuilder,
        barrierColor,
        barrierBuilder,
        barrierDismissible,
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
      ..add(DiagnosticsProperty<FlTooltipTransitionsBuilder>(
        'transitionsBuilder',
        transitionsBuilder,
      ))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('margin', margin))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>(
        'contentPadding',
        contentPadding,
      ))
      ..add(DoubleProperty('position', position))
      ..add(DoubleProperty('elevation', elevation))
      ..add(DiagnosticsProperty<BorderRadiusGeometry>(
        'borderRadius',
        borderRadius,
      ))
      ..add(DoubleProperty('tailLength', tailLength))
      ..add(DoubleProperty('tailBaseWidth', tailBaseWidth))
      ..add(DiagnosticsProperty<TailBuilder>('tailBuilder', tailBuilder))
      ..add(DiagnosticsProperty<Color>('barrierColor', barrierColor))
      ..add(DiagnosticsProperty<BarrierBuilder>(
        'barrierBuilder',
        barrierBuilder,
      ))
      ..add(FlagProperty(
        'barrierDismissible',
        value: barrierDismissible,
        ifTrue: 'barrier dismissible',
        ifFalse: 'barrier not dismissible',
      ))
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
