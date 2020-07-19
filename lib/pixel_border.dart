import 'dart:math';

import 'package:flutter/widgets.dart';

///
/// A ShapeBorder to draw a box with pixelated corners.
///
class PixelBorder extends ShapeBorder {
  /// The radii for each corner.
  ///
  /// Each corner [Radius] defines the endpoints that will be connected by
  /// "pixels" (squares) with size [pixelSize].
  ///
  /// For the border to be drawn properly, each radius must be a multiple of
  /// [pixelSize]
  final BorderRadiusGeometry borderRadius;

  /// size of a "pixel"
  /// the smaller, the less pixel-y the shape will look
  final double pixelSize;

  /// The style of this border
  final BorderStyle style;

  /// The color of the border (if drawn)
  final Color borderColor;

  const PixelBorder({
    @required this.borderRadius,
    @required this.pixelSize,
    this.style = BorderStyle.none,
    this.borderColor = const Color(0xFF000000),
  }) : assert(pixelSize > 0);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(
        (style == BorderStyle.none) ? 0.0 : pixelSize,
      );

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) => _getPath(
        borderRadius
            .resolve(textDirection)
            .toRRect(rect)
            .deflate(style == BorderStyle.solid ? pixelSize : 0.0),
      );

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) =>
      _getPath(borderRadius.resolve(textDirection).toRRect(rect));

  Path _getPath(RRect rrect) {
    assert(borderRadius % pixelSize == BorderRadius.zero);

    // check if radii are larger than half of respective side and adjust if necessary
    final double Function(Radius) getRadius = (Radius radius) {
      final maxRadius = max(0.0, max(radius.y, radius.x));
      final side = min(rrect.height, rrect.width);
      return (min(side / 2, maxRadius) ~/ pixelSize) * pixelSize;
    };

    final tlRadius = getRadius(rrect.tlRadius);
    final trRadius = getRadius(rrect.trRadius);
    final blRadius = getRadius(rrect.blRadius);
    final brRadius = getRadius(rrect.brRadius);

    final tlYStart = min(rrect.center.dy, rrect.top + tlRadius);
    final tlXEnd = min(rrect.center.dx, rrect.left + tlRadius);

    final trXStart = max(rrect.center.dx, rrect.right - trRadius);
    final trYEnd = min(rrect.center.dy, rrect.top + trRadius);

    final brYStart = max(rrect.center.dy, rrect.bottom - brRadius);
    final brXEnd = max(rrect.center.dx, rrect.right - brRadius);

    final blXStart = min(rrect.center.dx, rrect.left + blRadius);
    final blYEnd = max(rrect.center.dy, rrect.bottom - blRadius);

    final List<Offset> vertices = [
      Offset(rrect.left, tlYStart),

      // top left corner
      for (double i = pixelSize; i <= tlXEnd - rrect.left; i += pixelSize) ...[
        Offset(rrect.left + i, tlYStart - i + pixelSize),
        Offset(rrect.left + i, tlYStart - i),
      ],

      // top line
      Offset(trXStart, rrect.top),

      // top right corner
      for (double i = pixelSize; i <= trYEnd - rrect.top; i += pixelSize) ...[
        Offset(trXStart + i - pixelSize, rrect.top + i),
        Offset(trXStart + i, rrect.top + i),
      ],

      // right line
      Offset(rrect.right, brYStart),

      // bottom right corner
      for (double i = pixelSize; i <= rrect.right - brXEnd; i += pixelSize) ...[
        Offset(rrect.right - i, brYStart + i - pixelSize),
        Offset(rrect.right - i, brYStart + i),
      ],

      // bottom line
      Offset(blXStart, rrect.bottom),

      // bottom left corner
      for (double i = pixelSize;
          i <= rrect.bottom - blYEnd;
          i += pixelSize) ...[
        Offset(blXStart - i + pixelSize, rrect.bottom - i),
        Offset(blXStart - i, rrect.bottom - i),
      ],
    ];

    return Path()..addPolygon(vertices, true);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    if (rect.isEmpty || style == BorderStyle.none) return;

    final Path path = getOuterPath(rect, textDirection: textDirection)
      ..addPath(getInnerPath(rect), Offset.zero);
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = pixelSize
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  ShapeBorder scale(double t) => PixelBorder(
        borderRadius: borderRadius * t,
        pixelSize: pixelSize * t,
        style: style,
        borderColor: borderColor,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PixelBorder &&
          pixelSize == other.pixelSize &&
          borderRadius == other.borderRadius &&
          style == other.style &&
          borderColor == other.borderColor;

  @override
  int get hashCode => hashValues(pixelSize, borderRadius);

  @override
  String toString() => "PixelBorder(\n"
      "\tpixelSize: $pixelSize,\n"
      "\borderRadius: $borderRadius,\n"
      "\tstyle: $style,\n"
      "\tborderColor: $borderColor,\n"
      ")";
}
