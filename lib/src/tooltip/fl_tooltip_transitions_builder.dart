part of fl_tooltip;

abstract class FlTooltipTransitionsBuilder {
  const factory FlTooltipTransitionsBuilder({
    required Duration duration,
    required AnimatedTransitionBuilder transitionBuilder,
    required Duration reverseDuration,
    required AnimatedTransitionBuilder reverseTransitionBuilder,
  }) = _FlTooltipTransitionsBuilderCreator;

  static const FlTooltipTransitionsBuilder fadingTransitions =
      FlTooltipTransitionsBuilder(
    duration: Duration(milliseconds: 150),
    transitionBuilder: _fadingTransitionBuilder,
    reverseDuration: Duration(milliseconds: 75),
    reverseTransitionBuilder: _reverseFadingTransitionBuilder,
  );

  static Widget _fadingTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Widget? child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }

  static Widget _reverseFadingTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Widget? child,
  ) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1.0, end: 0.0).animate(animation),
      child: child,
    );
  }

  static const FlTooltipTransitionsBuilder noTransitions =
      FlTooltipTransitionsBuilder(
    duration: Duration.zero,
    transitionBuilder: _noTransitionsBuilder,
    reverseDuration: Duration.zero,
    reverseTransitionBuilder: _noTransitionsBuilder,
  );

  static Widget _noTransitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Widget? child,
  ) {
    return child ?? const SizedBox();
  }

  Duration get duration;

  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Widget? child,
  );

  Duration get reverseDuration;

  Widget buildReverseTransitions(
    BuildContext context,
    Animation<double> animation,
    Widget? child,
  );
}

class _FlTooltipTransitionsBuilderCreator
    implements FlTooltipTransitionsBuilder {
  const _FlTooltipTransitionsBuilderCreator({
    required this.duration,
    required this.transitionBuilder,
    required this.reverseDuration,
    required this.reverseTransitionBuilder,
  });

  @override
  final Duration duration;

  final AnimatedTransitionBuilder transitionBuilder;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Widget? child,
  ) {
    return transitionBuilder(context, animation, child);
  }

  @override
  final Duration reverseDuration;

  final AnimatedTransitionBuilder reverseTransitionBuilder;

  @override
  Widget buildReverseTransitions(
    BuildContext context,
    Animation<double> animation,
    Widget? child,
  ) {
    return reverseTransitionBuilder(context, animation, child);
  }
}
