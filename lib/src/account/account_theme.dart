import 'package:flutter/material.dart';

class AccountThemePalette {
  static const Color darkGrey = Color.fromARGB(255, 0x28, 0x28, 0x28);
  static const Color background = Color.fromARGB(255, 66, 140, 227);
  static const Color textColor = Colors.white;
}

ThemeData createAccountTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    backgroundColor: AccountThemePalette.darkGrey,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
      fillColor: Colors.white,
      filled: true,
      hintStyle: TextStyle(color: Colors.black54),
      prefixIconColor: Colors.black
    ),
    textTheme: Typography.material2018().white.copyWith(subtitle1: const TextStyle(color: Colors.black))
  );
}

BoxDecoration createAccountBoxDecoration() {
  return BoxDecoration(
    color: AccountThemePalette.darkGrey,
    border: Border.all(color: Colors.white, width: 2.0),
    borderRadius: BorderRadius.circular(30),
  );
}