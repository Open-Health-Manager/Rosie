// Generic account screen with two fields

import 'package:flutter/material.dart';
import 'account_theme.dart';

// This provides the basic framework for the two otherwise identical sign-in
// screens.
class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key, required this.title, required this.fields, required this.submitLabel, required this.onSubmit}) : super(key: key);

  final String title;
  final List<Widget> fields;
  final String submitLabel;
  final void Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    List<Widget> formChildren = [
      Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AccountThemePalette.textColor)),
      const SizedBox(height: 30.0)
    ];
    for (var element in fields) {
      // For each field, we add a SizedBox between to add a bit of padding
      if (formChildren.length > 2) {
        formChildren.add(const SizedBox(height: 15.0));
      }
      formChildren.add(element);
    }
    formChildren.add(const SizedBox(height: 30.0));
    formChildren.add(ElevatedButton(
      child: Text(submitLabel),
      onPressed: onSubmit
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