import 'package:flutter/material.dart';
import 'package:pixel_border/pixel_border.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PixelBorder Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Showcase(),
    );
  }
}

class Showcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    child: SizedBox.shrink(),
                    style: ElevatedButton.styleFrom(
                      shape: PixelBorder.shape(
                        borderRadius: BorderRadius.circular(10.0),
                        pixelSize: 5.0,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: ShapeDecoration(
                    shape: PixelBorder.solid(
                      pixelSize: 2.0,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(16.0),
                      ),
                      color: Colors.purple,
                    ),
                  ),
                  height: 200,
                  width: 400,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    shape: PixelBorder.shape(
                      borderRadius: BorderRadius.circular(180.0),
                      pixelSize: 20.0,
                    ),
                    child: Container(
                      height: 200.0,
                      width: 350.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
