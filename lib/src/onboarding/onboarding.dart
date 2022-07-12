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
import 'package:flutter/services.dart';
import 'comic.dart';
import 'comic_page.dart';
import 'onboarding_theme.dart';
import 'signature_page.dart';
import '../account/sign_in.dart';
import '../account/sign_up.dart';

/// The onboarding UI. This provides the root of the system for navigating
/// through the UI.
class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  Future<OnboardingComic>? _comicFuture;

  @override
  void initState() {
    super.initState();
    // This will eventually depend on the state because it will eventually load
    // assets.
    _comicFuture = OnboardingComic.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OnboardingComic>(builder: (BuildContext context, AsyncSnapshot<OnboardingComic> snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        final comic = snapshot.data;
        if (comic != null) {
          // Build the actual comic, we have the data we need
          return _buildComic(context, comic);
        } else {
          // Build an error page
          return const Center(child: Text("Unable to load comic data."));
        }
      } else {
        return const Center(child: Text("Loading data use agreement..."));
      }
    },
    future: _comicFuture);
  }

  Widget _buildComic(BuildContext context, OnboardingComic comic) {
    // Use the onboarding theme and then embed a navigator for the onboarding navigation
    return Theme(
      data: createOnboardingTheme(),
      // FIXME: Arrow directions should depend on language direction
      child: Shortcuts(shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.arrowLeft): const PreviousPageIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowRight): const NextPageIntent()
        },
        child: Actions(actions: {
            PreviousPageIntent: _PreviousPageAction(),
            NextPageIntent: _NextPageAction(comic.pages.length)
          },
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
                  // For comic pages, we want to build a special transition.
                  return PageRouteBuilder(
                    pageBuilder: (BuildContext context, Animation<double> _, Animation<double> __) => ComicPage.fromPage(comic.pages[page]),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return ComicPageFlipTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        child: child
                      );
                    },
                    settings: settings
                  );
                case "signature":
                  builder = (BuildContext context) => const SignaturePage();
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
              // Everything else uses the platform default
              return MaterialPageRoute<void>(builder: builder, settings: settings);
            },

          )
        )
      )
    );
  }
}

/// Intent for moving to the previous page - this will always pop the current
/// page!
class PreviousPageIntent extends Intent {
  const PreviousPageIntent();
}

/// Intent for moving to the next page
class NextPageIntent extends Intent {
  const NextPageIntent();
}

class _PreviousPageAction extends ContextAction<PreviousPageIntent> {
  @override
  void invoke(PreviousPageIntent intent, [BuildContext? context]) {
    if (context != null) {
      Navigator.maybePop(context);
    }
  }
}

class _NextPageAction extends ContextAction<NextPageIntent> {
  _NextPageAction(this.lastPage);

  final int lastPage;

  @override
  void invoke(NextPageIntent intent, [BuildContext? context]) {
    if (context != null) {
      // Check to see where this is
      final route = ModalRoute.of<void>(context);
      if (route != null) {
        if (route.settings.name == "page") {
          // Grab the arguments. Null is page 0.
          int page = 0;
          if (route.settings.arguments is int) {
            page = route.settings.arguments as int;
          }
          // Move to the next page
          page++;
          if (page >= lastPage) {
            // If moving to the next page would move past the end, move to the
            // signature page.
            Navigator.pushNamed<void>(context, "signature");
          } else {
            // Otherwise, move to the next page
            Navigator.pushNamed<void>(context, "page", arguments: page);
          }
        }
      }
    }
  }
}