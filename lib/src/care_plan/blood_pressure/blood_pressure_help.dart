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

import 'package:flutter/material.dart';
import '../../rosie_theme.dart';

class BloodPressureHelp extends StatelessWidget {
  const BloodPressureHelp({Key? key, required this.emergency})
      : super(key: key);

  final bool emergency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          // emergency ? "How can I help?" : "Let's get some help!",
          "Here are some helpful options to check your blood pressure:",
          style: RosieTheme.font(fontSize: 18),
        ),
        const SizedBox(height: 15),
        ..._createActionButtons(context),
        const SizedBox(height: 15),
        _createButtonBar(context),
      ],
    );
  }

  List<Widget> _createActionButtons(BuildContext context) {
    if (emergency) {
      return <Widget>[
        ElevatedButton(
          child: const Text("Find an emergency room near you"),
          onPressed: () {},
        ),
        ElevatedButton(
          child: const Text("Call your emegency contact"),
          onPressed: () {},
        ),
        ElevatedButton(child: const Text("Call 911"), onPressed: () {}),
      ];
    } else {
      return <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text("Call a family member"),
              onPressed: () {},
            )
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text("Find a clinic nearby"),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text("Learn how to check it yourself"),
              onPressed: () {},
            ),
          ],
        ),
      ];
    }
  }

  Widget _createButtonBar(BuildContext context) {
    // Go back button is always the same
    final goBack = OutlinedButton(
      child: const Text("Go Back"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    if (emergency) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        children: <Widget>[
          OutlinedButton(
            child: const Text("Why is this an emergency?"),
            onPressed: () {},
          ),
          goBack,
        ],
      );
    } else {
      return Align(alignment: AlignmentDirectional.center, child: goBack);
    }
  }
}
