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

    final Offset centerLeft = Offset(rrect.left, rrect.center.dy);
    final Offset centerRight = Offset(rrect.right, rrect.center.dy);
    final Offset centerTop = Offset(rrect.center.dx, rrect.top);
    final Offset centerBottom = Offset(rrect.center.dx, rrect.bottom);

    final tlYStart = min(centerLeft.dy, rrect.top + max(0.0, rrect.tlRadiusY));
    final tlXEnd = min(centerTop.dx, rrect.left + max(0.0, rrect.tlRadiusX));

    final trXStart = max(centerTop.dx, rrect.right - max(0.0, rrect.trRadiusX));
    final trYEnd = min(centerRight.dy, rrect.top + max(0.0, rrect.trRadiusY));

    final brYStart = max(
      centerRight.dy,
      rrect.bottom - max(0.0, rrect.brRadiusY),
    );
    final brXEnd = max(
      centerBottom.dx,
      rrect.right - max(0.0, rrect.brRadiusX),
    );

    final blXStart = min(
      centerBottom.dx,
      rrect.left + max(0.0, rrect.blRadiusX),
    );
    final blYEnd = max(
      centerLeft.dy,
      rrect.bottom - max(0.0, rrect.blRadiusY),
    );

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
