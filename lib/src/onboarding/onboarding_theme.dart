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