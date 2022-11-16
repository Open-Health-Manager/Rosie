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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// Interactive color (currently, links)
  final Color interactive;

  /// Color for below optimal values
  final Color belowOptimal;
  /// Color for optimal values
  final Color optimal;
  /// Color for values that are high and of concern
  final Color concern;
  /// Color for values that are high and signify an urgent problem
  final Color urgent;
  /// Color for below optimal values when not active
  final Color inactiveBelowOptimal;
  /// Color for optimal values when not active
  final Color inactiveOptimal;
  /// Color for values of concern when not active
  final Color inactiveConcern;
  /// Color for urgent values when not active
  final Color inactiveUrgent;

  /// Color for border around chart slices (colored via one of [urgencyColor]
  /// colors).
  final Color chartBorder;

  @Deprecated("use the theme data")
  final Color inputBackground = const Color(0xFFE7E0EC);

  final Color speechBalloonBackground;
  final Color speechBalloonShadow;

  const RosiePalette({
    required this.brightness,
    required this.accent,
    required this.blush,
    required this.interactive,
    required this.belowOptimal,
    required this.optimal,
    required this.concern,
    required this.urgent,
    required this.inactiveBelowOptimal,
    required this.inactiveOptimal,
    required this.inactiveConcern,
    required this.inactiveUrgent,
    required this.chartBorder,
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
    Color? interactive,
    Color? belowOptimal,
    Color? optimal,
    Color? concern,
    Color? urgent,
    Color? inactiveBelowOptimal,
    Color? inactiveOptimal,
    Color? inactiveConcern,
    Color? inactiveUrgent,
    Color? chartBorder,
    Color? speechBalloonBackground,
    Color? speechBalloonShadow,
  }) {
    return RosiePalette(
      brightness: brightness ?? this.brightness,
      accent: accent ?? this.accent,
      blush: blush ?? this.blush,
      interactive: interactive ?? this.interactive,
      belowOptimal: belowOptimal ?? this.belowOptimal,
      optimal: optimal ?? this.optimal,
      concern: concern ?? this.concern,
      urgent: urgent ?? this.urgent,
      inactiveBelowOptimal: inactiveBelowOptimal ?? this.inactiveBelowOptimal,
      inactiveOptimal: inactiveOptimal ?? this.inactiveOptimal,
      inactiveConcern: inactiveConcern ?? this.inactiveConcern,
      inactiveUrgent: inactiveUrgent ?? this.inactiveUrgent,
      chartBorder: chartBorder ?? this.chartBorder,
      speechBalloonBackground:
          speechBalloonBackground ?? this.speechBalloonBackground,
      speechBalloonShadow: speechBalloonShadow ?? this.speechBalloonShadow,
    );
  }

  RosiePalette lerp(RosiePalette other, double t) {
    return RosiePalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      blush: Color.lerp(blush, other.blush, t) ?? blush,
      interactive: Color.lerp(interactive, other.interactive, t) ?? interactive,
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
      chartBorder:
          Color.lerp(chartBorder, other.chartBorder, t) ?? chartBorder,
      speechBalloonBackground: Color.lerp(
              speechBalloonBackground, other.speechBalloonBackground, t) ??
          speechBalloonBackground,
      speechBalloonShadow:
          Color.lerp(speechBalloonShadow, other.speechBalloonShadow, t) ??
              speechBalloonShadow,
    );
  }

  static const light = RosiePalette(
    brightness: Brightness.light,
    accent: Color.fromARGB(255, 250, 153, 175),
    blush: Color.fromARGB(255, 242, 109, 178),
    interactive: Color.fromARGB(255, 81, 84, 141),
    belowOptimal: Color.fromARGB(255, 234, 202, 210),
    optimal: Colors.white,
    concern: Color.fromARGB(255, 234, 202, 210),
    urgent: Color.fromARGB(255, 248, 119, 151),
    chartBorder: Colors.white,
    inactiveBelowOptimal: Color.fromARGB(255, 234, 202, 210),
    inactiveOptimal: Colors.white,
    inactiveConcern: Color.fromARGB(255, 234, 202, 210),
    inactiveUrgent: Color.fromARGB(255, 248, 119, 151),
    speechBalloonBackground: Color.fromARGB(255, 254, 242, 245),
    speechBalloonShadow: Color.fromARGB(64, 0, 0, 0),
  );

  static const dark = RosiePalette(
    brightness: Brightness.dark,
    accent: Color.fromARGB(255, 150, 92, 105),
    blush: Color.fromARGB(255, 124, 55, 90),
    interactive: Color(0xFFB5B5F6),
    belowOptimal: Color.fromARGB(255, 234, 202, 210),
    optimal: Colors.white,
    concern: Color.fromARGB(255, 234, 202, 210),
    urgent: Color.fromARGB(255, 248, 119, 151),
    chartBorder: Colors.black,
    inactiveBelowOptimal: Color.fromARGB(255, 234, 202, 210),
    inactiveOptimal: Colors.white,
    inactiveConcern: Color.fromARGB(255, 234, 202, 210),
    inactiveUrgent: Color.fromARGB(255, 248, 119, 151),
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

ColorScheme _createRosieColorScheme(RosiePalette palette) {
  final light = palette.brightness == Brightness.light;
  return ColorScheme.fromSeed(
    seedColor: palette.accent,
    primary: palette.accent,
    onPrimary: light ? Colors.black : Colors.white,
    error: const Color.fromARGB(255, 170, 58, 13),
    background: light ? Colors.white : Colors.black,
    onBackground: light ? Colors.black : Colors.white,
    brightness: palette.brightness,
  );
}

class RosieThemeExtension extends ThemeExtension<RosieThemeExtension> {
  const RosieThemeExtension({
    required this.palette,
    required this.comicTextStyle,
    required this.chartTextStyle,
    required this.chartNumericStyle,
    required this.secondaryButtonTheme,
  });

  /// Additional Rosie colors that do not fit within the [ColorScheme].
  final RosiePalette palette;

  /// Text style for "comic" text, used when Rosie is speaking.
  final TextStyle comicTextStyle;

  /// Text style for chart labels.
  final TextStyle chartTextStyle;

  /// Text style for chart numeric labels.
  final TextStyle chartNumericStyle;

  /// Button style for "secondary" buttons.
  final ElevatedButtonThemeData secondaryButtonTheme;

  @override
  ThemeExtension<RosieThemeExtension> copyWith({
    RosiePalette? palette,
    TextStyle? comicTextStyle,
    TextStyle? chartTextStyle,
    TextStyle? chartNumericStyle,
    ElevatedButtonThemeData? secondaryButtonTheme,
  }) {
    return RosieThemeExtension(
      palette: palette ?? this.palette,
      comicTextStyle: comicTextStyle ?? this.comicTextStyle,
      chartTextStyle: chartTextStyle ?? this.chartTextStyle,
      chartNumericStyle: chartNumericStyle ?? this.chartNumericStyle,
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
      chartTextStyle: TextStyle.lerp(chartTextStyle, other.chartTextStyle, t),
      chartNumericStyle: TextStyle.lerp(chartNumericStyle, other.chartNumericStyle, t),
      secondaryButtonTheme: ElevatedButtonThemeData.lerp(
          secondaryButtonTheme, other.secondaryButtonTheme, t),
    );
  }
}

ThemeData createRosieTheme({
  brightness = Brightness.light,
  TargetPlatform? targetPlatform,
}) {
  final palette = RosiePalette.forBrightness(brightness);
  final colorScheme = _createRosieColorScheme(palette);
  final typography = Typography.material2021(
      platform: targetPlatform ?? defaultTargetPlatform);
  // This is more to make code readable than anything else, for picking colors
  final light = brightness == Brightness.light;
  final baseTextTheme =
      brightness == Brightness.light ? typography.black : typography.white;
  return ThemeData(
    colorScheme: colorScheme,
    extensions: <ThemeExtension<dynamic>>[
      RosieThemeExtension(
        palette: palette,
        comicTextStyle: GoogleFonts.comicNeue(color: colorScheme.onBackground),
        // FIXME: Chart is always light
        chartTextStyle: GoogleFonts.comicNeue(color: Colors.black, fontSize: 16.0,),
        chartNumericStyle: GoogleFonts.comicNeue(color: Colors.black, fontSize: 16.0,),
        secondaryButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                colorScheme.secondary),
            foregroundColor:
                MaterialStateProperty.all<Color>(colorScheme.onSecondary),
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
            MaterialStateProperty.all<Color>(colorScheme.primary),
        foregroundColor:
            MaterialStateProperty.all<Color>(colorScheme.onPrimary),
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
        backgroundColor: MaterialStateProperty.all<Color>(
          light
              ? const Color.fromARGB(255, 254, 242, 245)
              : const Color.fromARGB(255, 12, 0, 3),
        ),
        foregroundColor: MaterialStateProperty.all<Color>(colorScheme.onPrimary),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: const BorderSide(color: Colors.black, width: 0.5),
          ),
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: light
          ? const Color.fromARGB(255, 231, 224, 236)
          : const Color.fromARGB(255, 7, 0, 12),
      selectedItemColor: light
          ? const Color.fromARGB(255, 29, 25, 43)
          : const Color.fromARGB(255, 241, 237, 255),
      unselectedItemColor: light
          ? const Color.fromARGB(255, 31, 31, 31)
          : const Color.fromARGB(255, 224, 224, 224),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: palette.accent, width: 2),
      ),
      focusColor: palette.accent,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: palette.accent,
      selectionColor: palette.accent.withAlpha(128),
      selectionHandleColor: palette.accent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: light ? Colors.white : const Color(0xFF565051),
      foregroundColor: light ? Colors.black : const Color(0xFFD0D0D0),
      elevation: 0,
      systemOverlayStyle:
          light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
    ),
    textTheme: baseTextTheme.copyWith(
      headlineLarge: GoogleFonts.ubuntu(textStyle: baseTextTheme.headlineLarge),
      headlineMedium:
          GoogleFonts.ubuntu(textStyle: baseTextTheme.headlineMedium),
      headlineSmall: GoogleFonts.ubuntu(textStyle: baseTextTheme.headlineSmall),
      titleLarge: GoogleFonts.ubuntu(textStyle: baseTextTheme.titleLarge),
      titleMedium: GoogleFonts.ubuntu(textStyle: baseTextTheme.titleMedium),
      titleSmall: GoogleFonts.ubuntu(textStyle: baseTextTheme.titleSmall),
    ),
  );
}

@Deprecated('no longer used as the background is no longer a gradient')
BoxDecoration createRosieScreenBoxDecoration() {
  //return const BoxDecoration(gradient: RosieTheme.backgroundGradient);
  return const BoxDecoration(color: Colors.white);
}
