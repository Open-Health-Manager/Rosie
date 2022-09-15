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

// A single page in the data agreement comic.

import 'package:flutter/material.dart';
import 'comic.dart';
import 'onboarding.dart';
import '../rosie_theme.dart';

/// A single comic page.
class ComicPage extends StatelessWidget {
  const ComicPage({
    Key? key,
    required this.text,
    required this.comicPage,
    required this.nextLabel,
    this.showLoginLink = false,
  }) : super(key: key);

  final String text;
  final String comicPage;
  final String nextLabel;
  final bool showLoginLink;

  @override
  Widget build(BuildContext context) {
    // This children change depending on page number, so build them first
    final List<Widget> children = [
      Container(
        margin: const EdgeInsets.all(15.0),
        padding: const EdgeInsets.all(25.0),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: Color(0xFFFEF2F5),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 24.0, fontFamily: 'ComicNeue'),
        ),
      ),
      Expanded(child: Image(image: AssetImage(comicPage), fit: BoxFit.contain)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: ElevatedButton(
          onPressed: () {
            // When pressed, move on to the next page, if possible
            Actions.invoke(context, const NextPageIntent());
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                nextLabel,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8, height: 42),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    ];
    if (showLoginLink) {
      // Add a way to log in
      children.insert(
        2,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ElevatedButton(
            style: Theme.of(context)
                .extension<RosieThemeExtension>()
                ?.secondaryButtonTheme
                .style,
            onPressed: () {
              Navigator.pushNamed(context, "signIn");
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text(
                  "Skip to Sign In",
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(width: 8, height: 42),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(children: children),
        ),
      ),
    );
  }

  factory ComicPage.fromPage(OnboardingComicPage page) {
    return ComicPage(
      text: page.altText,
      comicPage:
          "assets/data_use_agreement/rosieOnboarding-${page.pageNumber}.png",
      nextLabel: page.nextLabel,
      showLoginLink: page.firstPage,
    );
  }
}
