part of extensions;

class RenderBoxPosition with Diagnosticable {
  const RenderBoxPosition._({
    required this.topLeftOffset,
    required this.centerOffset,
    required this.size,
  });

  factory RenderBoxPosition._fromRenderBox(RenderBox renderBox) {
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Rect rect = offset & size;
    return RenderBoxPosition._(
      topLeftOffset: offset,
      centerOffset: rect.center,
      size: size,
    );
  }

  factory RenderBoxPosition._fromRenderBoxDryLayout(RenderBox renderBox) {
    final Size size = renderBox.getDryLayout(
      const BoxConstraints.tightForFinite(),
    );
    final Offset centerOffset = renderBox.localToGlobal(
      renderBox.size.center(Offset.zero),
    );
    final Offset topLeftOffset = Offset(
      -centerOffset.dx + renderBox.size.width / 2,
      -centerOffset.dy + renderBox.size.height / 2,
    );
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
