## 0.1.0

- **Breaking:** `FlTooltipEntryBarrier` no longer takes a `builder`. Its default constructor draws the barrier with
  `color`, and blurs what's behind it with `blurSigma`. A custom barrier moves to `FlTooltipEntryBarrier.custom`, whose
  `builder` draws the barrier's look only.
- Add `FlTooltipSpotlight`, a hole in the barrier around the target, with a `padding`, a `shape` (any `ShapeBorder`),
  an optional `decorationBuilder`, and `allowTargetInteraction`. By default, the hole takes gestures like the rest of
  the barrier does, so the target doesn't get them.
- The barrier stays on its `Overlay` instead of moving with the target, so it always covers the `Overlay`.
- The spotlight hole follows the target on every frame, without rebuilding or repainting anything.
- The tooltip follows the target when the target moves without the tooltip being rebuilt (a route transition, a
  scroll), and is placed again against the `Overlay`'s edges, without rebuilding its content.
- Fix the tooltip throwing when its target is disposed while the tooltip shows.
- **Breaking:** `FlTooltipEntryOptions.useDryLayout` defaults to false: the tooltip points at the size the target is
  laid out at.
- **Breaking:** with `useDryLayout: true`, the target is measured with its own constraints, loosened, instead of
  unbounded ones (`BuildContext.dryBoxPosition` and `GlobalKey.dryBoxPosition` too). A target that fills the room it's
  given (a `Row` with an `Expanded` child, a `TextField`) no longer throws, and is measured as it's laid out. A text that
  wraps, or is cut short with an ellipsis, is measured as it's drawn instead of as one line.
- **Breaking:** `FlTooltipEntryOptions.alignment`, `direction`, `alternativeDirections` and `position` are replaced by
  `positionOptions`: a set of `FlTooltipPosition` (`direction`, `alignment`, `position`), in order of preference. Each
  option has its own `alignment` and `position`, so the tooltip can point at a different point of the target on each
  side. Defaults to `{FlTooltipPosition(direction: AxisDirection.down, alignment: Alignment.center)}`.
- The tooltip goes to the first of `positionOptions` it fits in, else the first one. It used to go to the last
  alternative direction it fit in.
- `positionOptions` must not be empty: an empty `const` set doesn't compile, and showing a tooltip with an empty one
  throws. A position that is the same as an earlier one is left out, also when comparing two `FlTooltipEntryOptions`;
  debug mode reports it.
- Compare `useDryLayout` in `FlTooltipEntryOptions` equality, so that changing it updates a showing tooltip.

## 0.0.2

- Add `RenderBoxPosition.rect`
- Remove dependency to material library
- Add `alternativeDirections` and `edgePadding`
- Upgrade to Flutter 3.13.9
- Add checking for `tailLength`
- Add `addAnimationStatusListener` and `removeAnimationStatusListener`
- Make barrier optional
- Fix content not showing when barrier is not null
- Fix barrier still dismissible when false
- Fix non dry box position offset
- Fix `RenderBoxPosition` from `FlTooltipEntry` not updated when the parent or screen size changes

## 0.0.1

- Update sdk constraint to '>=2.18.6 <4.0.0'
- Expose `rendering` library

## 0.0.1-alpha.0

- Initial release
