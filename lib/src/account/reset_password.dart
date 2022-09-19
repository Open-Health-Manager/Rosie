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

// The UI for resetting your password

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'account_screen.dart';
import 'account_theme.dart';
import '../open_health_manager/open_health_manager.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  String? email;
  String? password;

  @override
  Widget build(BuildContext context) {
    return AccountScreenForm(
      title: "Retrieve Account",
      formBuilder: (BuildContext context) {
        return AutofillGroup(
          child: Column(
            children: [
              const Text(
                  "Enter your email to get an email with password reset instructions."),
              const SizedBox(height: 15.0),
              TextFormField(
                autocorrect: false,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Email Address",
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required";
                  }
                  return null;
                },
                onChanged: (value) {
                  email = value;
                },
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
              ),
            ],
          ),
        );
      },
      submitLabel: "Recover Account",
      onSubmit: () async {
        if (email != null) {
          if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email!)) {
            return "The email entered is not a valid email address. Please try again.";
          }
          await context.read<OpenHealthManager>().requestPasswordReset(email!);
          if (!mounted) return null;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PasswordResetSent()),
          );
          return null;
        } else {
          return "Email is required";
        }
      },
      afterFormBuilder: (BuildContext context) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFEF2F5),
          ),
          child: const Text(
            "Back",
            style: TextStyle(color: Color(0xFF1F201D)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

/// This screen is shown after the password request email has been successfully sent.
class PasswordResetSent extends StatelessWidget {
  const PasswordResetSent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AccountScreen(
      builder: (context) {
        return Column(
          children: <Widget>[
            const Text(
              'Retrieve Account',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AccountThemePalette.textColor,
              ),
            ),
            const SizedBox(height: 30.0),
            const Text('Recovery email sent!'),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {
                // Attempt to open the email app
              },
              child: const Text('Open Email'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEF2F5),
              ),
              child: const Text(
                "Back",
                style: TextStyle(color: Color(0xFF1F201D)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
