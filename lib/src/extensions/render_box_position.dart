part of extensions;

class RenderBoxPosition with Diagnosticable {
  const RenderBoxPosition._({
    required this.topLeftOffset,
    required this.centerOffset,
    required this.size,
  });

  static (Offset center, Offset topLeft) _getOffsets(RenderBox box, Size size) {
    final Offset centerOffset = box.localToGlobal(
      size.center(Offset.zero),
    );
    final Offset topLeftOffset = Offset(
      -centerOffset.dx + size.width / 2,
      -centerOffset.dy + size.height / 2,
    );
    return (centerOffset, topLeftOffset);
  }

  factory RenderBoxPosition._fromRenderBox(RenderBox renderBox) {
    final Size size = renderBox.size;
    final (Offset centerOffset, Offset topLeftOffset) = _getOffsets(renderBox, size);
    return RenderBoxPosition._(
      topLeftOffset: topLeftOffset,
      centerOffset: centerOffset,
      size: size,
    );
  }

  factory RenderBoxPosition._fromRenderBoxDryLayout(RenderBox renderBox) {
    // The size the box would be with the room its parent gives it, without being stretched to fill it: its own
    // constraints, loosened. Unbounded constraints would make a box that fills the room it's given (e.g. a `Row` with
    // an `Expanded` child, a `TextField`) throw, and would measure a text that wraps or is cut short as one line,
    // wider than its box.
    final Size size = renderBox.getDryLayout(renderBox.constraints.loosen());
    final (Offset centerOffset, Offset topLeftOffset) = _getOffsets(renderBox, size);
    return RenderBoxPosition._(
      topLeftOffset: topLeftOffset,
      centerOffset: centerOffset,
      size: size,
    );
  }

  factory RenderBoxPosition.fromSize(Size size) {
    const Offset offset = Offset.zero;
    final Rect rect = offset & size;
    return RenderBoxPosition._(
      topLeftOffset: rect.topLeft,
      centerOffset: rect.center,
      size: size,
    );
  }

  /// Offset to target's top left corner
  final Offset topLeftOffset;
  final Offset centerOffset;
  final Size size;
  Rect get rect => topLeftOffset & size;

  static const RenderBoxPosition zero = RenderBoxPosition._(
    topLeftOffset: Offset.zero,
    centerOffset: Offset.zero,
    size: Size.zero,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RenderBoxPosition &&
          other.runtimeType == runtimeType &&
          other.topLeftOffset == topLeftOffset &&
          other.centerOffset == centerOffset &&
          other.size == size;

  @override
  int get hashCode => Object.hash(
        runtimeType,
        topLeftOffset,
        centerOffset,
        size,
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Offset>('topLeftOffset', topLeftOffset))
      ..add(DiagnosticsProperty<Offset>('centerOffset', centerOffset))
      ..add(DiagnosticsProperty<Size>('size', size));
  }
}
