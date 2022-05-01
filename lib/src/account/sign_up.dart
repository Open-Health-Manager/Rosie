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
  String? fullName;
  String? email;

  @override
  Widget build(BuildContext context) {
    return AccountScreen(
      title: "Sign Up",
      fields: [
        TextFormField(
          autocorrect: false,
          decoration: const InputDecoration(hintText: "Full Name", prefixIcon: Icon(Icons.account_circle)),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Full name is required";
            }
            return null;
          },
          onChanged: (value) {
            fullName = value;
          }
        ),
        TextFormField(
          autocorrect: false,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(hintText: "Email", prefixIcon: Icon(Icons.email)),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Email is required";
            }
            return null;
          },
          onChanged: (value) {
            email = value;
          }
        )
      ],
      submitLabel: "Sign Up",
      onSubmit: () async {
        if (fullName != null && email != null) {
          await context.read<OpenHealthManager>().createAccount(fullName!, email!);
          return true;
        } else {
          // Show a dialog?
          return false;
        }
      }
    );
  }
}