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

/// Rosie palette. There are two basic palettes: one for dark mode, one for
/// light mode.
class RosiePalette {
  /// Brightness mode for this palette: light or dark
  final Brightness brightness;

  /// Accent color (Rosie color)
  final Color accent;

  /// Blush (not used anywhere?)
  final Color blush;

  /// Background color for elevated buttons
  final Color buttonBackground;

  /// Foreground color for elevated buttons (text/icon)
  final Color buttonForeground;

  /// Background color for secondary elevated button/outlined buttons
  final Color secondaryButtonBackground;
  final Color belowOptimal;
  final Color optimal;
  final Color concern;
  final Color urgent;
  final Color inactiveBelowOptimal;
  final Color inactiveOptimal;
  final Color inactiveConcern;
  final Color inactiveUrgent;

  @Deprecated(
      "refers to a gradient that is no longer used, use backgroundColor")
  final Color backgroundTop = Colors.white;
  @Deprecated(
      "refers to a gradient this is no longer used, use backgroundColor")
  final Color backgroundBottom = const Color(0xFF428CE3);

  final Color inputBackground = const Color(0xFFE7E0EC);
  final Color dialogBackground = const Color(0xFFE1E3E9);
  final Color error;

  final Color backgroundColor;
  final Color fontColor;
  final Color speechBalloonBackground;
  final Color speechBalloonShadow;

  const RosiePalette({
    required this.brightness,
    required this.accent,
    required this.blush,
    required this.buttonBackground,
    required this.buttonForeground,
    required this.secondaryButtonBackground,
    required this.belowOptimal,
    required this.optimal,
    required this.concern,
    required this.urgent,
    required this.inactiveBelowOptimal,
    required this.inactiveOptimal,
    required this.inactiveConcern,
    required this.inactiveUrgent,
    required this.error,
    required this.backgroundColor,
    required this.fontColor,
    required this.speechBalloonBackground,
    required this.speechBalloonShadow,
  });

  /// Retrieve an urgency color by index.
  ///
  /// 0 = belowOptimal, 1 = optimal, 2 = concern, 3 = urgent
  Color urgencyColor(int index, [bool active = true]) {
    if (index <= 0) {
      return active ? belowOptimal : inactiveBelowOptimal;
    } else if (index == 1) {
      return active ? optimal : inactiveOptimal;
    } else if (index == 2) {
      return active ? concern : inactiveConcern;
    } else {
      return active ? urgent : inactiveUrgent;
    }
  }

  RosiePalette copyWith({
    Brightness? brightness,
    Color? accent,
    Color? blush,
    Color? buttonBackground,
    Color? buttonForeground,
    Color? secondaryButtonBackground,
    Color? belowOptimal,
    Color? optimal,
    Color? concern,
    Color? urgent,
    Color? inactiveBelowOptimal,
    Color? inactiveOptimal,
    Color? inactiveConcern,
    Color? inactiveUrgent,
    Color? error,
    Color? backgroundColor,
    Color? fontColor,
    Color? speechBalloonBackground,
    Color? speechBalloonShadow,
  }) {
    return RosiePalette(
      brightness: brightness ?? this.brightness,
      accent: accent ?? this.accent,
      blush: blush ?? this.blush,
      buttonBackground: buttonBackground ?? this.buttonBackground,
      buttonForeground: buttonForeground ?? this.buttonForeground,
      secondaryButtonBackground:
          secondaryButtonBackground ?? this.secondaryButtonBackground,
      belowOptimal: belowOptimal ?? this.belowOptimal,
      optimal: optimal ?? this.optimal,
      concern: concern ?? this.concern,
      urgent: urgent ?? this.urgent,
      inactiveBelowOptimal: inactiveBelowOptimal ?? this.inactiveBelowOptimal,
      inactiveOptimal: inactiveOptimal ?? this.inactiveOptimal,
      inactiveConcern: inactiveConcern ?? this.inactiveConcern,
      inactiveUrgent: inactiveUrgent ?? this.inactiveUrgent,
      error: error ?? this.error,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontColor: fontColor ?? this.fontColor,
      speechBalloonBackground:
          speechBalloonBackground ?? this.speechBalloonBackground,
      speechBalloonShadow:
          speechBalloonShadow ?? this.speechBalloonShadow,
    );
  }

  RosiePalette lerp(RosiePalette other, double t) {
    return RosiePalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      blush: Color.lerp(blush, other.blush, t) ?? blush,
      buttonBackground:
          Color.lerp(buttonBackground, other.buttonBackground, t) ??
              buttonBackground,
      buttonForeground:
          Color.lerp(buttonForeground, other.buttonForeground, t) ??
              buttonForeground,
      secondaryButtonBackground: Color.lerp(
              secondaryButtonBackground, other.secondaryButtonBackground, t) ??
          secondaryButtonBackground,
      belowOptimal:
          Color.lerp(belowOptimal, other.belowOptimal, t) ?? belowOptimal,
      optimal: Color.lerp(optimal, other.optimal, t) ?? optimal,
      concern: Color.lerp(concern, other.concern, t) ?? concern,
      urgent: Color.lerp(urgent, other.urgent, t) ?? urgent,
      inactiveBelowOptimal:
          Color.lerp(inactiveBelowOptimal, other.inactiveBelowOptimal, t) ??
              inactiveBelowOptimal,
      inactiveOptimal: Color.lerp(inactiveOptimal, other.inactiveOptimal, t) ??
          inactiveOptimal,
      inactiveConcern: Color.lerp(inactiveConcern, other.inactiveConcern, t) ??
          inactiveConcern,
      inactiveUrgent:
          Color.lerp(inactiveUrgent, other.inactiveUrgent, t) ?? inactiveUrgent,
      error: Color.lerp(error, other.error, t) ?? error,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t) ??
          backgroundColor,
      fontColor: Color.lerp(fontColor, other.fontColor, t) ?? fontColor,
      speechBalloonBackground: Color.lerp(
              speechBalloonBackground, other.speechBalloonBackground, t) ??
          speechBalloonBackground,
      speechBalloonShadow: Color.lerp(
              speechBalloonShadow, other.speechBalloonShadow, t) ??
          speechBalloonShadow,
    );
  }

  static const light = RosiePalette(
    brightness: Brightness.light,
    accent: Color.fromARGB(255, 250, 153, 175),
    blush: Color.fromARGB(255, 242, 109, 178),
    buttonBackground: Color.fromARGB(255, 250, 153, 175),
    buttonForeground: Colors.black,
    secondaryButtonBackground: Color(0xFFFEF2F5),
    belowOptimal: Color.fromARGB(255, 234, 202, 210),
    optimal: Colors.white,
    concern: Color.fromARGB(255, 234, 202, 210),
    urgent: Color.fromARGB(255, 248, 119, 151),
    inactiveBelowOptimal: Color.fromARGB(255, 234, 202, 210),
    inactiveOptimal: Colors.white,
    inactiveConcern: Color.fromARGB(255, 234, 202, 210),
    inactiveUrgent: Color.fromARGB(255, 248, 119, 151),
    error: Color(0xFF880000),
    backgroundColor: Colors.white,
    fontColor: Colors.black,
    speechBalloonBackground: Color.fromARGB(255, 254, 242, 245),
    speechBalloonShadow: Color.fromARGB(64, 0, 0, 0),
  );

  static const dark = RosiePalette(
    brightness: Brightness.dark,
    accent: Color.fromARGB(255, 150, 92, 105),
    blush: Color.fromARGB(255, 124, 55, 90),
    buttonBackground: Color.fromARGB(255, 150, 92, 105),
    buttonForeground: Colors.white,
    secondaryButtonBackground: Color(0xFFFEF2F5),
    belowOptimal: Color.fromARGB(255, 234, 202, 210),
    optimal: Colors.white,
    concern: Color.fromARGB(255, 234, 202, 210),
    urgent: Color.fromARGB(255, 248, 119, 151),
    inactiveBelowOptimal: Color.fromARGB(255, 234, 202, 210),
    inactiveOptimal: Colors.white,
    inactiveConcern: Color.fromARGB(255, 234, 202, 210),
    inactiveUrgent: Color.fromARGB(255, 248, 119, 151),
    error: Color(0xFF880000),
    backgroundColor: Colors.black,
    fontColor: Colors.white,
    speechBalloonBackground: Color.fromARGB(255, 13, 0, 2),
    speechBalloonShadow: Color.fromARGB(64, 0, 0, 0),
  );

  static RosiePalette forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}

// Rosie theme data.
class RosieTheme {
  /// Generates the comic font for the Rosie theme.
  @Deprecated(
      "deprecated when used to generate the comic theme outside of Rosie, still used to generate for the theme")
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
  @Deprecated(
      "deprecated when used to generate the comic theme outside of Rosie, still used to generate for the theme")
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
    seedColor: RosiePalette.forBrightness(brightness).accent,
    brightness: brightness,
  );
}

class RosieThemeExtension extends ThemeExtension<RosieThemeExtension> {
  const RosieThemeExtension({
    required this.palette,
    required this.comicTextStyle,
    required this.secondaryButtonTheme,
  });

  final RosiePalette palette;
  final TextStyle comicTextStyle;
  final ElevatedButtonThemeData secondaryButtonTheme;

  @override
  ThemeExtension<RosieThemeExtension> copyWith({
    RosiePalette? palette,
    TextStyle? comicTextStyle,
    ElevatedButtonThemeData? secondaryButtonTheme,
  }) {
    return RosieThemeExtension(
      palette: palette ?? this.palette,
      comicTextStyle: comicTextStyle ?? this.comicTextStyle,
      secondaryButtonTheme: secondaryButtonTheme ?? this.secondaryButtonTheme,
    );
  }

  @override
  ThemeExtension<RosieThemeExtension> lerp(
      ThemeExtension<RosieThemeExtension>? other, double t) {
    if (other is! RosieThemeExtension) {
      return this;
    }
    // This uses copyWith because lerp can, conceptually, return null
    return copyWith(
      palette: palette.lerp(other.palette, t),
      comicTextStyle: TextStyle.lerp(comicTextStyle, other.comicTextStyle, t),
      secondaryButtonTheme: ElevatedButtonThemeData.lerp(
          secondaryButtonTheme, other.secondaryButtonTheme, t),
    );
  }
}

ThemeData createRosieTheme({brightness = Brightness.light}) {
  final palette = RosiePalette.forBrightness(brightness);
  return ThemeData(
    colorScheme: createRosieColorScheme(brightness: brightness),
    extensions: <ThemeExtension<dynamic>>[
      RosieThemeExtension(
        palette: palette,
        comicTextStyle: RosieTheme.comicFont(color: palette.fontColor),
        secondaryButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                palette.secondaryButtonBackground),
            foregroundColor:
                MaterialStateProperty.all<Color>(palette.buttonForeground),
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: const BorderSide(color: Colors.black, width: 0.5),
              ),
            ),
          ),
        ),
      ),
    ],
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(palette.buttonBackground),
        foregroundColor:
            MaterialStateProperty.all<Color>(palette.buttonForeground),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: const BorderSide(color: Colors.black, width: 0.5),
          ),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        //backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        backgroundColor: MaterialStateProperty.all<Color>(
          const Color.fromARGB(255, 254, 242, 245),
        ),
        foregroundColor:
            // MaterialStateProperty.all<Color>(RosieTheme.buttonColor),
            MaterialStateProperty.all<Color>(Colors.black),
        //side: MaterialStateProperty.all<BorderSide>(
        //const BorderSide(color: Color.fromARGB(255, 121, 116, 126))),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          //const StadiumBorder()
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: const BorderSide(color: Colors.black, width: 0.5),
          ),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 231, 224, 236),
      selectedItemColor: Color.fromARGB(255, 29, 25, 43),
      unselectedItemColor: Color.fromARGB(255, 31, 31, 31),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: palette.accent, width: 2),
      ),
      focusColor: palette.accent,
      hoverColor: const Color(0x141C1B1F),
      fillColor: palette.inputBackground,
      labelStyle: const TextStyle(color: Colors.black, fontSize: 14),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: palette.accent,
      selectionColor: palette.accent.withAlpha(128),
      selectionHandleColor: palette.accent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
  );
}

@Deprecated('no longer used as the background is no longer a gradient')
BoxDecoration createRosieScreenBoxDecoration() {
  //return const BoxDecoration(gradient: RosieTheme.backgroundGradient);
  return const BoxDecoration(color: Colors.white);
}
