# pixel_border

[![pub](https://img.shields.io/badge/pub-2.0.0--nullsafety.0-blue.svg)](https://pub.dev/packages/pixel_border) ![test](https://github.com/aqulu/flutter_pixel_border/workflows/test/badge.svg) ![lint](https://github.com/aqulu/flutter_pixel_border/workflows/lint/badge.svg)

A package to render shapes or borders of widgets with pixelated corners.

## Usage

PixelBorder can be used the same way built-in ShapeBorders are, by setting the shape property on any Widget supporting it.

Some examples include:

Drawing an orange square border where all corners are rounded and drawn with "pixels" of size 2.0

```dart
Container(
  decoration: ShapeDecoration(
    shape: PixelBorder.solid(
      borderRadius: BorderRadius.circular(4.0),
      pixelSize: 2.0,
      color: Colors.orange,
    ),
  ),
  height: 42.0,
  width: 42.0,
);
```

Setting the default button shape in MaterialApp:

```dart
MaterialApp(
  theme: ThemeData(
    buttonTheme: ButtonThemeData(
      shape: PixelBorder.shape(
        borderRadius: BorderRadius.circular(10),
        pixelSize: 5,
      ),
    ),
  ),
);
```

For corners to be drawn properly, `PixelBorder` requires the radii defined in `borderRadius` to be a multiple of `pixelSize`.

![examples](assets/border_examples.png)
