// This provides the sign in process

import 'package:flutter/material.dart';
import 'account_theme.dart';
import '../auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey _formState = GlobalKey(debugLabel: "SignIn");
  String? email;
  String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(),
      body: SafeArea(child: Center(child: Container(
        decoration: createAccountBoxDecoration(),
        child: Theme(
          child: Form(key: _formState,
            child: Column(children: [
              const Text("Sign In", style: TextStyle(fontSize: 30.0, color: Colors.white, fontWeight: FontWeight.bold)),
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
              TextButton(
                child: const Text('Sign In'),
                onPressed: () async {
                  if (email != null && password != null) {
                    await OpenHealthManagerAuthScope.of(context).signIn(email!, password!);
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

// This provides the black bordered thing around the widget
// class AccountWidget extends StatelessWidget {
//   const AccountWidget({Key? key, required this.child}): super(key: key);

//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     //
//   }
// }