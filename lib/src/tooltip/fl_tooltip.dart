/*
Copyright (c) 2021 Rex Magana

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/* 
Copyright (c) 2023 Iandi Santulus

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

library fl_tooltip;

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:fl_tooltip/src/extensions/_extensions.dart';
import 'package:fl_tooltip/src/rendering/_rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

part 'single_child_tooltip.dart';
part 'fl_tooltip_target.dart';
part 'fl_tooltip_theme.dart';
part 'fl_tooltip_transitions_builder.dart';
part 'fl_tooltip_dismiss_options.dart';
part 'fl_tooltip_entry.dart';
part 'fl_tooltip_entry_options.dart';

typedef FlTooltipKey = GlobalKey<FlTooltipState>;

/// A widget to display a tooltip over target widget. The tooltip can be
/// displayed on any axis of the widget and fallback to the opposite axis if
/// the tooltip does cannot fit its content.
class FlTooltip extends StatefulWidget {
  const FlTooltip({
    super.key,
    this.useRootOverlay = false,
    this.targetKey,
    required this.options,
    required this.child,
  });

  final FlTooltipEntryOptions options;

  final bool useRootOverlay;

  /// The key of the target widget. If null, the tooltip will be linked to the
  /// [child] widget.
  final FlTooltipTargetKey? targetKey;

  /// The child widget the tooltip will hover over.
  final Widget child;

  @override
  FlTooltipState createState() => FlTooltipState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<FlTooltipEntryOptions>('options', options))
      ..add(FlagProperty(
        'useRootOverlay',
        value: useRootOverlay,
        ifTrue: 'use root overlay',
        ifFalse: 'use nearest overlay',
      ));
  }
}

class FlTooltipState extends State<FlTooltip>
    with SingleTickerProviderStateMixin<FlTooltip> {
  @override
  Widget build(BuildContext context) {
    return FlTooltipTarget(
      key: _childKey,
      child: widget.child,
    );
  }

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
    )..addStatusListener(_handleStatusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final FlTooltipTransitionsBuilder transitionsBuilder =
        widget.options.transitionsBuilder ??
            FlTooltipEntryOptions._effectiveTransitionsBuilderOf(context);
    _animationController
      ..duration = transitionsBuilder.duration
      ..reverseDuration = transitionsBuilder.reverseDuration;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlayEntry();
    super.dispose();
  }

  void _handleStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      _removeOverlayEntry();
    }
  }

  Future<void> showTooltip() async {
    if (!isShowing) {
      _createOverlayEntry();
    }
    await _animationController.forward();
  }

  Future<void> hideTooltip() async {
    if (!isShowing) return;
    await _animationController.reverse();
    _removeOverlayEntry();
  }

  void _removeOverlayEntry() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void deactivate() {
    if (isShowing) {
      _removeOverlayEntry();
    }
    super.deactivate();
  }

  @override
  void didUpdateWidget(covariant FlTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldUpdateTooltipOverlay(oldWidget)) {
      _scheduleUpdateOverlayEntry();
    }
  }

  bool _shouldUpdateTooltipOverlay(FlTooltip oldWidget) {
    return oldWidget.targetKey != widget.targetKey ||
        oldWidget.useRootOverlay != widget.useRootOverlay ||
        oldWidget.options != widget.options;
  }

  void _scheduleUpdateOverlayEntry() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final OverlayEntry? overlayEntry = _overlayEntry;
      if (!mounted || overlayEntry == null || !overlayEntry.mounted) {
        return;
      }
      overlayEntry.markNeedsBuild();
    });
  }

  OverlayEntry? _overlayEntry;

  /// Whether the tooltip is currently showing.
  bool get isShowing => _overlayEntry != null;

  void _createOverlayEntry() {
    final OverlayState overlay = Overlay.of(
      context,
      rootOverlay: widget.useRootOverlay,
      debugRequiredFor: widget,
      // this is to support older flutter version
      // ignore: unnecessary_non_null_assertion
    )!;
    final OverlayEntry entry = OverlayEntry(builder: _buildEntry);
    _overlayEntry = entry;
    overlay.insert(entry);
  }

  final FlTooltipTargetKey _childKey = FlTooltipTargetKey();
  FlTooltipTargetKey get _targetKey => widget.targetKey ?? _childKey;

  Widget _buildEntry(BuildContext context) {
    return FlTooltipEntry(
      animation: _animationController.view,
      options: widget.options,
      targetKey: _targetKey,
      onDismissTooltip: hideTooltip,
    );
  }
}
