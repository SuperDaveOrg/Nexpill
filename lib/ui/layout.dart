import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Screen-size rules, so tablets get a layout
/// made for them rather than a stretched phone screen. On phones none of
/// this changes anything.

/// The widest a column of text and rows should get before it's hard to read.
const readableWidth = 680.0;

/// From here up, screens may use two columns.
const wideBreakpoint = 840.0;

/// Widest a two-column screen gets.
const wideContentWidth = 1120.0;

bool isWide(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= wideBreakpoint;

/// Padding for a scrolling list that keeps its content [maxWidth] wide and
/// centred, on top of the list's own [base] padding. The list itself stays
/// full width, so it scrolls from anywhere on the screen, margins included.
EdgeInsets readablePadding(
  BuildContext context, {
  EdgeInsets base = EdgeInsets.zero,
  double maxWidth = readableWidth,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final gutter = math.max(0.0, (width - maxWidth) / 2);
  return base + EdgeInsets.symmetric(horizontal: gutter);
}

/// Centres a non-scrolling [child] at a readable width.
class Readable extends StatelessWidget {
  const Readable({super.key, required this.child, this.maxWidth = readableWidth});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      );
}
