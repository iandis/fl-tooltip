part of fl_tooltip;

/// Lays a [FlTooltipEntryBarrier] over the whole [Overlay], and cuts its [FlTooltipSpotlight] hole around the target
/// linked by [link].
///
/// The barrier is laid out at the [Overlay]'s size, in the [Overlay]'s coordinates, so it goes wherever the [Overlay]
/// goes and never follows the target. Only the hole follows the target: it is cut on every frame while the frame is
/// composited, from the transform the target has on that frame (see [_SpotlightClipLayer]). So when the target moves
/// (a route transition, a scroll), nothing here is rebuilt, laid out or painted again.
///
/// [child] is the barrier's look: a [ColoredBox] (and a [BackdropFilter]) for the default [FlTooltipEntryBarrier], or
/// what [FlTooltipEntryBarrier.builder] returns.
class _TooltipBarrier extends SingleChildRenderObjectWidget {
  const _TooltipBarrier({
    required this.link,
    required this.showWhenUnlinked,
    required this.dismissible,
    required this.spotlight,
    required this.textDirection,
    super.child,
  });

  /// The link to the target, the same one the tooltip follows.
  final LayerLink link;

  /// Whether the barrier shows while the target isn't on screen, like [CompositedTransformFollower.showWhenUnlinked].
  final bool showWhenUnlinked;

  /// See [FlTooltipEntryBarrier.dismissible].
  final bool dismissible;

  final FlTooltipSpotlight? spotlight;

  /// Resolves [FlTooltipSpotlight.padding] and the hole's [FlTooltipSpotlight.shape].
  final TextDirection textDirection;

  @override
  _RenderTooltipBarrier createRenderObject(BuildContext context) {
    return _RenderTooltipBarrier(
      link: link,
      showWhenUnlinked: showWhenUnlinked,
      dismissible: dismissible,
      spotlight: spotlight,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderTooltipBarrier renderObject) {
    renderObject
      ..link = link
      ..showWhenUnlinked = showWhenUnlinked
      ..dismissible = dismissible
      ..spotlight = spotlight
      ..textDirection = textDirection;
  }
}

class _RenderTooltipBarrier extends RenderProxyBox {
  _RenderTooltipBarrier({
    required LayerLink link,
    required bool showWhenUnlinked,
    required this.dismissible,
    required FlTooltipSpotlight? spotlight,
    required TextDirection textDirection,
  })  : _link = link,
        _showWhenUnlinked = showWhenUnlinked,
        _spotlight = spotlight,
        _textDirection = textDirection;

  LayerLink get link => _link;
  LayerLink _link;
  set link(LayerLink value) {
    if (_link == value) return;
    _link = value;
    markNeedsPaint();
  }

  bool get showWhenUnlinked => _showWhenUnlinked;
  bool _showWhenUnlinked;
  set showWhenUnlinked(bool value) {
    if (_showWhenUnlinked == value) return;
    _showWhenUnlinked = value;
    markNeedsPaint();
  }

  // Only read while hit testing, so changing it doesn't need a repaint.
  bool dismissible;

  FlTooltipSpotlight? get spotlight => _spotlight;
  FlTooltipSpotlight? _spotlight;
  set spotlight(FlTooltipSpotlight? value) {
    if (_spotlight == value) return;
    _spotlight = value;
    markNeedsPaint();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsPaint();
  }

  /// An empty [FollowerLayer] on [link]. Like any follower layer, it works out the target's transform on every frame
  /// while the frame is composited. It draws nothing: [_SpotlightClipLayer] reads that transform to cut the hole, and
  /// [hitTest] reads it to find the hole.
  final LayerHandle<FollowerLayer> _targetProbe = LayerHandle<FollowerLayer>();
  final LayerHandle<_SpotlightClipLayer> _clip = LayerHandle<_SpotlightClipLayer>();

  // The barrier always paints into its own layers (the probe and the clip), even without a spotlight, because the
  // clip layer is also what hides the barrier while the target isn't on screen.
  @override
  bool get alwaysNeedsCompositing => true;

  /// Whether the barrier is gone because the target isn't on screen (e.g. it scrolled away, or its route is covered).
  bool get _isHidden => link.leader == null && !showWhenUnlinked;

  @override
  void paint(PaintingContext context, Offset offset) {
    // The probe has to be pushed before the clip layer: layers are added to the scene in the order they are pushed,
    // so the probe has worked out the target's transform for this frame by the time the clip layer reads it.
    //
    // Its unlinked offset is this barrier's paint offset, so that [FollowerLayer.getLastTransform] maps the target's
    // coordinates to this barrier's (see [_SpotlightClipLayer._holeInLayerSpace]). It never shows anything, so it
    // stays hidden while unlinked.
    final FollowerLayer targetProbe = (_targetProbe.layer ??= FollowerLayer(link: link))
      ..link = link
      ..showWhenUnlinked = false
      ..unlinkedOffset = offset
      ..linkedOffset = Offset.zero;
    context.pushLayer(targetProbe, (_, __) {}, Offset.zero);

    // The barrier's look is painted once into the clip layer. When the target moves, the clip layer cuts the hole in
    // a new place on the next frame, and the look's layers are reused as they are.
    final _SpotlightClipLayer clip = (_clip.layer ??= _SpotlightClipLayer())
      ..targetProbe = targetProbe
      ..link = link
      ..showWhenUnlinked = showWhenUnlinked
      ..spotlight = spotlight
      ..textDirection = textDirection
      ..bounds = offset & size;
    context.pushLayer(clip, super.paint, offset);
  }

  /// Where the barrier takes gestures:
  /// - nowhere while it is hidden (see [_isHidden]);
  /// - not in the hole when [FlTooltipSpotlight.allowTargetInteraction] is true, so they reach the target;
  /// - everywhere else, the hole included, the barrier's gesture handlers get them, so the hole dismisses the tooltip
  ///   like the rest of the barrier does.
  ///
  /// A barrier that isn't [dismissible] takes every gesture there itself (see [hitTestSelf]), whatever its look does
  /// with them, so nothing behind it gets them, not even through a look that doesn't take gestures. A dismissible one
  /// leaves that to its look and its gesture handlers, which let gestures through to what's behind it while they
  /// dismiss the tooltip.
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (_isHidden) return false;
    final FlTooltipSpotlight? spotlight = this.spotlight;
    if (spotlight != null && spotlight.allowTargetInteraction && _holeContains(spotlight, position)) return false;
    return super.hitTest(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) => !dismissible;

  bool _holeContains(FlTooltipSpotlight spotlight, Offset position) {
    // The transform of the last composited frame: where the hole was drawn, so where the user saw it.
    final Matrix4? targetTransform = _targetProbe.layer?.getLastTransform();
    if (targetTransform == null) return false;
    final Path? hole = _spotlightPath(spotlight, link.leaderSize, textDirection)?.transform(targetTransform.storage);
    return hole != null && hole.contains(position);
  }

  @override
  void dispose() {
    _targetProbe.layer = null;
    _clip.layer = null;
    super.dispose();
  }
}

/// The [FlTooltipSpotlight] hole in the target's own coordinates (the target's top left at 0, 0), or null without a
/// target size.
Path? _spotlightPath(FlTooltipSpotlight spotlight, Size? targetSize, TextDirection textDirection) {
  if (targetSize == null) return null;
  final Rect holeRect = spotlight.padding.resolve(textDirection).inflateRect(Offset.zero & targetSize);
  return spotlight.shape.getOuterPath(holeRect, textDirection: textDirection);
}

/// Clips its children (the barrier's look) to [bounds] minus the [FlTooltipSpotlight] hole around the target.
///
/// The hole is worked out in [addToScene], from the transform [targetProbe] has just worked out for the target on
/// this frame. So it is where the target is on every frame, without anything being rebuilt, laid out or painted again.
/// The layer also leaves the barrier out of the scene while the target isn't on screen, like a follower layer.
class _SpotlightClipLayer extends ContainerLayer {
  FollowerLayer? targetProbe;
  LayerLink? link;
  bool showWhenUnlinked = false;
  FlTooltipSpotlight? spotlight;
  TextDirection textDirection = TextDirection.ltr;

  /// The barrier, in this layer's coordinates.
  Rect bounds = Rect.zero;

  /// The hole moves with the target without anything marking this layer dirty, so it has to be added to every scene,
  /// like a [FollowerLayer].
  @override
  bool get alwaysNeedsAddToScene => true;

  @override
  void addToScene(SceneBuilder builder) {
    if (link?.leader == null && !showWhenUnlinked) {
      engineLayer = null;
      return;
    }
    final Path? hole = _holeInLayerSpace();
    if (hole == null) {
      // No spotlight, or no target on screen to cut it around: the whole barrier shows.
      engineLayer = null;
      addChildrenToScene(builder);
      return;
    }
    engineLayer = builder.pushClipPath(
      Path.combine(PathOperation.difference, Path()..addRect(bounds), hole),
      oldLayer: engineLayer as ClipPathEngineLayer?,
    );
    addChildrenToScene(builder);
    builder.pop();
  }

  Path? _holeInLayerSpace() {
    final FlTooltipSpotlight? spotlight = this.spotlight;
    if (spotlight == null) return null;
    // Maps the target's coordinates to the barrier's (see [FollowerLayer.getLastTransform]). The barrier's coordinates
    // are offset from this layer's by the barrier's paint offset, which is the top left of [bounds].
    final Matrix4? targetTransform = targetProbe?.getLastTransform();
    if (targetTransform == null) return null;
    return _spotlightPath(spotlight, link?.leaderSize, textDirection)
        ?.transform(targetTransform.storage)
        .shift(bounds.topLeft);
  }
}

/// A [CompositedTransformFollower] whose offset comes from [boxPosition], so that the tooltip, laid out against the
/// same [boxPosition], lines up with the target without being rebuilt.
///
/// The tooltip is laid out in the [Overlay]'s coordinates, against where the target was on the last frame. The offset
/// takes those coordinates back to the target's own, and the follower then puts them where the target is on this
/// frame. So between two updates of [boxPosition], the tooltip moves with the target exactly; an update only changes
/// where the tooltip sits against the [Overlay]'s edges.
class _TargetFollower extends SingleChildRenderObjectWidget {
  const _TargetFollower({
    required this.link,
    required this.showWhenUnlinked,
    required this.boxPosition,
    super.child,
  });

  final LayerLink link;
  final bool showWhenUnlinked;
  final ValueListenable<RenderBoxPosition> boxPosition;

  @override
  _RenderTargetFollower createRenderObject(BuildContext context) {
    return _RenderTargetFollower(
      link: link,
      showWhenUnlinked: showWhenUnlinked,
      boxPosition: boxPosition,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderTargetFollower renderObject) {
    renderObject
      ..link = link
      ..showWhenUnlinked = showWhenUnlinked
      ..boxPosition = boxPosition;
  }
}

class _RenderTargetFollower extends RenderFollowerLayer {
  _RenderTargetFollower({
    required super.link,
    required super.showWhenUnlinked,
    required ValueListenable<RenderBoxPosition> boxPosition,
  })  : _boxPosition = boxPosition,
        super(offset: boxPosition.value.topLeftOffset);

  ValueListenable<RenderBoxPosition> get boxPosition => _boxPosition;
  ValueListenable<RenderBoxPosition> _boxPosition;
  set boxPosition(ValueListenable<RenderBoxPosition> value) {
    if (_boxPosition == value) return;
    if (attached) _boxPosition.removeListener(_updateOffset);
    _boxPosition = value;
    if (attached) _boxPosition.addListener(_updateOffset);
    _updateOffset();
  }

  // Setting [offset] only repaints the follower: nothing is rebuilt or laid out.
  void _updateOffset() => offset = _boxPosition.value.topLeftOffset;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _boxPosition.addListener(_updateOffset);
    _updateOffset();
  }

  @override
  void detach() {
    _boxPosition.removeListener(_updateOffset);
    super.detach();
  }
}
