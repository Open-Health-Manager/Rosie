// This provides the sign in process

import 'package:flutter/material.dart';
import 'account_theme.dart';
import '../auth.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignUpState();
}

class SignUpData {
}

class _SignUpState extends State<SignUp> {
  final GlobalKey _formState = GlobalKey(debugLabel: "SignUp");
  String? fullName;
  String? email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(),
      body: SafeArea(child: Center(child: Container(
        decoration: createAccountBoxDecoration(),
        child: Theme(
          child: Form(key: _formState,
            child: Column(children: [
              const Text("Sign Up", style: TextStyle(fontSize: 30.0, color: Colors.white, fontWeight: FontWeight.bold)),
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
              ),
              TextButton(
                child: const Text('Sign Up'),
                onPressed: () async {
                  if (fullName != null && email != null) {
                    await OpenHealthManagerAuthScope.of(context).createAccount(fullName!, email!);
                  } else {
                    // Show a dialog?
                  }
                }
              )
            ])
          ),
          data: createAccountTheme()
        )
      )))
    );
  }
}