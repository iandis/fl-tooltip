part of fl_tooltip;

class _SingleChildTooltip extends SingleChildRenderObjectWidget {
  const _SingleChildTooltip({
    required this.boxPosition,
    required this.alignment,
    required this.direction,
    required this.alternativeDirections,
    required this.margin,
    required this.edgePadding,
    required this.position,
    required this.borderRadius,
    required this.tailLength,
    required this.tailBaseWidth,
    required this.tailBuilder,
    required this.textDirection,
    required this.backgroundColor,
    required this.shadow,
    required this.elevation,
    super.child,
  });

  final RenderBoxPosition boxPosition;
  final Alignment alignment;
  final AxisDirection direction;
  final Set<AxisDirection> alternativeDirections;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry edgePadding;
  final double position;
  final BorderRadiusGeometry borderRadius;
  final double tailLength;
  final double tailBaseWidth;
  final TailBuilder tailBuilder;
  final TextDirection textDirection;
  final Color backgroundColor;
  final Shadow shadow;
  final double elevation;

  @override
  _RenderSingleChildTooltip createRenderObject(BuildContext context) {
    return _RenderSingleChildTooltip(
      boxPosition: boxPosition,
      alignment: alignment,
      direction: direction,
      alternativeDirections: alternativeDirections,
      margin: margin,
      edgePadding: edgePadding,
      position: position,
      borderRadius: borderRadius,
      tailLength: tailLength,
      tailBaseWidth: tailBaseWidth,
      tailBuilder: tailBuilder,
      textDirection: textDirection,
      backgroundColor: backgroundColor,
      shadow: shadow,
      elevation: elevation,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSingleChildTooltip renderObject,
  ) {
    renderObject
      ..boxPosition = boxPosition
      ..alignment = alignment
      ..direction = direction
      ..alternativeDirections = alternativeDirections
      ..margin = margin
      ..edgePadding = edgePadding
      ..position = position
      ..borderRadius = borderRadius
      ..tailLength = tailLength
      ..tailBaseWidth = tailBaseWidth
      ..tailBuilder = tailBuilder
      ..textDirection = textDirection
      ..backgroundColor = backgroundColor
      ..shadow = shadow
      ..elevation = elevation;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<RenderBoxPosition>(
      'boxPosition',
      boxPosition,
    ));
    properties.add(DiagnosticsProperty<Alignment>('alignment', alignment));
    properties.add(DiagnosticsProperty<AxisDirection>('direction', direction));
    properties.add(DiagnosticsProperty<Set<AxisDirection>>(
      'alternativeDirections',
      alternativeDirections,
    ));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('margin', margin));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>(
      'edgePadding',
      edgePadding,
    ));
    properties.add(DoubleProperty('position', position));
    properties.add(
      DiagnosticsProperty<BorderRadiusGeometry>('borderRadius', borderRadius),
    );
    properties.add(DoubleProperty('tailLength', tailLength));
    properties.add(DoubleProperty('tailBaseWidth', tailBaseWidth));
    properties.add(ObjectFlagProperty<TailBuilder>.has(
      'tailBuilder',
      tailBuilder,
    ));
    properties.add(
      DiagnosticsProperty<TextDirection>('textDirection', textDirection),
    );
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(DiagnosticsProperty<Shadow>('shadow', shadow));
    properties.add(DoubleProperty('elevation', elevation));
  }
}

class _RenderSingleChildTooltip extends RenderAlignBoxPosition {
  _RenderSingleChildTooltip({
    required super.boxPosition,
    super.alignment,
    required AxisDirection direction,
    required Set<AxisDirection> alternativeDirections,
    required EdgeInsetsGeometry margin,
    required EdgeInsetsGeometry edgePadding,
    required double position,
    required BorderRadiusGeometry borderRadius,
    required double tailLength,
    required double tailBaseWidth,
    required TailBuilder tailBuilder,
    required TextDirection textDirection,
    required Color backgroundColor,
    required Shadow shadow,
    required double elevation,
  })  : _direction = direction,
        _resolvedDirection = direction,
        _alternativeDirections = alternativeDirections,
        _margin = margin,
        _resolvedMargin = margin.resolve(textDirection),
        _edgePadding = edgePadding,
        _resolvedEdgePadding = edgePadding.resolve(textDirection),
        _position = position,
        _borderRadius = borderRadius,
        _tailLength = tailLength,
        _tailBaseWidth = tailBaseWidth,
        _tailBuilder = tailBuilder,
        _textDirection = textDirection,
        _backgroundColor = backgroundColor,
        _shadow = shadow,
        _elevation = elevation;

  AxisDirection _resolvedDirection;
  AxisDirection get direction => _direction;
  AxisDirection _direction;
  set direction(AxisDirection value) {
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }

  Set<AxisDirection> get alternativeDirections => _alternativeDirections;
  Set<AxisDirection> _alternativeDirections;
  set alternativeDirections(Set<AxisDirection> value) {
    if (_alternativeDirections == value) return;
    _alternativeDirections = value;
    markNeedsLayout();
  }

  EdgeInsets _resolvedMargin;
  EdgeInsetsGeometry get margin => _margin;
  EdgeInsetsGeometry _margin;
  set margin(EdgeInsetsGeometry value) {
    if (_margin == value) return;
    _margin = value;
    _resolvedMargin = value.resolve(textDirection);
    markNeedsLayout();
  }

  EdgeInsets _resolvedEdgePadding;
  EdgeInsetsGeometry get edgePadding => _edgePadding;
  EdgeInsetsGeometry _edgePadding;
  set edgePadding(EdgeInsetsGeometry value) {
    if (_edgePadding == value) return;
    _edgePadding = value;
    _resolvedEdgePadding = value.resolve(textDirection);
    markNeedsLayout();
  }

  double get position => _position;
  double _position;
  set position(double value) {
    if (_position == value) return;
    _position = value;
    markNeedsLayout();
  }

  BorderRadiusGeometry get borderRadius => _borderRadius;
  BorderRadiusGeometry _borderRadius;
  set borderRadius(BorderRadiusGeometry value) {
    if (_borderRadius == value) return;
    _borderRadius = value;
    markNeedsLayout();
  }

  double get tailLength => _tailLength;
  double _tailLength;
  set tailLength(double value) {
    if (_tailLength == value) return;
    _tailLength = value;
    markNeedsLayout();
  }

  double get tailBaseWidth => _tailBaseWidth;
  double _tailBaseWidth;
  set tailBaseWidth(double value) {
    if (_tailBaseWidth == value) return;
    _tailBaseWidth = value;
    markNeedsLayout();
  }

  TailBuilder get tailBuilder => _tailBuilder;
  TailBuilder _tailBuilder;
  set tailBuilder(TailBuilder value) {
    if (_tailBuilder == value) return;
    _tailBuilder = value;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    _resolvedMargin = margin.resolve(value);
    markNeedsLayout();
  }

  Color get backgroundColor => _backgroundColor;
  Color _backgroundColor;
  set backgroundColor(Color value) {
    if (_backgroundColor == value) return;
    _backgroundColor = value;
    markNeedsPaint();
  }

  Shadow get shadow => _shadow;
  Shadow _shadow;
  set shadow(Shadow value) {
    if (_shadow == value) return;
    _shadow = value;
    markNeedsPaint();
  }

  double get elevation => _elevation;
  double _elevation;
  set elevation(double value) {
    if (_elevation == value) return;
    _elevation = value;
    markNeedsPaint();
  }

  double get _tailMargin => _getTailMargin(_resolvedDirection);

  double _getTailMargin(AxisDirection direction) {
    final EdgeInsets resolvedMargin = margin.resolve(textDirection);
    switch (direction) {
      case AxisDirection.up:
        return resolvedMargin.bottom;
      case AxisDirection.down:
        return resolvedMargin.top;
      case AxisDirection.right:
        return resolvedMargin.left;
      case AxisDirection.left:
        return resolvedMargin.right;
    }
  }

  (Offset, AxisDirection) _resolveChildOffsetAndAxisDirection(Size childSize) {
    AxisDirection? resolvedDirection;
    Offset? resolvedChildOffset;
    final List<AxisDirection> directionsToResolve = {
      direction,
      ...alternativeDirections,
    }.toList();
    while (directionsToResolve.isNotEmpty) {
      final double childXOffset;
      final double childYOffset;
      final AxisDirection direction = directionsToResolve.removeAt(0);
      final double additionalOffset = _getTailMargin(direction) + tailLength;
      final Size childSizeWithTail;

      // Alignment Modifier:
      // dx = 0.5 x alignmentX x target width
      // dy = 0.5 x alignmentY x target height
      switch (direction) {
        // Offset:
        // dx = target center dx + (-0.5 x child width) + xAlignmentModifier
        // dy = target center dy + (-1.0 x child height) + yAlignmentModifier
        case AxisDirection.up:

        // Offset:
        // dx = target center dx + (-0.5 x child width) + xAlignmentModifier
        // child is already at the bottom, no need to calculate its height,
        // hence the 0.0 x child height
        // dy = target center dy + (0.0 x child height) + yAlignmentModifier
        case AxisDirection.down:
          final double childHeight = childSize.height;
          final double childYOffsetMultiplier =
              direction == AxisDirection.up ? -1.0 : 0.0;
          final double additionalYOffsetMultiplier =
              direction == AxisDirection.up ? -1.0 : 1.0;
          final double yAdditionalOffset =
              additionalYOffsetMultiplier * additionalOffset;
          childXOffset = -0.5 * childSize.width;
          childYOffset =
              childYOffsetMultiplier * childHeight + yAdditionalOffset;
          childSizeWithTail = Size(
            childSize.width,
            childSize.height + tailLength,
          );
        // Offset:
        // child is already at the right, no need to calculate its width,
        // hence the 0.0 x child width
        // dx = target center dx + (0.0 x child width) + xAlignmentModifier
        // dy = target center dy + (-0.5 x child height) + yAlignmentModifier
        case AxisDirection.right:
        // Offset:
        // dx = target center dx + (-1.0 x child width) + xAlignmentModifier
        // dy = target center dy + (-0.5 x child height) + yAlignmentModifier
        case AxisDirection.left:
          final double childWidth = childSize.width;
          final double childXOffsetMultiplier =
              direction == AxisDirection.right ? 0.0 : -1.0;
          final double additionalXOffsetMultiplier =
              direction == AxisDirection.right ? 1.0 : -1.0;
          final double xAdditionalOffset =
              additionalXOffsetMultiplier * additionalOffset;
          childXOffset =
              childXOffsetMultiplier * childWidth + xAdditionalOffset;
          childYOffset = -0.5 * childSize.height;
          childSizeWithTail = Size(
            childSize.width + tailLength,
            childSize.height,
          );
      }
      // x
      final double targetCenterDx = boxPosition.centerOffset.dx;
      final double xAlignmentModifier =
          0.5 * alignment.x * boxPosition.size.width;
      final double dx = targetCenterDx + childXOffset + xAlignmentModifier;

      // y
      final double targetCenterDy = boxPosition.centerOffset.dy;
      final double yAlignmentModifier =
          0.5 * alignment.y * boxPosition.size.height;
      final double dy = targetCenterDy + childYOffset + yAlignmentModifier;

      final Offset alignedOffset = Offset(dx, dy);
      final Offset translatedAlignedOffset = _computeTranslatedAlignedOffset(
        alignedOffset: alignedOffset,
        childSize: childSize,
        direction: direction,
        position: position,
      );
      final Offset boundedAlignedOffset = _computeBoundedAlignedOffset(
        alignedOffset: translatedAlignedOffset,
        childSize: childSize,
        constraints: constraints,
        resolvedMargin: _resolvedMargin,
        resolvedEdgePadding: _resolvedEdgePadding,
      );
      final bool boundedOffsetNotCrossing = _boundedOffsetNotCrossing(
        unboundedOffset: alignedOffset,
        boundedOffset: boundedAlignedOffset,
        direction: direction,
        size: childSizeWithTail,
      );

      if (direction == this.direction || boundedOffsetNotCrossing) {
        resolvedChildOffset = boundedAlignedOffset;
        resolvedDirection = direction;
        if (direction == this.direction && boundedOffsetNotCrossing) break;
      }
    }

    return (resolvedChildOffset!, resolvedDirection!);
  }

  /// This method is just to check if [boundedOffset] calculated by [_computeBoundedAlignedOffset]
  /// is not crossing the starting point of the tail calculated in [unboundedOffset].
  static bool _boundedOffsetNotCrossing({
    required Offset unboundedOffset,
    required Offset boundedOffset,
    required AxisDirection direction,
    required Size size,
  }) {
    final Rect unboundedRect = unboundedOffset & size;
    final Rect boundedRect = boundedOffset & size;
    return switch (direction) {
      AxisDirection.left => unboundedRect.right == boundedRect.right,
      AxisDirection.up => unboundedRect.bottom == boundedRect.bottom,
      AxisDirection.right => unboundedRect.left == boundedRect.left,
      AxisDirection.down => unboundedRect.top == boundedRect.top,
    };
  }

  @override
  void alignChild() {
    assert(child != null);
    assert(!child!.debugNeedsLayout);
    assert(child!.hasSize);
    assert(hasSize);

    final (
      resolvedOffset,
      resolvedDirection,
    ) = _resolveChildOffsetAndAxisDirection(child!.size);

    final BoxParentData childParentData = child!.parentData! as BoxParentData;
    childParentData.offset = resolvedOffset;
    _resolvedDirection = resolvedDirection;
  }

  static Offset _computeTranslatedAlignedOffset({
    required Offset alignedOffset,
    required Size childSize,
    required AxisDirection direction,
    required double position,
  }) {
    final double boundedTranslation = math.max(
      -1.0,
      math.min(1.0, position),
    );
    switch (direction) {
      case AxisDirection.up:
      case AxisDirection.down:
        final double maxTranslationX = 0.5 * childSize.width;
        return alignedOffset.translate(
          boundedTranslation * maxTranslationX,
          0.0,
        );
      case AxisDirection.right:
      case AxisDirection.left:
        final double maxTranslationY = 0.5 * childSize.height;
        return alignedOffset.translate(
          0.0,
          boundedTranslation * maxTranslationY,
        );
    }
  }

  static Offset _computeBoundedAlignedOffset({
    required Offset alignedOffset,
    required Size childSize,
    required BoxConstraints constraints,
    required EdgeInsets resolvedMargin,
    required EdgeInsets resolvedEdgePadding,
  }) {
    final insets = resolvedMargin + resolvedEdgePadding;
    final Size size = constraints.biggest;
    final double dx = math.max(
      insets.left,
      math.min(
        size.width - insets.right - childSize.width,
        alignedOffset.dx,
      ),
    );
    final double dy = math.max(
      insets.top,
      math.min(
        size.height - insets.bottom - childSize.height,
        alignedOffset.dy,
      ),
    );
    return Offset(dx, dy);
  }

  @override
  BoxConstraints computeConstraints(BoxConstraints constraints) {
    final BoxConstraints loosenConstraints =
        constraints.loosen().deflate(_resolvedMargin + _resolvedEdgePadding);
    switch (_resolvedDirection) {
      case AxisDirection.up:
      case AxisDirection.down:
        return loosenConstraints.copyWith(
          maxWidth: loosenConstraints.maxWidth,
          maxHeight: loosenConstraints.maxHeight -
              tailLength -
              boxPosition.size.height,
        );
      case AxisDirection.right:
      case AxisDirection.left:
        return loosenConstraints.copyWith(
          maxWidth:
              loosenConstraints.maxWidth - tailLength - boxPosition.size.width,
          maxHeight: loosenConstraints.maxHeight,
        );
    }
  }

  // Copied from [RenderPositionedTooltip.paint] in
  // https://github.com/Nolence/just_the_tooltip/blob/main/lib/src/positioned_tooltip.dart
  @override
  void paint(PaintingContext context, Offset offset) {
    // TODO: add debug paint for overflows

    final RenderBox? child = this.child;
    if (child == null) return;

    final BoxParentData childParentData = child.parentData! as BoxParentData;
    final Offset parentDataOffset = childParentData.offset;
    final Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    final Path path = Path();
    final BorderRadius radius = borderRadius.resolve(textDirection);
    final Offset childOffset = offset + parentDataOffset;
    final Rect rect = childOffset & child.size;

    // TODO: Currently, I don't think this is triggered by an empty child. Dunno
    /// why this is the case or if this is a feature.
    if (!rect.isEmpty && rect.isFinite && !rect.hasNaN) {
      path.addRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: radius.topLeft,
          topRight: radius.topRight,
          bottomLeft: radius.bottomLeft,
          bottomRight: radius.bottomRight,
        ),
      );
      if (tailLength > 0) {
        path.addPath(
          _paintTail(
            rect: rect,
            radius: radius,
          ),
          Offset.zero,
        );
      }

      // TODO: What do I do about the blurSigma property on shadow?
      context.canvas.drawShadow(
        path.shift(shadow.offset),
        shadow.color,
        elevation,
        false,
      );
      context.canvas.drawPath(path, paint);
    }

    context.paintChild(child, childOffset);
  }

  Offset _getTailOffset(Rect childRect) {
    final double xAlignmentMultiplier = -0.5 * alignment.x;
    final double yAlignmentMultiplier = -0.5 * alignment.y;

    final Offset tailOffset = Offset(
      boxPosition.centerOffset.dx -
          xAlignmentMultiplier * boxPosition.size.width,
      boxPosition.centerOffset.dy -
          yAlignmentMultiplier * boxPosition.size.height,
    );

    switch (_resolvedDirection) {
      case AxisDirection.up:
        final double childBottomY = childRect.bottomCenter.dy;
        return tailOffset.translate(
          0,
          childBottomY - (tailOffset.dy - tailLength - _resolvedMargin.bottom),
        );
      case AxisDirection.down:
        final double childTopY = childRect.topCenter.dy;
        return tailOffset.translate(
          0,
          childTopY - (tailOffset.dy + tailLength + _resolvedMargin.top),
        );
      case AxisDirection.right:
        final double childLeftX = childRect.centerLeft.dx;
        return tailOffset.translate(
          childLeftX - (tailOffset.dx + tailLength + _resolvedMargin.left),
          0,
        );
      case AxisDirection.left:
        final double childRightX = childRect.centerRight.dx;
        return tailOffset.translate(
          childRightX - (tailOffset.dx - tailLength - _resolvedMargin.right),
          0,
        );
    }
  }

  // Copied from [RenderPositionedTooltip._paintTail] in
  // https://github.com/Nolence/just_the_tooltip/blob/main/lib/src/positioned_tooltip.dart
  Path _paintTail({
    required Rect rect,
    required BorderRadius radius,
  }) {
    // Clockwise around the triangle starting at the target center
    // point + offset
    double x = 0, y = 0, x2 = 0, y2 = 0, x3 = 0, y3 = 0;
    final Offset target = _getTailOffset(rect);

    switch (_resolvedDirection) {
      case AxisDirection.up:
        final double baseLength = math.min(
          tailBaseWidth,
          (rect.right - rect.left) -
              (radius.bottomLeft.x + radius.bottomRight.x),
        );
        final double halfBaseLength = baseLength / 2;
        final double insetLeftCorner = rect.left + radius.bottomLeft.x;
        final double insetRightCorner = rect.right - radius.bottomRight.x;

        if (insetLeftCorner > insetRightCorner) {
          // This happens when the content is so small, accounting for the
          // border radius messes up our measurements. Might as well not draw
          // a tail at this point
          break;
        }

        final Offset offsetTarget = target.translate(0, -_tailMargin);

        // assert(rect.bottom == _target.dy - tailLength);

        x = offsetTarget.dx;
        y = offsetTarget.dy;

        x2 = (math.min(offsetTarget.dx, insetRightCorner) - halfBaseLength)
            .clamp(insetLeftCorner, insetRightCorner);
        y2 = rect.bottom;

        x3 = (math.max(offsetTarget.dx, insetLeftCorner) + halfBaseLength)
            .clamp(insetLeftCorner, insetRightCorner);
        y3 = rect.bottom;
        break;
      case AxisDirection.down:
        final double baseLength = math.min(
          tailBaseWidth,
          (rect.right - rect.left) - (radius.topLeft.x + radius.topRight.x),
        );
        final double halfBaseLength = baseLength / 2;
        final double insetLeftCorner = rect.left + radius.topLeft.x;
        final double insetRightCorner = rect.right - radius.topRight.x;

        if (insetLeftCorner > insetRightCorner) break;

        final Offset offsetTarget = target.translate(0, _tailMargin);

        assert(rect.top == offsetTarget.dy + tailLength);

        x = offsetTarget.dx;
        y = offsetTarget.dy;

        x2 = (math.max(offsetTarget.dx, insetLeftCorner) + halfBaseLength)
            .clamp(insetLeftCorner, insetRightCorner);
        y2 = rect.top;

        x3 = (math.min(offsetTarget.dx, insetRightCorner) - halfBaseLength)
            .clamp(insetLeftCorner, insetRightCorner);
        y3 = rect.top;
        break;
      case AxisDirection.left:
        final double baseLength = math.min(
          tailBaseWidth,
          (rect.bottom - rect.top) - (radius.topRight.y + radius.bottomRight.y),
        );
        final double halfBaseLength = baseLength / 2;
        final double insetTopCorner = rect.top + radius.topRight.y;
        final double insetBottomCorner = rect.bottom - radius.bottomRight.y;

        if (insetBottomCorner < insetTopCorner) break;

        final Offset offsetTarget = target.translate(-_tailMargin, 0.0);

        assert(rect.right == offsetTarget.dx - tailLength);

        x = offsetTarget.dx;
        y = offsetTarget.dy;

        x2 = rect.right;
        y2 = (math.max(offsetTarget.dy, insetTopCorner) + halfBaseLength)
            .clamp(insetTopCorner, insetBottomCorner);

        x3 = rect.right;
        y3 = (math.min(offsetTarget.dy, insetBottomCorner) - halfBaseLength)
            .clamp(insetTopCorner, insetBottomCorner);

        break;
      case AxisDirection.right:
        final double baseLength = math.min(
          tailBaseWidth,
          (rect.bottom - rect.top) - (radius.topLeft.y + radius.topRight.y),
        );

        final double halfBaseLength = baseLength / 2;
        final double insetBottomCorner = rect.bottom - radius.bottomLeft.y;
        final double insetTopCorner = rect.top + radius.topLeft.y;

        if (insetBottomCorner < insetTopCorner) break;

        final Offset offsetTarget = target.translate(_tailMargin, 0.0);

        assert(rect.left == offsetTarget.dx + tailLength);

        x = offsetTarget.dx;
        y = offsetTarget.dy;

        x2 = rect.left;
        y2 = (math.min(offsetTarget.dy, insetBottomCorner) - halfBaseLength)
            .clamp(insetTopCorner, insetBottomCorner);

        x3 = rect.left;
        y3 = (math.max(offsetTarget.dy, insetTopCorner) + halfBaseLength)
            .clamp(insetTopCorner, insetBottomCorner);
        break;
    }

    return tailBuilder(Offset(x, y), Offset(x2, y2), Offset(x3, y3));
  }
}
