part of fl_tooltip;

/// The overlay entry produced by [FlTooltipEntry.createEntry].
/// Use this to dismiss the tooltip.
class FlTooltipOverlayEntry {
  OverlayEntry? _overlayEntry;
  void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class FlTooltipEntry extends StatefulWidget {
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

  /// Creates a [FlTooltipOverlayEntry] and inserts it into the overlay.
  ///
  /// [animation] can be optionally provided in order to animate the tooltip.
  ///
  /// [useRootOverlay] can be optionally provided in order to use the root
  /// [Overlay] widget. This is the same as passing `rootOverlay: true` to
  /// [Overlay.of].
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
    _checkPositionOptionsNotEmpty(options.positionOptions);
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
  State<FlTooltipEntry> createState() => _FlTooltipEntryState();
}

class _FlTooltipEntryState extends State<FlTooltipEntry> {
  /// Where the target is, as of the last frame. The tooltip is laid out against it.
  ///
  /// It is listened to by the tooltip's render objects ([_RenderSingleChildTooltip] and [_RenderTargetFollower])
  /// rather than by this state, so a move of the target lays out and paints the tooltip again without a rebuild.
  late final ValueNotifier<RenderBoxPosition> _boxPosition = ValueNotifier<RenderBoxPosition>(
    _readPosition() ?? RenderBoxPosition.zero,
  );

  /// The target's laid out size, as of the last frame. The spotlight decoration is sized from it, like the spotlight
  /// itself (see [_SpotlightClipLayer]), even when the tooltip points at the target's natural size
  /// ([FlTooltipEntryOptions.useDryLayout]).
  late final ValueNotifier<Size> _targetSize = ValueNotifier<Size>(_readTargetSize() ?? Size.zero);

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(_syncTargetPosition);
  }

  @override
  void didUpdateWidget(FlTooltipEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetKey != widget.targetKey || oldWidget.options.useDryLayout != widget.options.useDryLayout) {
      _updateTargetPosition();
    }
  }

  @override
  void dispose() {
    _boxPosition.dispose();
    _targetSize.dispose();
    super.dispose();
  }

  Size? _readTargetSize() {
    final RenderObject? target = widget.targetKey.currentContext?.findRenderObject();
    return target is RenderBox && target.hasSize ? target.size : null;
  }

  RenderBoxPosition? _readPosition() {
    return widget.options.useDryLayout ? widget.targetKey.dryBoxPosition : widget.targetKey.boxPosition;
  }

  /// Checks where the target is after every frame, so the tooltip follows it when it moves without this entry being
  /// rebuilt, e.g. while the target's route transitions in or while it scrolls.
  ///
  /// The check never asks for a frame: it only runs after the frames something else asked for. When the target moved,
  /// only the tooltip's render objects are updated (see [_SingleChildTooltip] and [_TargetFollower]); nothing is
  /// rebuilt. The barrier and its spotlight don't need this at all (see [_TooltipBarrier]).
  void _syncTargetPosition(Duration _) {
    if (!mounted) return;
    _updateTargetPosition();
    SchedulerBinding.instance.addPostFrameCallback(_syncTargetPosition);
  }

  void _updateTargetPosition() {
    // A target that is gone (e.g. disposed by a lazy list) keeps its last position: the follower hides the tooltip
    // while the target isn't on screen.
    final RenderBoxPosition? position = _readPosition();
    if (position == null) return;
    // [ValueNotifier] only notifies when the value changed ([RenderBoxPosition] compares by value), so a target that
    // doesn't move costs one [RenderBox.localToGlobal] per frame and nothing else.
    _boxPosition.value = position;
    _targetSize.value = _readTargetSize() ?? _targetSize.value;
  }

  @override
  Widget build(BuildContext context) {
    final FlTooltipEntryOptions options = widget.options;
    final VoidCallback onDismissTooltip = widget.onDismissTooltip;
    final LayerLink? link = widget.targetKey.currentState?._link;
    if (link == null) {
      // The target is gone (e.g. a lazy list disposed it): there is nothing to point at. [FlTooltip] removes this
      // entry when its own target goes, so this only happens with a separate [FlTooltip.targetKey].
      return const SizedBox.shrink();
    }

    final FlTooltipThemeData? flTooltipTheme = FlTooltipTheme.maybeOf(context);

    final EdgeInsetsGeometry effectiveMargin =
        options.margin ?? flTooltipTheme?.margin ?? FlTooltipThemeData._defaultMargin;

    final EdgeInsetsGeometry effectiveEdgePadding =
        options.edgePadding ?? flTooltipTheme?.edgePadding ?? EdgeInsets.zero;

    final EdgeInsetsGeometry effectiveContentPadding =
        options.contentPadding ?? flTooltipTheme?.contentPadding ?? FlTooltipThemeData._defaultContentPadding;

    final Color effectiveBarrierColor =
        options.barrier?.color ?? flTooltipTheme?.barrierColor ?? FlTooltipThemeData._defaultBarrierColor;

    final Color effectiveBackgroundColor =
        options.backgroundColor ?? flTooltipTheme?.backgroundColor ?? FlTooltipThemeData._defaultBackgroundColor;

    final BorderRadiusGeometry effectiveBorderRadius =
        options.borderRadius ?? flTooltipTheme?.borderRadius ?? FlTooltipThemeData._defaultBorderRadius;

    final Shadow effectiveShadow = options.shadow ?? flTooltipTheme?.shadow ?? FlTooltipThemeData._defaultShadow;

    final TextDirection effectiveTextDirection =
        options.textDirection ?? Directionality.maybeOf(context) ?? TextDirection.ltr;

    final double effectiveElevation =
        options.elevation ?? flTooltipTheme?.elevation ?? FlTooltipThemeData._defaultElevation;

    final double effectiveTailLength =
        options.tailLength ?? flTooltipTheme?.tailLength ?? FlTooltipThemeData._defaultTailLength;

    final double effectiveTailBaseWidth =
        options.tailBaseWidth ?? flTooltipTheme?.tailBaseWidth ?? FlTooltipThemeData._defaultTailBaseWidth;

    final TailBuilder effectiveTailBuilder =
        options.tailBuilder ?? flTooltipTheme?.tailBuilder ?? FlTooltipThemeData.defaultTailBuilder;

    final FlTooltipDismissOptions effectiveDismissOptions =
        options.dismissOptions ?? flTooltipTheme?.dismissOptions ?? FlTooltipThemeData._defaultDismissOptions;

    final Widget contentWidget;
    if (effectiveContentPadding != EdgeInsets.zero) {
      contentWidget = Padding(
        padding: effectiveContentPadding,
        child: options.content,
      );
    } else {
      contentWidget = options.content;
    }

    // An empty non-const set gets past [FlTooltipEntryOptions]'s own check (e.g. options changed while the tooltip
    // shows), and a set of non-const positions can hold the same one twice.
    _checkPositionOptionsNotEmpty(options.positionOptions);
    assert(_debugReportDuplicatePositions(options.positionOptions));
    final Set<FlTooltipPosition> positionOptions = _deduplicatePositions(options.positionOptions);

    final FlTooltipEntryBarrier? barrier = options.barrier;

    // The tooltip moves with the target: it is laid out against [_boxPosition], and the follower lines it up with
    // the target on every frame in between.
    final Widget tooltip = _TargetFollower(
      link: link,
      showWhenUnlinked: options.showWhenUnlinked,
      boxPosition: _boxPosition,
      child: GestureDetector(
        onTap: (barrier == null || barrier.dismissible) && effectiveDismissOptions.whenContentTapped
            ? onDismissTooltip
            : null,
        child: _SingleChildTooltip(
          boxPosition: _boxPosition,
          positionOptions: positionOptions,
          margin: effectiveMargin,
          edgePadding: effectiveEdgePadding,
          borderRadius: effectiveBorderRadius,
          tailBaseWidth: effectiveTailBaseWidth,
          tailLength: effectiveTailLength,
          tailBuilder: effectiveTailBuilder,
          backgroundColor: effectiveBackgroundColor,
          textDirection: effectiveTextDirection,
          shadow: effectiveShadow,
          elevation: effectiveElevation,
          // The tooltip is repainted when the target moves, its content doesn't need to be.
          child: RepaintBoundary(child: contentWidget),
        ),
      ),
    );

    Widget content;
    if (barrier == null) {
      content = tooltip;
    } else {
      final FlTooltipSpotlight? spotlight = barrier.spotlight;
      final WidgetBuilder? spotlightDecorationBuilder = spotlight?.decorationBuilder;
      content = Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Covers the whole Overlay and stays on it, while its spotlight follows the target (see
          // [_TooltipBarrier]). Its look is built once here: nothing in it depends on where the target is.
          _TooltipBarrier(
            link: link,
            showWhenUnlinked: options.showWhenUnlinked,
            dismissible: barrier.dismissible,
            spotlight: spotlight,
            textDirection: effectiveTextDirection,
            child: GestureDetector(
              // A dismissible barrier lets gestures through to what's behind it while it dismisses the tooltip. A
              // barrier that isn't dismissible takes every gesture itself (see [_RenderTooltipBarrier.hitTest]).
              behavior: barrier.dismissible ? HitTestBehavior.translucent : HitTestBehavior.deferToChild,
              onTap: barrier.dismissible && effectiveDismissOptions.whenBarrierTapped ? onDismissTooltip : null,
              onHorizontalDragStart: barrier.dismissible && effectiveDismissOptions.whenBarrierScrolledHorizontally
                  ? (_) => onDismissTooltip()
                  : null,
              onVerticalDragStart: barrier.dismissible && effectiveDismissOptions.whenBarrierScrolledVertically
                  ? (_) => onDismissTooltip()
                  : null,
              child: Builder(
                builder: (BuildContext context) =>
                    barrier.builder?.call(context, effectiveBarrierColor) ??
                    _buildBarrier(effectiveBarrierColor, barrier.blurSigma),
              ),
            ),
          ),
          // Moves with the target, over the spotlight.
          if (spotlight != null && spotlightDecorationBuilder != null)
            _buildSpotlightDecoration(
              link: link,
              padding: spotlight.padding.resolve(effectiveTextDirection),
              builder: spotlightDecorationBuilder,
            ),
          // Above the barrier, so that the barrier doesn't take the tooltip's gestures.
          tooltip,
        ],
      );
    }

    final Animation<double>? animation = widget.animation;
    if (animation != null) {
      final FlTooltipTransitionsBuilder effectiveTransitionsBuilder =
          options.transitionsBuilder ?? FlTooltipEntryOptions._effectiveTransitionsBuilderOf(context);
      content = DualTransitionBuilder(
        animation: animation,
        forwardBuilder: effectiveTransitionsBuilder.buildTransitions,
        reverseBuilder: effectiveTransitionsBuilder.buildReverseTransitions,
        child: content,
      );
    }

    return content;
  }

  /// The look of the default [FlTooltipEntryBarrier]. It is laid out at the Overlay's size by the [Stack] around it.
  static Widget _buildBarrier(Color color, double blurSigma) {
    final Widget barrier = ColoredBox(color: color);
    if (blurSigma == 0.0) return barrier;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      child: barrier,
    );
  }

  /// Puts [FlTooltipSpotlight.decorationBuilder]'s widget over the hole: a follower whose top left is the hole's, at
  /// the hole's size. It is only rebuilt when the target's size changes, not when the target moves.
  Widget _buildSpotlightDecoration({
    required LayerLink link,
    required EdgeInsets padding,
    required WidgetBuilder builder,
  }) {
    return CompositedTransformFollower(
      link: link,
      showWhenUnlinked: false,
      offset: Offset(-padding.left, -padding.top),
      // The decoration doesn't take gestures, so the hole's are handled as [FlTooltipSpotlight.allowTargetInteraction]
      // says.
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topLeft,
          child: ValueListenableBuilder<Size>(
            valueListenable: _targetSize,
            builder: (_, Size targetSize, Widget? child) => SizedBox(
              width: targetSize.width + padding.horizontal,
              height: targetSize.height + padding.vertical,
              child: child,
            ),
            child: Builder(builder: builder),
          ),
        ),
      ),
    );
  }
}
