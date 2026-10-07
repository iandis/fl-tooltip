part of extensions;

extension BuildContextExt on BuildContext {
  /// Where this context's [RenderBox] is, at the size it's laid out at.
  RenderBoxPosition? get boxPosition {
    assert(!debugDoingBuild);
    assert(!(this as Element).debugIsDefunct);

    final RenderObject? renderBox = findRenderObject();
    if (renderBox is! RenderBox) return null;
    return RenderBoxPosition._fromRenderBox(renderBox);
  }

  /// Where this context's [RenderBox] is, at its natural size: the size it would be with the room its parent gives it
  /// (its own constraints, loosened), without being stretched to fill it.
  RenderBoxPosition? get dryBoxPosition {
    assert(!debugDoingBuild);
    assert(!(this as Element).debugIsDefunct);

    final RenderObject? renderBox = findRenderObject();
    if (renderBox is! RenderBox) return null;
    return RenderBoxPosition._fromRenderBoxDryLayout(renderBox);
  }

  RenderBoxPosition get mediaQueryBoxPosition {
    return RenderBoxPosition.fromSize(MediaQuery.of(this).size);
  }
}

extension GlobalKeyExt on GlobalKey {
  RenderBoxPosition? get boxPosition => currentContext?.boxPosition;
  RenderBoxPosition? get dryBoxPosition => currentContext?.dryBoxPosition;
}
