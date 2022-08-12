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

class AccountThemePalette {
  static const Color darkGrey = Color.fromARGB(255, 0x28, 0x28, 0x28);
  static const Color background = Color.fromARGB(255, 66, 140, 227);
  static const Color textColor = Colors.white;
}

ThemeData createAccountTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AccountThemePalette.background,
      elevation: 0.0,
    ),
    backgroundColor: AccountThemePalette.darkGrey,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      fillColor: Colors.white,
      filled: true,
      hintStyle: TextStyle(color: Colors.black54),
      prefixIconColor: Colors.black,
    ),
    textTheme: Typography.material2018()
        .white
        .copyWith(subtitle1: const TextStyle(color: Colors.black)),
    toggleableActiveColor: AccountThemePalette.background,
  );
}

BoxDecoration createAccountBoxDecoration() {
  return BoxDecoration(
    color: AccountThemePalette.darkGrey,
    border: Border.all(color: Colors.white, width: 2.0),
    borderRadius: BorderRadius.circular(30),
  );
}
