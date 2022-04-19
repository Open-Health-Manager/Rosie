import 'package:flutter/material.dart';

const Color darkGrey = Color.fromARGB(255, 0x28, 0x28, 0x28);

ThemeData createAccountTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    backgroundColor: darkGrey
  );
}

BoxDecoration createAccountBoxDecoration() {
  return BoxDecoration(
    color: darkGrey,
    border: Border.all(color: Colors.white, width: 2.0),
    borderRadius: BorderRadius.circular(30),
  );
}