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
import '../open_health_manager/open_health_manager.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _login = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _firstName.dispose();
    super.dispose();
  }

  Widget _buildForm(BuildContext context) {
    return AutofillGroup(
      child: Form(key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              autofocus: true,
              autofillHints: const <String>[AutofillHints.newUsername],
              decoration: const InputDecoration(hintText: "User Name", prefixIcon: Icon(Icons.account_circle)),
              controller: _login,
              validator: (String? value) => value == null || value.isEmpty ? "User name cannot be blank" : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 15),
            TextFormField(
              autofillHints: const <String>[AutofillHints.givenName],
              decoration: const InputDecoration(hintText: "First Name", prefixIcon: Icon(Icons.badge)),
              controller: _firstName,
              validator: (String? value) => value == null || value.isEmpty ? "First name cannot be blank" : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 15),
            TextFormField(
              autofillHints: const <String>[AutofillHints.familyName],
              decoration: const InputDecoration(hintText: "Last Name", prefixIcon: Icon(Icons.badge)),
              controller: _lastName,
              validator: (String? value) => value == null || value.isEmpty ? "Last name cannot be blank" : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 15),
            TextFormField(
              autofillHints: const <String>[AutofillHints.email],
              decoration: const InputDecoration(hintText: "Email Address", prefixIcon: Icon(Icons.email)),
              controller: _email,
              // TODO (maybe): Validate that this is at least sort of accurate
              validator: (String? value) => value == null || value.isEmpty ? "Email cannot be blank" : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 15),
            TextFormField(
              autofillHints: const <String>[AutofillHints.newPassword],
              decoration: const InputDecoration(hintText: "Password", prefixIcon: Icon(Icons.lock)),
              controller: _password,
              obscureText: true,
              validator: (String? value) => value == null || value.isEmpty ? "Password cannot be blank" : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 15),
            TextFormField(
              // Apparently should also be "new password"
              autofillHints: const <String>[AutofillHints.newPassword],
              decoration: const InputDecoration(hintText: "Confirm Password", prefixIcon: Icon(Icons.lock)),
              controller: _confirmPassword,
              obscureText: true,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return null;
                }
                // Otherwise, check if they match
                return value == _password.text ? null : "Passwords do not match";
              },
              textInputAction: TextInputAction.done,
              onEditingComplete: () {
                Actions.invoke(context, const SubmitIntent());
              },
            ),
          ],
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return AccountScreen(
      title: "Sign Up",
      formBuilder: _buildForm,
      submitLabel: "Sign Up",
      onSubmit: () async {
        // currentState being null would indicate an actual error in the code
        if (_formKey.currentState!.validate()) {
          await context.read<OpenHealthManager>().createAccount(
            _login.text, _email.text, _password.text,
            firstName: _firstName.text,
            lastName: _lastName.text
          );
          return null;
        } else {
          return "Please correct the above errors and try again";
        }
      }
    );
  }
}