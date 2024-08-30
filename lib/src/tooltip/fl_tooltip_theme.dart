part of fl_tooltip;

class FlTooltipTheme extends StatelessWidget {
  const FlTooltipTheme({
    super.key,
    required this.data,
    required this.child,
  });

  static FlTooltipThemeData? maybeOf(BuildContext context) {
    final _FlTooltipInheritedTheme? inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<_FlTooltipInheritedTheme>();
    return inheritedTheme?.theme.data;
  }

  static FlTooltipThemeData of(BuildContext context) {
    final FlTooltipThemeData? theme = maybeOf(context);
    assert(theme != null, 'No FlTooltipTheme found in context');
    return theme!;
  }

  static FlTooltipThemeData? maybeGet(BuildContext context) {
    final _FlTooltipInheritedTheme? inheritedTheme =
        context.getInheritedWidgetOfExactType<_FlTooltipInheritedTheme>();
    return inheritedTheme?.theme.data;
  }

  static FlTooltipThemeData get(BuildContext context) {
    final FlTooltipThemeData? theme = maybeGet(context);
    assert(theme != null, 'No FlTooltipTheme found in context');
    return theme!;
  }

  final FlTooltipThemeData data;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _FlTooltipInheritedTheme(
      theme: this,
      child: child,
    );
  }
}

class _FlTooltipInheritedTheme extends InheritedTheme {
  const _FlTooltipInheritedTheme({
    required this.theme,
    required super.child,
  });

  final FlTooltipTheme theme;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      FlTooltipTheme(data: theme.data, child: child);

  @override
  bool updateShouldNotify(_FlTooltipInheritedTheme oldWidget) =>
      theme.data != oldWidget.theme.data;
}

class FlTooltipThemeData {
  const FlTooltipThemeData({
    this.margin = _defaultMargin,
    this.contentPadding = _defaultContentPadding,
    this.borderRadius = _defaultBorderRadius,
    this.barrierColor = _defaultBarrierColor,
    this.backgroundColor = _defaultBackgroundColor,
    this.elevation = _defaultElevation,
    this.tailLength = _defaultTailLength,
    this.tailBaseWidth = _defaultTailBaseWidth,
    this.transitionsBuilder = _defaultTransitionsBuilder,
    this.shadow = _defaultShadow,
    this.tailBuilder = defaultTailBuilder,
    this.dismissOptions = _defaultDismissOptions,
  });

  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry contentPadding;
  final BorderRadiusGeometry borderRadius;

  /// {@template fl_tooltip.FlTooltipTheme.barrierColor}
  /// Background color for widget underneath the tooltip (skrim)
  /// {@endtemplate}
  final Color barrierColor;

  /// {@template fl_tooltip.FlTooltipTheme.backgroundColor}
  /// Background color for content
  /// {@endtemplate}
  final Color backgroundColor;
  final double elevation;
  final double tailLength;
  final double tailBaseWidth;
  final FlTooltipTransitionsBuilder transitionsBuilder;
  final Shadow shadow;
  final TailBuilder tailBuilder;
  final FlTooltipDismissOptions dismissOptions;

  static const EdgeInsetsGeometry _defaultMargin = EdgeInsets.all(8.0);
  static const EdgeInsetsGeometry _defaultContentPadding = EdgeInsets.zero;
  static const BorderRadiusGeometry _defaultBorderRadius = BorderRadius.zero;

  /// Transparent color
  static const Color _defaultBarrierColor = Color(0x00000000);

  /// From material's Colors.black54
  static const Color _defaultBackgroundColor = Color(0x8A000000);
  static const double _defaultElevation = 4.0;
  static const double _defaultTailLength = 16.0;
  static const double _defaultTailBaseWidth = 32.0;
  static const FlTooltipTransitionsBuilder _defaultTransitionsBuilder =
      FlTooltipTransitionsBuilder.fadingTransitions;
  static const Shadow _defaultShadow = Shadow(
    offset: Offset.zero,
    blurRadius: 0.0,
    color: Color.fromARGB(255, 0, 0, 0),
  );
  static const FlTooltipDismissOptions _defaultDismissOptions =
      FlTooltipDismissOptions();

  /// Draws a linear closed triangle path for the tail.
  static Path defaultTailBuilder(Offset tip, Offset point2, Offset point3) {
    return Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(point2.dx, point2.dy)
      ..lineTo(point3.dx, point3.dy)
      ..close();
  }

  /// Draws a bezier closed triangle path for the tail.
  static Path defaultBezierTailBuilder(
    Offset tip,
    Offset point2,
    Offset point3,
  ) {
    final offsetBetween = Offset(
      lerpDouble(point2.dx, point3.dx, 0.5)!,
      lerpDouble(point2.dy, point3.dy, 0.5)!,
    );

    return Path()
      ..moveTo(tip.dx, tip.dy)
      ..quadraticBezierTo(
        offsetBetween.dx,
        offsetBetween.dy,
        point2.dx,
        point2.dy,
      )
      ..lineTo(point3.dx, point3.dy)
      ..quadraticBezierTo(
        offsetBetween.dx,
        offsetBetween.dy,
        tip.dx,
        tip.dy,
      )
      ..close();
  }

  FlTooltipThemeData copyWith({
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? contentPadding,
    BorderRadiusGeometry? borderRadius,
    Color? barrierColor,
    Color? backgroundColor,
    double? elevation,
    double? tailLength,
    double? tailBaseWidth,
    FlTooltipTransitionsBuilder? transitionsBuilder,
    Shadow? shadow,
    TailBuilder? tailBuilder,
    FlTooltipDismissOptions? dismissOptions,
  }) {
    return FlTooltipThemeData(
      margin: margin ?? this.margin,
      contentPadding: contentPadding ?? this.contentPadding,
      borderRadius: borderRadius ?? this.borderRadius,
      barrierColor: barrierColor ?? this.barrierColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      tailLength: tailLength ?? this.tailLength,
      tailBaseWidth: tailBaseWidth ?? this.tailBaseWidth,
      transitionsBuilder: transitionsBuilder ?? this.transitionsBuilder,
      shadow: shadow ?? this.shadow,
      tailBuilder: tailBuilder ?? this.tailBuilder,
      dismissOptions: dismissOptions ?? this.dismissOptions,
    );
  }

  FlTooltipThemeData lerp(covariant FlTooltipThemeData? other, double t) {
    if (other == null) return this;
    return FlTooltipThemeData(
      margin: EdgeInsetsGeometry.lerp(
            margin,
            other.margin,
            t,
          ) ??
          _defaultMargin,
      contentPadding: EdgeInsetsGeometry.lerp(
            contentPadding,
            other.contentPadding,
            t,
          ) ??
          _defaultContentPadding,
      borderRadius: BorderRadiusGeometry.lerp(
            borderRadius,
            other.borderRadius,
            t,
          ) ??
          _defaultBorderRadius,
      barrierColor: Color.lerp(
            barrierColor,
            other.barrierColor,
            t,
          ) ??
          _defaultBarrierColor,
      backgroundColor: Color.lerp(
            backgroundColor,
            other.backgroundColor,
            t,
          ) ??
          _defaultBackgroundColor,
      elevation: lerpDouble(elevation, other.elevation, t) ?? _defaultElevation,
      tailLength: lerpDouble(
            tailLength,
            other.tailLength,
            t,
          ) ??
          _defaultTailLength,
      tailBaseWidth: lerpDouble(tailBaseWidth, other.tailBaseWidth, t) ??
          _defaultTailBaseWidth,
      transitionsBuilder: other.transitionsBuilder,
      shadow: Shadow.lerp(
            shadow,
            other.shadow,
            t,
          ) ??
          _defaultShadow,
      tailBuilder: other.tailBuilder,
      dismissOptions: other.dismissOptions,
    );
  }
}
