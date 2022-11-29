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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'account_screen.dart';
import 'verify_account.dart';
import '../../data_use_agreement/data_use_agreement.dart';
import '../open_health_manager/open_health_manager.dart';
import '../account/sign_in.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key, required this.dataUseAgreement}) : super(key: key);

  final DataUseAgreement dataUseAgreement;

  @override
  State<StatefulWidget> createState() => _SignUpState();
}

/// Utility to label a checkbox. This is almost like CheckboxListTile except
/// that places the checkbox on the right, which is correct for things like
/// settings lists. This places it on the left.
class _LabeledCheckbox extends StatelessWidget {
  const _LabeledCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.child,
    required this.errorText,
  }) : super(key: key);

  final bool value;
  final void Function(bool?) onChanged;
  final Widget child;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final checkbox = _buildCheckbox(context);
    // If there's error text, we need to wrap the thing in a small column to
    // add it.
    final error = errorText;
    if (error != null) {
      return Column(children: [
        checkbox,
        Text(error, style: TextStyle(color: Theme.of(context).errorColor))
      ]);
    } else {
      return checkbox;
    }
  }

  Widget _buildCheckbox(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        const SizedBox(width: 15),
        Expanded(
          child: InkWell(
            child: child,
            onTap: () {
              onChanged(!value);
            },
          ),
        ),
      ],
    );
  }
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  var _agreesToTerms = false;
  var _assertsAge = false;

  @override
  void dispose() {
    _firstName.dispose();
    super.dispose();
  }

  Widget _buildForm(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              autofillHints: const <String>[AutofillHints.givenName],
              decoration: InputDecoration(
                hintText: localizations.firstNameHint,
                prefixIcon: const Icon(Icons.badge),
              ),
              controller: _firstName,
              validator: (String? value) => value == null || value.isEmpty
                  ? localizations.firstNameRequired
                  : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 15),
            TextFormField(
              autofillHints: const <String>[AutofillHints.familyName],
              decoration: InputDecoration(
                hintText: localizations.lastNameHint,
                prefixIcon: const Icon(Icons.badge),
              ),
              controller: _lastName,
              validator: (String? value) => value == null || value.isEmpty
                  ? localizations.lastNameRequired
                  : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 15),
            TextFormField(
              autofillHints: const <String>[AutofillHints.email],
              decoration: InputDecoration(
                hintText: localizations.emailAddressHint,
                prefixIcon: const Icon(Icons.email),
              ),
              controller: _email,
              // TODO (maybe): Validate that this is at least sort of accurate
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return localizations.emailRequired;
                } else if (!isValidEmail(value)) {
                  return localizations.invalidEmailFormat;
                } else {
                  return null;
                }
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 15),
            TextFormField(
              autofillHints: const <String>[AutofillHints.newPassword],
              decoration: InputDecoration(
                hintText: localizations.passwordHint,
                prefixIcon: const Icon(Icons.lock),
              ),
              controller: _password,
              obscureText: true,
              validator: (String? value) => value == null || value.isEmpty
                  ? localizations.passwordRequired
                  : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 15),
            TextFormField(
              // Apparently should also be "new password"
              autofillHints: const <String>[AutofillHints.newPassword],
              decoration: InputDecoration(
                hintText: localizations.confirmPasswordHint,
                prefixIcon: const Icon(Icons.lock),
              ),
              controller: _confirmPassword,
              obscureText: true,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return null;
                }
                // Otherwise, check if they match
                return value == _password.text
                    ? null
                    : localizations.confirmPasswordMismatch;
              },
              textInputAction: TextInputAction.done,
              onEditingComplete: () {
                Actions.invoke(context, const SubmitIntent());
              },
            ),
            const SizedBox(height: 15),
            FormField<bool>(
              builder: (field) => _LabeledCheckbox(
                value: field.value == true,
                onChanged: (bool? newValue) {
                  field.didChange(newValue);
                  setState(() {
                    _agreesToTerms = newValue == true;
                  });
                },
                errorText: field.errorText,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: localizations.agreeTOSBefore),
                      TextSpan(
                        text: localizations.agreeTOSLink,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(widget.dataUseAgreement.source);
                          },
                      ),
                      TextSpan(text: localizations.agreeTOSAfter),
                    ],
                  ),
                ),
              ),
              validator: (value) {
                return value == true
                    ? null
                    : localizations.errorAgreeTOS;
              },
              initialValue: _agreesToTerms,
            ),
            const SizedBox(height: 15),
            FormField<bool>(
              builder: (field) => _LabeledCheckbox(
                value: field.value == true,
                onChanged: (bool? newValue) {
                  field.didChange(newValue);
                  setState(() {
                    _assertsAge = newValue == true;
                  });
                },
                errorText: field.errorText,
                child: Text(localizations.assertAge),
              ),
              validator: (value) {
                return value == true
                    ? null
                    : localizations.errorAssertAge;
              },
              initialValue: _assertsAge,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AccountScreenForm(
      title: localizations.signUpTitle,
      formBuilder: _buildForm,
      submitLabel: localizations.signUpButton,
      onSubmit: () async {
        // currentState being null would indicate an actual error in the code
        if (_formKey.currentState!.validate()) {
          // It doesn't seem likely this can change during load but go ahead and
          // make it immutable anyway
          final email = _email.text;
          await context.read<OpenHealthManager>().createAccount(
                email,
                _password.text,
                firstName: _firstName.text,
                lastName: _lastName.text,
                dataUseAgreement: widget.dataUseAgreement,
                duaAccepted: _agreesToTerms,
                ageAttested: _assertsAge,
              );
          // Ensure the view is still mounted
          if (!mounted) return null;
          // If here, we need to push on to the verify account page
          // TODO: Should this reset the nav stack?
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyAccountScreen(email: email),
            ),
          );
          return null;
        } else {
          return localizations.correctAboveErrors;
        }
      },
      afterFormBuilder: (BuildContext context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEF2F5),
              ),
              child: Text(
                localizations.back,
                style: const TextStyle(color: Color(0xFF1F201D)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: localizations.haveAccount),
                  TextSpan(
                    text: localizations.haveAccountLink,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushNamed(context, "signIn");
                      },
                  ),
                  const TextSpan(text: ".")
                ],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
