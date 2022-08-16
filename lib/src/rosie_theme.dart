// Copyright 2022 The MITRE Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class RosieTheme {
  static const Color accent = Color(0xFF6750A4);
  static const Color primary = Color.fromARGB(255, 109, 211, 233);
  static const Color shadow = Color.fromARGB(255, 49, 181, 206);
  static const Color blush = Color.fromARGB(255, 242, 109, 178);
  static const Color buttonColor = accent;
  static const Color onButtonColor = Colors.white;
  /* static const Color belowOptimal = Color.fromARGB(255, 60, 126, 205);
  static const Color optimal = Color.fromARGB(255, 97, 78, 222);
  static const Color concern = Color.fromARGB(255, 175, 54, 174);
  static const Color urgent = Color.fromARGB(255, 205, 25, 133);
  static const Color inactiveBelowOptimal = Color.fromARGB(255, 22, 46, 75);
  static const Color inactiveOptimal = Color.fromARGB(255, 32, 26, 74);
  static const Color inactiveConcern = Color.fromARGB(255, 84, 39, 85);
  static const Color inactiveUrgent = Color.fromARGB(255, 68, 8, 44); */
  static const Color belowOptimal = Color.fromARGB(255, 234, 202, 210);
  static const Color optimal = Color.fromARGB(255, 238, 173, 190);
  static const Color concern = Color.fromARGB(255, 243, 146, 170);
  static const Color urgent = Color.fromARGB(255, 248, 119, 151);
  static const Color inactiveBelowOptimal = Color.fromARGB(255, 234, 202, 210);
  static const Color inactiveOptimal = Color.fromARGB(255, 238, 173, 190);
  static const Color inactiveConcern = Color.fromARGB(255, 243, 146, 170);
  static const Color inactiveUrgent = Color.fromARGB(255, 248, 119, 151);

  static const Color backgroundTop = Colors.white;
  static const Color backgroundBottom = Color(0xFF428CE3);
  static const Color inputBackground = Color(0xFFE7E0EC);
  static const Color dialogBackground = Color(0xFFE1E3E9);
  static const Color error = Color(0xFF880000);

  static const Color backgroundColor = Colors.white;
  static const Color fontColor = Colors.black;

  static const Gradient backgroundGradient = LinearGradient(
    colors: [backgroundTop, backgroundBottom],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const List<Color> urgencyPalette = [
    belowOptimal,
    optimal,
    concern,
    urgent,
  ];

  // Generates the comic font for the Rosie theme.
  static TextStyle comicFont({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    return GoogleFonts.comicNeue(
      textStyle: textStyle,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height ?? 1.15,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  }

  // Generates the general font for the Rosie theme.
  static TextStyle font({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    return GoogleFonts.ubuntu(
      textStyle: textStyle,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  }
}

ColorScheme createRosieColorScheme({required Brightness brightness}) {
  return ColorScheme.fromSeed(
      seedColor: RosieTheme.backgroundBottom, brightness: brightness);
}

ThemeData createRosieTheme({brightness = Brightness.light}) {
  // Intentionally ignore the given brightness for now and ALWAYS do light mode
  return ThemeData(
    colorScheme: createRosieColorScheme(brightness: Brightness.light),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(RosieTheme.buttonColor),
        foregroundColor:
            MaterialStateProperty.all<Color>(RosieTheme.onButtonColor),
        shape: MaterialStateProperty.all<OutlinedBorder>(const StadiumBorder()),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
      foregroundColor: MaterialStateProperty.all<Color>(RosieTheme.buttonColor),
      side: MaterialStateProperty.all<BorderSide>(
          const BorderSide(color: Color.fromARGB(255, 121, 116, 126))),
      shape: MaterialStateProperty.all<OutlinedBorder>(const StadiumBorder()),
    )),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 231, 224, 236),
      selectedItemColor: Color.fromARGB(255, 29, 25, 43),
      unselectedItemColor: Color.fromARGB(255, 31, 31, 31),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: RosieTheme.accent, width: 2)),
      focusColor: RosieTheme.accent,
      hoverColor: Color(0x141C1B1F),
      fillColor: RosieTheme.inputBackground,
      labelStyle: TextStyle(color: RosieTheme.accent),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: RosieTheme.accent,
      selectionColor: RosieTheme.accent.withAlpha(128),
      selectionHandleColor: RosieTheme.accent,
    ),
  );
}

BoxDecoration createRosieScreenBoxDecoration() {
  //return const BoxDecoration(gradient: RosieTheme.backgroundGradient);
  return const BoxDecoration(color: RosieTheme.backgroundColor);
}
