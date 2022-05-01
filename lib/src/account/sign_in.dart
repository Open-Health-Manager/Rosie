// This provides the sign in process

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'account_screen.dart';
import '../open_health_manager/open_health_manager.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String? email;
  String? password;

  @override
  Widget build(BuildContext context) {
    return AccountScreen(
      title: "Sign In",
      fields: [
        TextFormField(
          autocorrect: false,
          decoration: const InputDecoration(hintText: "Email", prefixIcon: Icon(Icons.email)),
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
        ),
        TextFormField(
          autocorrect: false,
          decoration: const InputDecoration(hintText: "Password", prefixIcon: Icon(Icons.lock)),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Password cannot be blank";
            }
            return null;
          },
          onChanged: (value) {
            password = value;
          }
        ),
      ],
      submitLabel: "Sign In",
      onSubmit: () async {
        if (email != null && password != null) {
          final auth = await context.read<OpenHealthManager>().signIn(email!, password!);
          return auth != null;
        } else {
          // Show a dialog?
          return false;
        }
      },
    );
  }
}