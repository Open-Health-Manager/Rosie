import 'package:flutter/material.dart';

class RosieTheme {
  static const Color primary = Color.fromARGB(255, 109, 211, 233);
  static const Color shadow = Color.fromARGB(255, 49, 181, 206);
  static const Color blush = Color.fromARGB(255, 242, 109, 178);
}

ColorScheme createRosieColorScheme({required Brightness brightness}) {
  return ColorScheme.fromSeed(seedColor: RosieTheme.primary, brightness: brightness);
}

ThemeData createRosieTheme({brightness = Brightness.light}) {
  return ThemeData(
    colorScheme: createRosieColorScheme(brightness: brightness)
  );
}

BoxDecoration createRosieScreenBoxDecoration() {
  return const BoxDecoration(gradient:
    LinearGradient(
      colors: [Colors.white, Color.fromARGB(255, 0x42, 0x8C, 0xE3)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter
    )
  );
}