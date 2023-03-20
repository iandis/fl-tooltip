part of fl_tooltip;

typedef FlTooltipTargetKey = GlobalKey<FlTooltipTargetState>;

class FlTooltipTarget extends StatefulWidget {
  const FlTooltipTarget({
    required FlTooltipTargetKey super.key,
    required this.child,
  });

  final Widget child;

  @override
  FlTooltipTargetState createState() => FlTooltipTargetState();
}

class FlTooltipTargetState extends State<FlTooltipTarget> {
  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: widget.child,
    );
  }

  final LayerLink _link = LayerLink();
}
