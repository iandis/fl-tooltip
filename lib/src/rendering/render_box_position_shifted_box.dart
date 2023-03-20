part of rendering;

abstract class RenderBoxPositionShiftedBox extends RenderShiftedBox {
  RenderBoxPositionShiftedBox({
    required RenderBoxPosition boxPosition,
    Alignment alignment = Alignment.center,
    RenderBox? child,
  })  : _alignment = alignment,
        _boxPosition = boxPosition,
        super(child);

  Alignment _alignment;
  Alignment get alignment => _alignment;
  set alignment(Alignment value) {
    if (value == _alignment) return;
    _alignment = value;
    markNeedsLayout();
  }

  RenderBoxPosition _boxPosition;
  RenderBoxPosition get boxPosition => _boxPosition;
  set boxPosition(RenderBoxPosition value) {
    if (value == _boxPosition) return;
    _boxPosition = value;
    markNeedsLayout();
  }

  @protected
  void alignChild() {
    assert(child != null);
    assert(!child!.debugNeedsLayout);
    assert(child!.hasSize);
    assert(hasSize);
    final BoxParentData childParentData = child!.parentData! as BoxParentData;
    // Child's center offset from its top left corner
    final double childX = boxPosition.centerOffset.dx - 0.5 * child!.size.width;
    final double childY =
        boxPosition.centerOffset.dy - 0.5 * child!.size.height;

    final double xAlignmentMultiplier = -0.5 * alignment.x;
    final double yAlignmentMultiplier = -0.5 * alignment.y;

    final Offset alignedOffset = Offset(
      childX - xAlignmentMultiplier * boxPosition.size.width,
      childY - yAlignmentMultiplier * boxPosition.size.height,
    );
    childParentData.offset = alignedOffset;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Alignment>('alignment', alignment))
      ..add(DiagnosticsProperty<RenderBoxPosition>('boxPosition', boxPosition));
  }
}
