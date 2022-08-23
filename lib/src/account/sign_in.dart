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
import 'package:provider/provider.dart';
import 'account_screen.dart';
import 'reset_password.dart';
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
    final goBack = OutlinedButton(
      child: const Text("Back"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    return Align(alignment: AlignmentDirectional.centerEnd, child: goBack);
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
              TextButton(
                child: const Text('Retrieve account or password?'),
                onPressed: () {
                  Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                          builder: (context) => const ResetPassword()));
                },
              ),
              _createButtonBar(context)
            ]);

        /* return TextButton(
          child: const Text('Retrieve account or password?'),
          onPressed: () {
            Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                    builder: (context) => const ResetPassword()));
          },
        ); */
      },
    );
  }
}
