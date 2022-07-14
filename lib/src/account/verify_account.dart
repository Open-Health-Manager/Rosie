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
import 'package:url_launcher/url_launcher.dart';
import 'account_screen.dart';

class VerifyAccountScreen extends StatelessWidget {
  const VerifyAccountScreen({Key? key, required this.email}) : super(key: key);

  final String email;

  TextSpan _createDescription() {
    return TextSpan(children: [
      const TextSpan(text: "I've sent an email to "),
      TextSpan(text: email, style: const TextStyle(fontWeight: FontWeight.bold)),
      const TextSpan(text: ".")
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AccountScreen(
      builder: (context) => Column(
        children: <Widget>[
          Text("Verify your Email", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 15),
          Text.rich(_createDescription()),
          const SizedBox(height: 15),
          OutlinedButton(child:
            const Text("Open Mail"),
            onPressed: () {
              // Attempt to launch a mailto: link
              launchUrl(Uri.parse('mailto:'));
            }
          ),
          const Text("You need to verify your email to continue. If you don't see it, check your spam folder, or get another verification email sent."),
          const SizedBox(height: 15),
          OutlinedButton(
            child: const Text("Resend Verification Email"),
            onPressed: () {
              // Does nothing for now
            }
          )
        ],
      )
    );
  }
}
