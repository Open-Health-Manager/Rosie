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

  final _AccountScreenState _state;

  @override
  void invoke(SubmitIntent intent) => _state.submit();
}

/// A scaffolding for the account screens, both the sign in and the create
/// account screens.
class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key, required this.title, required this.builder, required this.submitLabel, required this.onSubmit, this.loadingLabel="Loading..."}) : super(key: key);

  final String title;
  final String submitLabel;
  final String loadingLabel;
  /// Async function to perform the submit. Return a string to indicate an error
  /// occurred that prevents submitting the form. Return null to indicate the
  /// submit succeeded.
  final Future<String?> Function() onSubmit;
  /// Build the widgets that are contained within the form.
  final Widget Function(BuildContext) builder;

  @override
  createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
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
    List<Widget> formChildren = [
      Text(widget.title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AccountThemePalette.textColor)),
      const SizedBox(height: 30.0),
      Builder(builder: widget.builder),
      const SizedBox(height: 30.0),
      FutureBuilder(future: _submitFuture,
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.done:
              final submitButton = ElevatedButton(
                child: Text(widget.submitLabel),
                onPressed: submit
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
                  children:[
                    Text(
                      error,
                      softWrap: true,
                      style: TextStyle(color: Theme.of(context).errorColor)
                    ),
                    submitButton
                  ],
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                );
              }
            case ConnectionState.waiting:
            case ConnectionState.active:
              // Display a loading indicator
              return Row(children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 8),
                Flexible(child: Text(widget.loadingLabel), flex: 1)
              ]);
          }
        },
      )
    ];
    return Theme(
      data: createAccountTheme(),
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        backgroundColor: AccountThemePalette.background,
        extendBodyBehindAppBar: true,
        body: Actions(
          actions: <Type, Action<Intent>>{
            SubmitIntent: _SubmitAction(this)
          },
          child: ListView(
            children: [
              // This exists for padding
              const SizedBox(height: 20.0),
              // Create a stack to place Rosie on top of the screen
              Stack(
                alignment: AlignmentDirectional.topCenter,
                children: [
                  // Rosie is 163x145
                  // This is the "real" box
                  Container(
                    margin: const EdgeInsets.fromLTRB(40.0, 132.0, 40.0, 0.0),
                    padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 20.0),
                    decoration: createAccountBoxDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: formChildren
                    )
                  ),
                  const Image(image: AssetImage("assets/pdm_comic_avatar.png"))
                ]
              )
            ]
          )
        )
      )
    );
  }
}