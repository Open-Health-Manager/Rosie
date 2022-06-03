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
  const BloodPressureHelp({Key? key, required this.emergency}) : super(key: key);

  final bool emergency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(emergency ? "How can I help?" : "Let's get some help!", style: RosieTheme.font(fontSize: 24)),
        ..._createActionButtons(context),
        const SizedBox(height: 15),
        _createButtonBar(context)
      ]
    );
  }

  List<Widget> _createActionButtons(BuildContext context) {
    if (emergency) {
      return <Widget>[
        ElevatedButton(child: const Text("Find an emergency room near you"), onPressed: () { }),
        ElevatedButton(child: const Text("Call your emegency contact"), onPressed: () { }),
        ElevatedButton(child: const Text("Call 911"), onPressed: () { })
      ];
    } else {
      final textStyle = RosieTheme.font(fontSize: 14);
      return <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: Text("Show me clinics nearby", style: textStyle)),
            ElevatedButton(child: const Text("Clinics"), onPressed: () { })
          ]
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: Text("Call family", style: textStyle)),
            ElevatedButton(child: const Text("Call Family"), onPressed: () { })
          ]
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: Text("Learn how to check it", style: textStyle)),
            ElevatedButton(child: const Text("Check It"), onPressed: () { })
          ]
        )
      ];
    }
  }

  Widget _createButtonBar(BuildContext context) {
    // Go back button is always the same
    final goBack = OutlinedButton(
      child: const Text("Go Back"),
      onPressed: () { Navigator.of(context).pop(); },
    );
    if (emergency) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        children: <Widget>[
          OutlinedButton(
            child: const Text("Why is this an emergency?"),
            onPressed: () { }
          ),
          goBack
        ]
      );
    } else {
      return Align(
        alignment: AlignmentDirectional.centerEnd,
        child: goBack
      );
    }
  }
}