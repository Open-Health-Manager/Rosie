import 'package:flutter/material.dart';

class OnboardingTheme {
  static const Color primary = Color.fromARGB(255, 66, 140, 227);
  static const Color onPrimary = Colors.white;
}

ThemeData createOnboardingTheme({brightness = Brightness.light}) {
  // Currently you are allowed to pass a brightness, and it will be happily ignored.
  return ThemeData(colorScheme:
    ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: OnboardingTheme.primary,
      primary: OnboardingTheme.primary,
      onPrimary: OnboardingTheme.onPrimary,
      background: Colors.white
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: OnboardingTheme.onPrimary,
      foregroundColor: OnboardingTheme.primary,
      elevation: 0.0
    ),
    scaffoldBackgroundColor: Colors.white
  );
}