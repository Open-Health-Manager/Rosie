import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'onboarding_theme.dart';

class SignaturePage extends StatefulWidget {
  const SignaturePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SignaturePageState();
}

class SignaturePageState extends State<SignaturePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? fullname;
  bool checked = false;

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signature")),
      body: Container(
        padding: const EdgeInsets.all(40),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 50),
                child: TextFormField(
                  decoration: const InputDecoration(hintText: "Type your full name to sign"),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Your name is required";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    fullname = value;
                  },
                )
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                FormField<bool>(
                  builder: (field) => Checkbox(
                    value: field.value,
                    onChanged: (newValue) {
                      field.didChange(newValue);
                      checked = newValue ?? false;
                    }
                  ),
                  initialValue: false,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: const _AgreementText()
                  )
                )
              ],),
              Container(
                padding: const EdgeInsets.only(top: 50),
                child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: TextButton(
                        child: const Text("Disagree"),
                        onPressed: () {}
                      )
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        child: const Text("Agree"),
                        onPressed: () {
                          if (checked && fullname != null && fullname!.isNotEmpty) {
                            Navigator.pushNamed(context, "signUp");
                          } else {
                            // Show an error
                          }
                        },
                        style: ElevatedButton.styleFrom(primary: OnboardingTheme.primary)
                      )
                    )
                  ]
                )
              )
            ]
          )
        )
      )
    );
  }
}

class _AgreementText extends StatelessWidget {
  const _AgreementText({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: "By checking this box, I understand and agree to the terms of the "),
          TextSpan(
            text: "Patient Data Use Agreement",
            style: const TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()..onTap = () {
              launchUrlString('https://github.com/patient-data-manager/pdua/blob/master/patient-data-use-agreement.md');
            }
          ),
          const TextSpan(text: " and acknowledge that typing my name above represents my electronic signature.")
        ]
      ),
      softWrap: true,
      textAlign: TextAlign.start,
    );
  }
}