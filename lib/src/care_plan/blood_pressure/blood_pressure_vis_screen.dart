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

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../rosie_dialog.dart';
import '../../rosie_text_balloon.dart';
import '../../rosie_theme.dart';
import '../../open_health_manager/patient_data.dart';
import '../../open_health_manager/blood_pressure.dart';
import 'blood_pressure_entry.dart';
import 'blood_pressure_chart.dart';

class BloodPressureScale {
  const BloodPressureScale(this.systolicRange, this.diastolicRange);

  static const ages18To59 =
      BloodPressureScale([90, 140, 180, 230], [60, 90, 110, 140]);
  static const ages60Up =
      BloodPressureScale([90, 150, 180, 230], [60, 90, 110, 140]);

  factory BloodPressureScale.forAge(int age) {
    if (age < 60) {
      return ages18To59;
    } else {
      return ages60Up;
    }
  }

  final List<int> systolicRange;
  final List<int> diastolicRange;

  List<double> get systolicPercentStops {
    final max = systolicRange.last.toDouble();
    return List.from(systolicRange.map<double>((e) => e.toDouble() / max));
  }

  List<double> get diastolicPercentStops {
    final max = diastolicRange.last.toDouble();
    return List.from(diastolicRange.map<double>((e) => e.toDouble() / max));
  }

  // Determines which slice of the scale the given BP value falls in.
  int activeSlice(double systolic, double diastolic) {
    // Range are maxmium values for each slice, so find the first one they fit in
    int systolicSlice =
        systolicRange.indexWhere((element) => systolic < element);
    int diastolicSlice =
        diastolicRange.indexWhere((element) => diastolic < element);
    // Return whichever slice is greatest, capping to whatever the ranges are
    return math.min(
        math.max(systolicSlice, diastolicSlice), systolicRange.length - 1);
  }
}

/// The blood pressure visualization screen.
class BloodPressureVisualizationScreen extends StatefulWidget {
  const BloodPressureVisualizationScreen(
      {Key? key, this.scale = BloodPressureScale.ages18To59})
      : super(key: key);

  final BloodPressureScale scale;

  @override
  State<BloodPressureVisualizationScreen> createState() =>
      _BloodPressureVisualizationState();
}

BloodPressureObservation? mostRecentObservation(
    List<BloodPressureObservation>? observations) {
  if (observations == null || observations.isEmpty) {
    return null;
  } else {
    return observations.reduce((first, second) {
      final firstTaken = first.taken;
      if (firstTaken == null) {
        // If the first was taken at an unknown time, always use the second.
        // Basically, prefer later in the list if all taken times are
        // unknown.
        return second;
      }
      final secondTaken = second.taken;
      if (secondTaken == null) {
        // In this case, first has a taken time but second doesn't.
        return first;
      }
      // Otherwise, return whichever one is later
      return secondTaken.isAfter(firstTaken) ? second : first;
    });
  }
}

class _BloodPressureVisualizationState
    extends State<BloodPressureVisualizationScreen> {
  late Future<List<BloodPressureObservation>?> _bloodPressureFuture;

  @override
  void initState() {
    super.initState();
    _bloodPressureFuture = context.read<PatientData>().bloodPressure.get();
  }

  Widget _createUpdateAction(String label, BuildContext context,
      PatientData patientData, BloodPressureObservation? bloodPressure) {
    return ElevatedButton(
        child: Text(label),
        onPressed: () async {
          final updatedSample = await showDialog<BloodPressureObservation>(
              context: context,
              builder: (context) {
                return RosieDialog(children: [
                  BloodPressureEntry(
                    initialSystolic: bloodPressure?.systolic,
                    initialDiastolic: bloodPressure?.diastolic,
                  )
                ]);
              });
          if (updatedSample != null) {
            setState(() {
              patientData.addBloodPressureObservation(updatedSample);
              // This essentially just tells it to recheck the value - it should be the same list object but it should
              // then pull in the most recent
              _bloodPressureFuture = patientData.bloodPressure.get();
            });
          }
        });
  }

  Widget _createReloadAction(
      String label, BuildContext context, PatientData patientData) {
    return ElevatedButton(
        child: Text(label),
        onPressed: () {
          setState(() {
            _bloodPressureFuture = patientData.bloodPressure.reload();
          });
        });
  }

  Widget _createRosieBubble(BuildContext context, PatientData patientData,
      BloodPressureObservation? bloodPressure, BPChartUrgency urgency) {
    var text = "Update your blood pressure here.";
    var updateLabel = "Update";
    var expression = RosieExpression.neutral;
    if (urgency.index >= 3) {
      text = "Update your blood pressure now!";
      updateLabel = "Update now";
      expression = RosieExpression.surprised;
    } else {
      if (urgency.outdated) {
        text =
            "Make sure to get your blood pressure checked, then update it here.";
      }
    }
    return RosieTextBalloon.text(text,
        action: _createUpdateAction(
            updateLabel, context, patientData, bloodPressure),
        actionPosition: RosieActionPosition.after,
        expression: expression);
  }

  Widget _createChart(BuildContext context,
      BloodPressureObservation? bloodPressure, BPChartUrgency urgency,
      {loading = false}) {
    Widget chart = BloodPressureChart(
        bloodPressure: bloodPressure,
        typeLabelStyle: RosieTheme.comicFont(color: Colors.white, fontSize: 16),
        numericLabelStyle: RosieTheme.comicFont(
            color: Colors.white, fontSize: 20, height: 1.0),
        scale: widget.scale,
        urgency: urgency);
    if (loading) {
      chart = Stack(
        alignment: Alignment.center,
        children: [chart, const CircularProgressIndicator()],
      );
    }
    return Expanded(
        child: SafeArea(
            child: Padding(padding: const EdgeInsets.all(8), child: chart)));
  }

  @override
  Widget build(BuildContext context) {
    // Grab the current blood pressure from the patient data store
    final patientData = context.read<PatientData>();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
          padding: const EdgeInsets.all(4),
          child: FutureBuilder<List<BloodPressureObservation>?>(
              builder: (context, snapshot) {
                final Widget chart;
                final Widget rosieBubble;
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    chart = _createChart(context, null,
                        const BPChartUrgency(-1, outdated: true));
                    rosieBubble = RosieTextBalloon.text(
                        "No blood pressure available.",
                        action: _createReloadAction(
                            "Reload", context, patientData));
                    break;
                  case ConnectionState.waiting:
                    // When loading, show that
                    chart = _createChart(
                        context, null, const BPChartUrgency(-1, outdated: true),
                        loading: true);
                    rosieBubble = RosieTextBalloon.text(
                        "Please wait while your blood pressure data is loaded...");
                    break;
                  case ConnectionState.active:
                  case ConnectionState.done:
                    // In both these cases, try and get a value.
                    final bloodPressure = mostRecentObservation(snapshot.data);
                    final urgency = BPChartUrgency(
                        bloodPressure == null
                            ? -1
                            : widget.scale.activeSlice(bloodPressure.systolic,
                                bloodPressure.diastolic),
                        outdated: bloodPressure?.isOutdated() ?? true);
                    chart = _createChart(context, bloodPressure, urgency);
                    if (snapshot.hasError) {
                      rosieBubble = RosieTextBalloon.rich(
                          TextSpan(children: <TextSpan>[
                            const TextSpan(
                                text:
                                    "An error prevented your blood pressure data from being loaded.\n\n"),
                            TextSpan(
                                text: snapshot.error?.toString() ??
                                    "No error data available",
                                style: const TextStyle(color: RosieTheme.error))
                          ]),
                          expression: RosieExpression.surprised,
                          action: _createReloadAction(
                              "Retry", context, patientData));
                    } else {
                      rosieBubble = _createRosieBubble(
                          context, patientData, bloodPressure, urgency);
                    }
                }
                return Column(
                    children: [chart, const SizedBox(height: 2), rosieBubble]);
              },
              future: _bloodPressureFuture)),
      appBar: AppBar(),
    );
  }
}
