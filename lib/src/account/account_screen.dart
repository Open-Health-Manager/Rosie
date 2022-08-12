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

// Generic account screen with two fields

import 'package:flutter/material.dart';
import 'account_theme.dart';

/// Intent for submitting the form within the account screen. This is intented
/// to be used to inform the account screen that some action has happened within
/// the form that means it should now invoke the onSubmit function.
class SubmitIntent extends Intent {
  const SubmitIntent();
}

class _SubmitAction extends Action<SubmitIntent> {
  _SubmitAction(this._state);

  final _AccountScreenFormState _state;

  @override
  void invoke(SubmitIntent intent) => _state.submit();
}

/// A widget that shows all the various parts around one of the screens within
/// the account login or signin process. This provides the app bar and the box
/// which Rosie sits on top of.
class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key, required this.builder}) : super(key: key);

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: createAccountTheme(),
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        backgroundColor: AccountThemePalette.background,
        extendBodyBehindAppBar: true,
        body: ListView(
          children: [
            // This exists for padding
            const SizedBox(height: 20.0),
            // Create a stack to place Rosie on top of the screen
            Stack(
              alignment: AlignmentDirectional.topStart,
              children: [
                // Rosie is 163x145
                // This is the "real" box
                Container(
                  margin: const EdgeInsets.fromLTRB(40.0, 60.0, 40.0, 0.0),
                  padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 20.0),
                  decoration: createAccountBoxDecoration(),
                  child: Builder(builder: builder),
                ),
                const Image(image: AssetImage("assets/pdm_comic_avatar.png")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A scaffolding for the account screen form, both the sign in and the create
/// account screens.
class AccountScreenForm extends StatefulWidget {
  const AccountScreenForm({
    Key? key,
    required this.title,
    required this.formBuilder,
    required this.submitLabel,
    required this.onSubmit,
    this.loadingLabel = "Loading...",
    this.afterFormBuilder,
  }) : super(key: key);

  final String title;
  final String submitLabel;
  final String loadingLabel;

  /// Async function to perform the submit. Return a string to indicate an error
  /// occurred that prevents submitting the form. Return null to indicate the
  /// submit succeeded.
  final Future<String?> Function() onSubmit;

  /// Build the widgets that are contained within the form.
  final Widget Function(BuildContext) formBuilder;

  /// An optional builder to build any content that should occur after the form
  final Widget Function(BuildContext)? afterFormBuilder;

  @override
  createState() => _AccountScreenFormState();
}

class _AccountScreenFormState extends State<AccountScreenForm> {
  // This is the future that indicates if a login/account creation is in process
  Future<String?>? _submitFuture;
  // Indicates that a submit is not in progress. This is intended more to
  // prevent accidental double-submitting via code than via the UI.
  bool _canSubmit = true;

  void submit() {
    setState(() {
      if (_canSubmit) {
        final future = widget.onSubmit();
        _canSubmit = false;
        // Add a handler to indicate submitting is allowed again
        _submitFuture = future.whenComplete(() {
          setState(() {
            _canSubmit = true;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final afterFormBuilder = widget.afterFormBuilder;
    List<Widget> formChildren = [
      Text(
        widget.title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AccountThemePalette.textColor,
        ),
      ),
      const SizedBox(height: 30.0),
      Builder(builder: widget.formBuilder),
      const SizedBox(height: 30.0),
      FutureBuilder(
        future: _submitFuture,
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.done:
              // refactor so that styling is the same as other buttons
              final submitButton = ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFFFA99AF),
                ),
                onPressed: submit,
                child: Text(widget.submitLabel),
              );
              String? error;
              if (snapshot.hasError) {
                error = (snapshot.error ?? "Unknown error").toString();
              } else if (snapshot.hasData) {
                error = snapshot.data;
              }
              if (error == null) {
                return submitButton;
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      error,
                      softWrap: true,
                      style: TextStyle(color: Theme.of(context).errorColor),
                    ),
                    submitButton,
                  ],
                );
              }
            case ConnectionState.waiting:
            case ConnectionState.active:
              // Display a loading indicator
              return Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 8),
                  Flexible(flex: 1, child: Text(widget.loadingLabel)),
                ],
              );
          }
        },
      ),
      if (afterFormBuilder != null) Builder(builder: afterFormBuilder),
    ];
    return Actions(
      actions: <Type, Action<Intent>>{SubmitIntent: _SubmitAction(this)},
      child: AccountScreen(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: formChildren,
        ),
      ),
    );
  }
}
