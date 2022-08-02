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
// import 'package:flutter/cupertino.dart';

class OnboardingTheme {
  static const Color primary = Color(0xFFFA99AF);
  static const Color onPrimary = Color(0xFF1F201D);
}

ThemeData createOnboardingTheme({brightness = Brightness.light}) {
  // Currently you are allowed to pass a brightness, and it will be happily ignored.
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: OnboardingTheme.primary,
        primary: OnboardingTheme.primary,
        onPrimary: OnboardingTheme.onPrimary,
        background: Colors.white),
    appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: OnboardingTheme.primary,
        elevation: 0.0),
    scaffoldBackgroundColor: Colors.white,
  );
}

/// Page flip transition.
class ComicPageFlipTransition extends StatelessWidget {
  const ComicPageFlipTransition(
      {Key? key,
      required this.animation,
      required this.secondaryAnimation,
      this.child})
      : super(key: key);

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    // Use easeInOutSine for the curve
    final curveTween = CurveTween(curve: Curves.easeInOutSine);
    final slideIn =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(curveTween);
    final slideOut =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-1.0, 0.0))
            .chain(curveTween);
    return SlideTransition(
        position: slideIn.animate(animation),
        child: SlideTransition(
            position: slideOut.animate(secondaryAnimation), child: child));
  }
}
