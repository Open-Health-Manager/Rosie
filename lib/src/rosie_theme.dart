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
  static const Color primary = Color.fromARGB(255, 109, 211, 233);
  static const Color shadow = Color.fromARGB(255, 49, 181, 206);
  static const Color blush = Color.fromARGB(255, 242, 109, 178);
  static const Color buttonColor = Color.fromARGB(255, 103, 80, 164);
  static const Color onButtonColor = Colors.white;
  static const Color belowOptimal = Color.fromARGB(255, 60, 126, 205);
  static const Color optimal = Color.fromARGB(255, 97, 78, 222);
  static const Color concern = Color.fromARGB(255, 175, 54, 174);
  static const Color urgent = Color.fromARGB(255, 205, 25, 133);
  static const Color inactiveBelowOptimal = Color.fromARGB(255, 22, 46, 75);
  static const Color inactiveOptimal = Color.fromARGB(255, 32, 26, 74);
  static const Color inactiveConcern = Color.fromARGB(255, 84, 39, 85);
  static const Color inactiveUrgent = Color.fromARGB(255, 68, 8, 44);
  static const Color backgroundTop = Colors.white;
  static const Color backgroundBottom = Color.fromARGB(255, 0x42, 0x8C, 0xE3);
  static const Gradient backgroundGradient = LinearGradient(
    colors: [backgroundTop, backgroundBottom],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter
  );
  static const List<Color> urgencyPalette = [ belowOptimal, optimal, concern, urgent ];

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
    double? decorationThickness}
  ) {
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
      decorationThickness: decorationThickness
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
    double? decorationThickness}
  ) {
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
      decorationThickness: decorationThickness
    );
  }
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