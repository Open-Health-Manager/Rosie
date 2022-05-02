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

// This provides the UI for the data agreement.

import 'package:flutter/material.dart';
import 'onboarding_theme.dart';
import 'comic_page.dart';
import '../account/sign_in.dart';
import '../account/sign_up.dart';

// The onboarding UI.
class Onboarding extends StatelessWidget {
  const Onboarding({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the onboarding theme and then embed a navigator for the onboarding navigation
    return Theme(
      data: createOnboardingTheme(),
      child: Navigator(
        initialRoute: "page",
        onGenerateRoute: (settings) {
          WidgetBuilder builder;
          // Grab just the end of the path
          switch (settings.name) {
            case "page":
              int page = 0;
              if (settings.arguments == null) {
                // No args = page 0
              } else if (settings.arguments is int) {
                page = settings.arguments as int;
              } else {
                throw Exception("Invalid page argument ${settings.arguments}");
              }
              builder = (BuildContext context) => createPage(page);
              break;
            case "signUp":
              builder = (BuildContext context) => const SignUp();
              break;
            case "signIn":
              builder = (BuildContext context) => const SignIn();
              break;
            default:
              throw Exception("Unknown route ${settings.name}");
          }
          return MaterialPageRoute<void>(builder: builder, settings: settings);
        },
      )
    );
  }
}