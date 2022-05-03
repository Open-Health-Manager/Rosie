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
import '../../open_health_manager/patient_data.dart';

class BloodPressureEntry extends StatefulWidget {
  const BloodPressureEntry({Key? key, required this.initialSystolic, required this.initialDiastolic}) : super(key: key);

  final double? initialSystolic;
  final double? initialDiastolic;

  @override
  State<StatefulWidget> createState() => _BloodPressureEntryState();
}

class _BloodPressureEntryState extends State<BloodPressureEntry> {
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();

  @override
  initState() {
    super.initState();
    _systolicController.text = widget.initialSystolic?.toStringAsFixed(0) ?? "";
    _diastolicController.text = widget.initialDiastolic?.toStringAsFixed(0) ?? "";
  }

  Widget _createTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text("Enter your blood pressure"),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(child: _createTextField("Systolic", _systolicController), width: 88),
            const Text("/", style: TextStyle(fontSize: 50)),
            SizedBox(child: _createTextField("Diastolic", _diastolicController), width: 85)
          ]
        ),
        const Align(alignment: AlignmentDirectional.centerEnd, child: Text("on Unspecified Date")),
        Row(mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            ElevatedButton(
              child: const Text("Help"),
              onPressed: () {
                // TODO: Show dialog
              },
            ),
            ElevatedButton(
              child: const Text("Update"),
              onPressed: () {
                Navigator.of(context).pop(BloodPressureSample(double.tryParse(_systolicController.text) ?? 0, double.tryParse(_diastolicController.text) ?? 0));
              }
            )
          ]
        )
      ]
    );
  }

  @override
  dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    super.dispose();
  }
}