import 'package:flutter/material.dart';

class RosieTheme {
  static const Color primary = Color.fromARGB(255, 109, 211, 233);
  static const Color shadow = Color.fromARGB(255, 49, 181, 206);
  static const Color blush = Color.fromARGB(255, 242, 109, 178);
  static const Color buttonColor = Color.fromARGB(255, 103, 80, 164);
  static const Color onButtonColor = Colors.white;
  static const Color optimal = Color.fromARGB(255, 97, 78, 222);
  static const Color concern = Color.fromARGB(255, 175, 54, 174);
  static const Color urgent = Color.fromARGB(255, 205, 25, 133);
  static const Color backgroundTop = Colors.white;
  static const Color backgroundBottom = Color.fromARGB(255, 0x42, 0x8C, 0xE3);
  static const Gradient backgroundGradient = LinearGradient(
    colors: [backgroundTop, backgroundBottom],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter
  );
  static const List<Color> urgencyPalette = [ optimal, concern, urgent ];
}

ColorScheme createRosieColorScheme({required Brightness brightness}) {
  return ColorScheme.fromSeed(seedColor: RosieTheme.backgroundBottom, brightness: brightness);
}

ThemeData createRosieTheme({brightness = Brightness.light}) {
  return ThemeData(
    colorScheme: createRosieColorScheme(brightness: brightness),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(RosieTheme.buttonColor),
        foregroundColor: MaterialStateProperty.all<Color>(RosieTheme.onButtonColor),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          const StadiumBorder()
        )
      )
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 231, 224, 236),
      selectedItemColor: Color.fromARGB(255, 29, 25, 43),
      unselectedItemColor: Color.fromARGB(255, 31, 31, 31)
    )
  );
}

BoxDecoration createRosieScreenBoxDecoration() {
  return const BoxDecoration(gradient: RosieTheme.backgroundGradient);
}