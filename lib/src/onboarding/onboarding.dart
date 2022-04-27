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