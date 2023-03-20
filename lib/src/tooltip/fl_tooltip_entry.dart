part of fl_tooltip;

class FlTooltipOverlayEntry {
  OverlayEntry? _overlayEntry;
  void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class FlTooltipEntry extends StatelessWidget {
  const FlTooltipEntry({
    super.key,
    this.animation,
    required this.options,
    required this.targetKey,
    required this.onDismissTooltip,
  });

  final Animation<double>? animation;

  final FlTooltipEntryOptions options;

  /// The key of the target widget. If null, the tooltip will be linked to the
  /// child widget.
  final FlTooltipTargetKey targetKey;

  final VoidCallback onDismissTooltip;

  static FlTooltipOverlayEntry showTooltip({
    required FlTooltipTargetKey targetKey,
    required FlTooltipEntryOptions options,
    Animation<double>? animation,
    bool useRootOverlay = false,
    Widget? debugOverlayRequiredFor,
  }) {
    final OverlayState overlay = Overlay.of(
      targetKey.currentContext!,
      rootOverlay: useRootOverlay,
      debugRequiredFor: debugOverlayRequiredFor,
      // this is to support older flutter version
      // ignore: unnecessary_non_null_assertion
    )!;
    final FlTooltipOverlayEntry entry = createEntry(
      targetKey: targetKey,
      options: options,
      animation: animation,
    );
    overlay.insert(entry._overlayEntry!);
    return entry;
  }

  static FlTooltipOverlayEntry createEntry({
    required FlTooltipTargetKey targetKey,
    required FlTooltipEntryOptions options,
    Animation<double>? animation,
  }) {
    final FlTooltipOverlayEntry entry = FlTooltipOverlayEntry();
    final OverlayEntry overlayEntry = OverlayEntry(
      builder: (_) => FlTooltipEntry(
        animation: animation,
        options: options,
        targetKey: targetKey,
        onDismissTooltip: entry.dismiss,
      ),
    );
    entry._overlayEntry = overlayEntry;
    return entry;
  }

  @override
  Widget build(BuildContext context) {
    final RenderBoxPosition? position =
        options.useDryLayout ? targetKey.dryBoxPosition : targetKey.boxPosition;
    final RenderBoxPosition boxPosition = position ?? RenderBoxPosition.zero;

    final FlTooltipTheme? flTooltipTheme = Theme.of(context).flTooltipTheme;

    final EdgeInsetsGeometry effectiveMargin = options.margin ??
        flTooltipTheme?.margin ??
        FlTooltipTheme._defaultMargin;

    final EdgeInsetsGeometry effectiveContentPadding = options.contentPadding ??
        flTooltipTheme?.contentPadding ??
        FlTooltipTheme._defaultContentPadding;

    final Color effectiveBarrierColor = options.barrierColor ??
        flTooltipTheme?.barrierColor ??
        FlTooltipTheme._defaultBarrierColor;

    final Color effectiveBackgroundColor = options.backgroundColor ??
        flTooltipTheme?.backgroundColor ??
        FlTooltipTheme._defaultBackgroundColor;

    final BorderRadiusGeometry effectiveBorderRadius = options.borderRadius ??
        flTooltipTheme?.borderRadius ??
        FlTooltipTheme._defaultBorderRadius;

    final Shadow effectiveShadow = options.shadow ??
        flTooltipTheme?.shadow ??
        FlTooltipTheme._defaultShadow;

    final TextDirection effectiveTextDirection = options.textDirection ??
        Directionality.maybeOf(context) ??
        TextDirection.ltr;

    final double effectiveElevation = options.elevation ??
        flTooltipTheme?.elevation ??
        FlTooltipTheme._defaultElevation;

    final double effectiveTailLength = options.tailLength ??
        flTooltipTheme?.tailLength ??
        FlTooltipTheme._defaultTailLength;

    final double effectiveTailBaseWidth = options.tailBaseWidth ??
        flTooltipTheme?.tailBaseWidth ??
        FlTooltipTheme._defaultTailBaseWidth;

    final TailBuilder effectiveTailBuilder = options.tailBuilder ??
        flTooltipTheme?.tailBuilder ??
        FlTooltipTheme.defaultTailBuilder;

    final FlTooltipDismissOptions effectiveDismissOptions =
        options.dismissOptions ??
            flTooltipTheme?.dismissOptions ??
            FlTooltipTheme._defaultDismissOptions;

    final Widget contentWidget;
    if (effectiveContentPadding != EdgeInsets.zero) {
      contentWidget = Padding(
        padding: effectiveContentPadding,
        child: options.content,
      );
    } else {
      contentWidget = options.content;
    }

    final Material wrappedContent = Material(
      type: MaterialType.transparency,
      child: contentWidget,
    );

    Widget content = Stack(
      children: <Widget>[
        GestureDetector(
          behavior: options.barrierDismissible
              ? HitTestBehavior.translucent
              : HitTestBehavior.deferToChild,
          onTap: effectiveDismissOptions.whenBarrierTapped
              ? onDismissTooltip
              : null,
          onHorizontalDragStart:
              effectiveDismissOptions.whenBarrierScrolledHorizontally
                  ? (_) => onDismissTooltip()
                  : null,
          onVerticalDragStart:
              effectiveDismissOptions.whenBarrierScrolledVertically
                  ? (_) => onDismissTooltip()
                  : null,
          child: Builder(
            builder: (BuildContext context) => options.barrierBuilder(
              context,
              effectiveBarrierColor,
            ),
          ),
        ),
        GestureDetector(
          onTap: effectiveDismissOptions.whenContentTapped
              ? onDismissTooltip
              : null,
          child: _SingleChildTooltip(
            boxPosition: boxPosition,
            alignment: options.alignment,
            direction: options.direction,
            margin: effectiveMargin,
            position: options.position,
            borderRadius: effectiveBorderRadius,
            tailBaseWidth: effectiveTailBaseWidth,
            tailLength: effectiveTailLength,
            tailBuilder: effectiveTailBuilder,
            backgroundColor: effectiveBackgroundColor,
            textDirection: effectiveTextDirection,
            shadow: effectiveShadow,
            elevation: effectiveElevation,
            child: wrappedContent,
          ),
        ),
      ],
    );

    final Animation<double>? animation = this.animation;
    if (animation != null) {
      final FlTooltipTransitionsBuilder effectiveTransitionsBuilder =
          options.transitionsBuilder ??
              FlTooltipEntryOptions._effectiveTransitionsBuilderOf(context);
      content = DualTransitionBuilder(
        animation: animation,
        forwardBuilder: effectiveTransitionsBuilder.buildTransitions,
        reverseBuilder: effectiveTransitionsBuilder.buildReverseTransitions,
        child: content,
      );
    }

    final LayerLink? link = targetKey.currentState?._link;
    assert(() {
      if (link == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('No link found for the tooltip target.'),
          ErrorDescription(
            'This might be a bug in the library.\n'
            'Please file an issue at https://github.com/iandis/fl_tooltip/issues/new '
            'with the reproducible code sample.',
          ),
        ]);
      }
      return true;
    }());

    return CompositedTransformFollower(
      link: link!,
      showWhenUnlinked: options.showWhenUnlinked,
      offset: boxPosition.topLeftOffset,
      child: content,
    );
  }
}
