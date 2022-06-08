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

/// This provides the basic framework for the two otherwise identical sign-in
/// screens.
class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key, required this.title, required this.fields, required this.submitLabel, required this.onSubmit, this.loadingLabel="Loading..."}) : super(key: key);

  final String title;
  final List<Widget> fields;
  final String submitLabel;
  final String loadingLabel;
  /// Async function to perform the submit. Return a string to indicate an error
  /// occurred that prevents submitting the form. Return null to indicate the
  /// submit succeeded.
  final Future<String?> Function() onSubmit;

  @override
  createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  /// This is the future that indicates if a login/account creation is in process
  Future<String?>? _submitFuture;

  @override
  Widget build(BuildContext context) {
    List<Widget> formChildren = [
      Text(widget.title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AccountThemePalette.textColor)),
      const SizedBox(height: 30.0)
    ];
    for (var element in widget.fields) {
      // For each field, we add a SizedBox between to add a bit of padding
      if (formChildren.length > 2) {
        formChildren.add(const SizedBox(height: 15.0));
      }
      formChildren.add(element);
    }
    formChildren.add(const SizedBox(height: 30.0));
    formChildren.add(FutureBuilder(future: _submitFuture,
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.done:
            final submitButton = ElevatedButton(
              child: Text(widget.submitLabel),
              onPressed: () {
                setState(() { _submitFuture = widget.onSubmit(); });
              }
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
    ));
    return Theme(
      data: createAccountTheme(),
      child: Scaffold(
        appBar: AppBar(),
        backgroundColor: AccountThemePalette.background,
        body: SafeArea(
          child: Column(
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