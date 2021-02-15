import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_border/pixel_border.dart';

void main() {
  test('negative radii are clamped to 0', () {
    const Rect rect = Rect.fromLTRB(10.0, 20.0, 50.0, 60.0);

    final matcher = _PathMatcher(
      [Offset(10.0, 20.0), Offset(20.0, 60.0)],
      [Offset(9.0, 19.0), Offset(51.0, 61.0)],
    );

    const PixelBorder border = PixelBorder.shape(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(-10)),
      pixelSize: 5.0,
    );

    expect(border.getOuterPath(rect), matcher);
    expect(border.getInnerPath(rect), matcher);
  });

  test('radius is truncated when larger than half of height', () {
    const Rect rect = Rect.fromLTRB(10.0, 10.0, 70.0, 30.0);

    final matcher = _PathMatcher(
      [
        // top left corner
        // Offset(10.0, 20.0),
        Offset(15.0, 20.0),
        Offset(15.0, 15.0),
        Offset(20.0, 15.0),
        Offset(20.0, 10.0),

        // top right corner
        Offset(60.0, 10.0),
        Offset(60.0, 15.0),
        Offset(65.0, 15.0),
        Offset(65.0, 20.0),
        // Offset(60.0, 20.0),

        // bottom right corner
        // Offset(60.0, 20.0),
        Offset(65.0, 20.0),
        Offset(65.0, 25.0),
        Offset(60.0, 25.0),
        Offset(60.0, 30.0),

        // bottom left corner
        Offset(20.0, 30.0),
        Offset(20.0, 25.0),
        Offset(15.0, 25.0),
        Offset(15.0, 20.0),
        // Offset(10.0, 20.0),
      ],
      [
        rect.topLeft,
        Offset(25.0, 9.0),
        rect.topRight,
        Offset(71.0, 25.0),
        rect.bottomRight,
        Offset(50.0, 31.0),
        rect.bottomLeft,
        Offset(9.0, 15.0),
      ],
    );

    const PixelBorder border = PixelBorder.shape(
      borderRadius: BorderRadius.all(Radius.circular(20.0)),
      pixelSize: 5.0,
    );

    expect(border.getOuterPath(rect), matcher);
    expect(border.getInnerPath(rect), matcher);
  });

  test('scaling', () {
    final halved = PixelBorder.shape(
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
      pixelSize: 2.5,
    );
    final normal = PixelBorder.shape(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      pixelSize: 5.0,
    );
    final enlarged = PixelBorder.shape(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      pixelSize: 7.5,
    );

    expect(normal.scale(0.5), halved);
    expect(normal.scale(1.0), normal);
    expect(normal.scale(1.5), enlarged);
  });

  test('BorderRadius.zero results in Rectangle', () {
    const Rect rect = Rect.fromLTRB(10.0, 20.0, 50.0, 60.0);

    final matcher = _PathMatcher(
      [Offset(10.0, 20.0), Offset(20.0, 60.0)],
      [Offset(9.0, 19.0), Offset(51.0, 61.0)],
    );

    const PixelBorder border = PixelBorder.shape(
      borderRadius: BorderRadius.zero,
      pixelSize: 5.0,
    );

    expect(border.getOuterPath(rect), matcher);
    expect(border.getInnerPath(rect), matcher);
  });

  test('non-zero BorderRadius', () {
    const Rect rect = Rect.fromLTRB(10.0, 20.0, 50.0, 60.0);

    final matcher = _PathMatcher(
      [
        // top left corner
        Offset(10.0, 30.0),
        Offset(15.0, 30.0),
        Offset(15.0, 25.0),
        Offset(20.0, 25.0),
        Offset(20.0, 20.0),
        // top right corner
        Offset(40.0, 20.0),
        Offset(40.0, 25.0),
        Offset(45.0, 25.0),
        Offset(45.0, 30.0),
        Offset(50.0, 30.0),
        // bottom right corner
        Offset(50.0, 50.0),
        Offset(45.0, 50.0),
        Offset(45.0, 55.0),
        Offset(40.0, 55.0),
        Offset(40.0, 60.0),
        // bottom left corner
        Offset(20.0, 60.0),
        Offset(20.0, 55.0),
        Offset(15.0, 55.0),
        Offset(15.0, 50.0),
        Offset(10.0, 50.0),
      ],
      [rect.topLeft, rect.topRight, rect.bottomLeft, rect.bottomRight],
    );

    const PixelBorder border = PixelBorder.shape(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      pixelSize: 5.0,
    );

    expect(border.getOuterPath(rect), matcher);
    expect(border.getInnerPath(rect), matcher);
  });

  test('pixelSize larger than borderRadius', () {
    const Rect rect = Rect.fromLTRB(10.0, 20.0, 50.0, 60.0);

    const PixelBorder border = PixelBorder.shape(
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
      pixelSize: 10.0,
    );

    expect(
      () => border.getOuterPath(rect),
      throwsA(isInstanceOf<AssertionError>()),
    );
    expect(
      () => border.getInnerPath(rect),
      throwsA(isInstanceOf<AssertionError>()),
    );
  });

  test('borderRadius is not multiple of pixelSize', () {
    const Rect rect = Rect.fromLTRB(10.0, 20.0, 50.0, 60.0);

    const PixelBorder border = PixelBorder.shape(
      borderRadius: BorderRadius.all(Radius.circular(7.0)),
      pixelSize: 5.0,
    );

    expect(
      () => border.getOuterPath(rect),
      throwsA(isInstanceOf<AssertionError>()),
    );
    expect(
      () => border.getInnerPath(rect),
      throwsA(isInstanceOf<AssertionError>()),
    );
  });

  test(
    'when height is multiple of pixelSize and radius bigger than height / 2 '
    'radius is recalculated for side to be at least 2*pixelSize high',
    () {
      const Rect rect = Rect.fromLTRB(10.0, 10.0, 310.0, 210.0);

      final matcher = _PathMatcher(
        [
          // left side
          Offset(10.0, 90.0),
          Offset(10.0, 130.0),

          // right side
          Offset(310.0, 90.0),
          Offset(310.0, 130.0),
        ],
        [
          // left side
          Offset(10.0, 89.0),
          Offset(10.0, 131.0),

          // right side
          Offset(310.0, 89.0),
          Offset(310.0, 131.0),
        ],
      );

      const PixelBorder border = PixelBorder.shape(
        borderRadius: BorderRadius.all(Radius.circular(200.0)),
        pixelSize: 20.0,
      );

      expect(border.getOuterPath(rect), matcher);
      expect(border.getInnerPath(rect), matcher);
    },
  );

  test(
    'pixelSize == borderRadius == height/2 == width/2 '
    'results in rectangle',
    () {
      const Rect rect = Rect.fromLTRB(10.0, 10.0, 20.0, 20.0);

      const PixelBorder border = PixelBorder.shape(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        pixelSize: 5.0,
      );

      final matcher = _PathMatcher(
        [
          Offset(10.0, 10.0),
          Offset(20.0, 10.0),
          Offset(20.0, 20.0),
          Offset(10.0, 20.0),
        ],
        [
          Offset(9.0, 9.0),
          Offset(21.0, 9.0),
          Offset(21.0, 21.0),
          Offset(9.0, 21.0),
        ],
      );

      expect(border.getOuterPath(rect), matcher);
      expect(border.getInnerPath(rect), matcher);
    },
  );
}

/// ref: https://github.com/flutter/flutter/blob/4d7525f05c05a6df0b29396bc9eb78c3bf1e9f89/packages/flutter/test/rendering/mock_canvas.dart#L447
class _PathMatcher extends Matcher {
  _PathMatcher(this.includes, this.excludes);

  List<Offset> includes;
  List<Offset> excludes;

  @override
  bool matches(Object? object, Map<dynamic, dynamic> matchState) {
    if (object is! Path) {
      matchState[this] = 'The given object ($object) was not a Path.';
      return false;
    }
    final Path path = object;
    final List<String> errors = <String>[
      for (final Offset offset in includes)
        if (!path.contains(offset))
          'Offset $offset should be inside the path, but is not.',
      for (final Offset offset in excludes)
        if (path.contains(offset))
          'Offset $offset should be outside the path, but is not.',
    ];
    if (errors.isEmpty) return true;
    matchState[this] =
        'Not all the given points were inside or outside the path as expected:\n  ${errors.join("\n  ")}';
    return false;
  }

  @override
  Description describe(Description description) {
    String points(List<Offset> list) {
      final int count = list.length;
      if (count == 1) return 'one particular point';
      return '$count particular points';
    }

    return description.add(
        'A Path that contains ${points(includes)} but does not contain ${points(excludes)}.');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description description,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    return description.add(matchState[this] as String);
  }
}
