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

// This provides the sign in process

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'account_screen.dart';
import 'reset_password.dart';
import 'sign_up.dart';
import '../open_health_manager/open_health_manager.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String? email;
  String? password;

  // new piece of code - create button bar, may need to add the underscore and call it from the build function as done in the blood_pressure_help
  Widget _createButtonBar(BuildContext context) {
    // Go back button is always the same
    final goBack = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Color(0xFFFEF2F5),
      ),
      child: const Text(
        "Back",
        style: TextStyle(color: Color(0xFF1F201D)),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    return Align(alignment: AlignmentDirectional.center, child: goBack);
  }

  @override
  Widget build(BuildContext context) {
    return AccountScreenForm(
      title: "Sign In",
      formBuilder: (BuildContext context) {
        return AutofillGroup(
            child: Column(
          children: [
            TextFormField(
              autocorrect: false,
              autofocus: true,
              decoration: const InputDecoration(
                  hintText: "Email Address", prefixIcon: Icon(Icons.email)),
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
            const SizedBox(height: 15.0),
            TextFormField(
              autocorrect: false,
              decoration: const InputDecoration(
                  hintText: "Password", prefixIcon: Icon(Icons.lock)),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Password cannot be blank";
                }
                return null;
              },
              onChanged: (value) {
                password = value;
              },
              onEditingComplete: () {
                Actions.invoke(context, const SubmitIntent());
              },
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
            ),
          ],
        ));
      },
      submitLabel: "Confirm",
      onSubmit: () async {
        if (email != null && password != null) {
          final auth =
              await context.read<OpenHealthManager>().signIn(email!, password!);
          return auth == null
              ? "Login failed (check your email and password)"
              : null;
        } else {
          return "Email and password are required";
        }
      },
      afterFormBuilder: (BuildContext context) {
        // A link to retrieve the password
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _createButtonBar(context),
              Text.rich(TextSpan(children: [
                const TextSpan(
                  text: "",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text: "Retrieve account or password?",
                    style: const TextStyle(
                        color: Color(0xFF4C4D4A),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                                builder: (context) => const ResetPassword()));
                      }),
                const TextSpan(
                  text: "",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              ])),
              Text.rich(TextSpan(children: [
                const TextSpan(
                  text: "Need to Create An Account? ",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                    text: "Sign Up",
                    style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushNamed(context, "signUp");
                      }),
                const TextSpan(
                  text: ".",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              ])),
            ]);
      },
    );
  }
}
