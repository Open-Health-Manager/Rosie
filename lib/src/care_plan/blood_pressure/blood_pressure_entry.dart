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
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../open_health_manager/blood_pressure.dart';
import '../../open_health_manager/patient_data.dart';
import '../../rosie_dialog.dart';
import '../../rosie_text_balloon.dart';
import '../../rosie_theme.dart';
import 'blood_pressure_help.dart';

class BloodPressureEntry extends StatefulWidget {
  const BloodPressureEntry(
      {Key? key, required this.initialSystolic, required this.initialDiastolic})
      : super(key: key);

  final double? initialSystolic;
  final double? initialDiastolic;

  @override
  State<StatefulWidget> createState() => _BloodPressureEntryState();
}

class _BloodPressureEntryState extends State<BloodPressureEntry> {
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  var _entryDate = DateTime.now();

  @override
  initState() {
    super.initState();
    _systolicController.text = widget.initialSystolic?.toStringAsFixed(0) ?? "";
    _diastolicController.text =
        widget.initialDiastolic?.toStringAsFixed(0) ?? "";
  }

  Widget _createTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  Widget _createEntryFields(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 88,
              child: _createTextField("Systolic", _systolicController),
            ),
            const Text("/", style: TextStyle(fontSize: 48)),
            SizedBox(
              width: 85,
              child: _createTextField("Diastolic", _diastolicController),
            ),
          ],
        ),
        InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                "on ${DateFormat.yMd().format(_entryDate)}",
                style: RosieTheme.comicFont(color: RosieTheme.accent),
              ),
              const Icon(Icons.edit_outlined, size: 14),
            ],
          ),
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _entryDate,
              firstDate: DateTime(1970),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              setState(() {
                _entryDate = pickedDate;
              });
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text("Enter your blood pressure", style: RosieTheme.font(fontSize: 20)),
        _createEntryFields(context),
        ButtonBar(
          children: <Widget>[
            OutlinedButton(
              child: const Text("Help"),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) {
                    return const RosieDialog(
                      expression: RosieExpression.surprised,
                      children: [
                        // For right now, this is never an "emergency" when
                        // showing the help, that's only ever accessed via the
                        // main page
                        BloodPressureHelp(emergency: false)
                      ],
                    );
                  },
                );
              },
            ),
            ElevatedButton(
              child: const Text("Update"),
              onPressed: () async {
                // When the button is pressed, try and store the new value in
                // the backend
                final obs = BloodPressureObservation(
                  double.tryParse(_systolicController.text) ?? 0,
                  double.tryParse(_diastolicController.text) ?? 0,
                  _entryDate,
                );
                final patientData = context.read<PatientData>();
                // Push on a dialog state, not awaiting the future
                Navigator.of(context).push(DialogRoute(
                  context: context,
                  builder: (BuildContext context) {
                    return const RosieDialog(
                      title: "Updating Health Record...",
                      children: <Widget>[
                        CircularProgressIndicator(),
                      ],
                    );
                  },
                ));
                await patientData.addBloodPressureObservation(obs);
                if (!mounted) return;
                // Pop off our loading modal
                Navigator.of(context).pop();
                // And the observation we just created
                Navigator.of(context).pop(obs);
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    super.dispose();
  }
}
