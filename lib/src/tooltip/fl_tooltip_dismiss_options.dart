part of fl_tooltip;

@immutable
class FlTooltipDismissOptions with Diagnosticable {
  const FlTooltipDismissOptions({
    this.whenBarrierTapped = true,
    this.whenBarrierScrolledHorizontally = true,
    this.whenBarrierScrolledVertically = true,
    this.whenContentTapped = true,
  });

  final bool whenBarrierTapped;
  final bool whenBarrierScrolledHorizontally;
  final bool whenBarrierScrolledVertically;
  final bool whenContentTapped;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlTooltipDismissOptions &&
          other.whenBarrierTapped == whenBarrierTapped &&
          other.whenBarrierScrolledHorizontally ==
              whenBarrierScrolledHorizontally &&
          other.whenBarrierScrolledVertically ==
              whenBarrierScrolledVertically &&
          other.whenContentTapped == whenContentTapped;

  @override
  int get hashCode => Object.hash(
        runtimeType,
        whenBarrierTapped,
        whenBarrierScrolledHorizontally,
        whenBarrierScrolledVertically,
        whenContentTapped,
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty(
        'whenBarrierTapped',
        value: whenBarrierTapped,
        ifTrue: 'dismisses when barrier is tapped',
        ifFalse: 'does not dismiss when barrier is tapped',
        showName: true,
      ))
      ..add(FlagProperty(
        'whenBarrierScrolledHorizontally',
        value: whenBarrierScrolledHorizontally,
        ifTrue: 'dismisses when barrier is scrolled horizontally',
        ifFalse: 'does not dismiss when barrier is scrolled horizontally',
        showName: true,
      ))
      ..add(FlagProperty(
        'whenBarrierScrolledVertically',
        value: whenBarrierScrolledVertically,
        ifTrue: 'dismisses when barrier is scrolled vertically',
        ifFalse: 'does not dismiss when barrier is scrolled vertically',
        showName: true,
      ))
      ..add(FlagProperty(
        'whenContentTapped',
        value: whenContentTapped,
        ifTrue: 'dismisses when content is tapped',
        ifFalse: 'does not dismiss when content is tapped',
        showName: true,
      ));
  }
}
