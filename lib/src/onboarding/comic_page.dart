// A single page in the data agreement comic.

import 'package:flutter/material.dart';
import 'onboarding_theme.dart';

// Holds data about a single page
class _Page {
  const _Page({required this.altText, this.nextLabel="Next"});

  final String altText;
  final String nextLabel;
}

const List<_Page> agreementPages = [
  _Page(altText: "Get control of your health. Follow me and learn how!"),
  _Page(altText: "Your data can come from anywhere... from you, the doctor\u2019s office, or a device like your phone. We put it all in the same place."),
  _Page(altText: "Now you can finally have one place to see your entire health picture."),
  _Page(altText: "Mistakes Happen. This is why you can correct (with some exceptions) and annotate your data."),
  _Page(altText: "You can share your data with anyone. We always need your permission before sharing your data."),
  _Page(altText: "You can share your data with recommendation services to access suggestions for a healthier lifestyle."),
  _Page(altText: "You can share data automatically during an emergency. First responders would be able to see critical health information about you."),
  _Page(altText: "You can review who has access to your data.", nextLabel: "Half-way through, continue"),
  _Page(altText: "You can stop sharing your data at any time."),
  _Page(altText: "However, those you have shared with may keep a copy of your data. But, they cannot get any new data after you stop sharing."),
  _Page(altText: "You can delete your data. We won\u2019t keep a copy. However, we can\u2019t make people delete the data you already shared with them."),
  _Page(altText: "You can transfer your data. We won\u2019t keep a copy."),
  _Page(altText: "We\u2019re responsible for keeping your data safe. You can hold us accountable if there is a data breach from Open Health Manager.")
];

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
                    child: const Text(
                      "By checking this box, I understand and agree to the terms of the Patient Data Use Agreement and acknowledge that typing my name above represents my electronic signature.",
                      softWrap: true,
                      textAlign: TextAlign.start,
                    )
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

// A single comic page. Requires
class ComicPage extends StatelessWidget {
  const ComicPage({Key? key, required this.text, required this.comicPage, required this.pageNumber, required this.nextLabel}) : super(key: key);

  final String text;
  final String comicPage;
  final String nextLabel;
  final int pageNumber;

  @override
  Widget build(BuildContext context) {
    // This children change depending on page number, so build them first
    final List<Widget> children = [
      Expanded(child: Image(image: AssetImage(comicPage), fit: BoxFit.contain)),
      Container(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child:
        ElevatedButton(
          onPressed: () {
            // When pressed, move on to the next page, if possible
            Navigator.pushNamed(context, "page", arguments: pageNumber + 1);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(nextLabel),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded)
            ]
          )
        )
      )
    ];
    if (pageNumber == 0) {
      // Add a way to log in
      children.insert(0, Row(children: [
        const Text("Already have an account?"),
        TextButton(
          child: const Text("Sign In"),
          onPressed: () {
            Navigator.pushNamed(context, "signIn");
          }
        )
      ]));
    }
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(children: children)
      )
    );
  }

}

Widget createPage(int pageNumber) {
  if (pageNumber < 0 || pageNumber > agreementPages.length) {
    throw RangeError.range(pageNumber, 0, agreementPages.length, "pageNumber");
  }
  if (pageNumber < agreementPages.length) {
    final page = agreementPages[pageNumber];
    return Theme(
      data: createOnboardingTheme(),
      child: ComicPage(
        text: page.altText,
        comicPage: "assets/data_use_agreement/page${pageNumber + 1}.png",
        pageNumber: pageNumber,
        nextLabel: page.nextLabel
      )
    );
  } else {
    // In this case, they're at the end, so show the signature page
    return Theme(data: createOnboardingTheme(), child: const SignaturePage());
  }
}