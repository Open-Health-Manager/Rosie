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
import 'package:provider/provider.dart';
import 'care_plan_cards.dart';
import 'patient_info_form/patient_info.dart';
import '../service/preventative_services_task_force.dart';
import '../open_health_manager/patient_data.dart';

class CarePlanHome extends StatefulWidget {
  const CarePlanHome({Key? key, required this.apiKey}) : super(key: key);

  final String apiKey;

  @override
  State<StatefulWidget> createState() => _CarePlanHomeState();
}

class _CarePlanHomeState extends State<CarePlanHome> {
  late Future<Map<String, dynamic>?>? _taskforceAPIFuture;

  void triggerAPICall() {
    _taskforceAPIFuture = PreventativeServicesTaskForce(apiKey: widget.apiKey)
        .getRecommendedServicesForPatient(
            Provider.of<PatientData>(context, listen: false));
  }

  @override
  void initState() {
    super.initState();
    triggerAPICall();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<PatientData>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
          child: FutureBuilder<Map<String, dynamic>?>(
              builder: (context, snapshot) {
                final List<CarePlanCards> cards = <CarePlanCards>[];
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    cards.add(CarePlanCards(
                      title: 'Blood Pressure',
                      heading: 'Blood Pressure Screening',
                      subheading: 'Annual',
                      screeningText: 'Based on your ',
                      patientInfoText: 'current info ',
                      patientInfoOnTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PatientInfo()),
                        );
                        triggerAPICall();
                      },
                      recommendationText:
                          'you should get your blood pressure checked at least once a year.',
                      dataServicesHeading: 'US Preventative Services',
                      dataServicesSubHeading: 'Preventative Task Force',
                      imageReferenceText:
                          'assets/care_plan/hypertension-in-adults-screening.png',
                    ));
                    break;
                  case ConnectionState.waiting:
                    // When loading, show that
                    /*cards.add(const CarePlanCards(
                  title: 'Calling API',
                  heading: 'Calling API',
                  subheading: '',
                  screeningText: '',
                  patientInfoText: '',
                  recommendationText: '',
                  dataServicesHeading: 'US Preventative Services',
                  dataServicesSubHeading: 'Preventative Task Force',
                  imageReferenceText:
                      'assets/care_plan/lung-cancer-screening.png',
                ));*/
                    return Row(children: const [
                      CircularProgressIndicator(),
                      SizedBox(width: 8),
                      Flexible(flex: 1, child: Text("Loading..."))
                    ]);
                  // break;
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.data != null) {
                      _createCards(cards, snapshot.data!);
                    }
                }
                return Column(children: <Widget>[
                  const SizedBox(height: 16),
                  ...cards,
                  const SizedBox(height: 16)
                ]);
              },
              future: _taskforceAPIFuture)),
    );
  }

  void _createCards(List<CarePlanCards> cards, Map<String, dynamic> data) {
    for (final rec in data["specificRecommendations"]) {
      if (rec["title"].startsWith("Hypertension in Adults: Screening")) {
        // put hypertension first if present
        cards.insert(
            0,
            CarePlanCards(
              title: 'Blood Pressure',
              heading: 'Blood Pressure Screening',
              subheading: 'Annual',
              screeningText: 'Based on your ',
              patientInfoText: 'current info ',
              patientInfoOnTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PatientInfo()),
                );
                setState(() => triggerAPICall());
              },
              recommendationText:
                  'you should get your blood pressure checked at least once a year.',
              dataServicesHeading: 'US Preventative Services',
              dataServicesSubHeading: 'Preventative Task Force',
              imageReferenceText:
                  'assets/care_plan/hypertension-in-adults-screening.png',
            ));
      } else {
        cards.add(CarePlanCards(
          title: rec["title"] ?? "",
          heading: rec["title"] ?? "",
          subheading: '',
          screeningText: (rec["text"] ?? "").replaceAll("<br>", ""),
          patientInfoText: "",
          patientInfoOnTap: null,
          recommendationText: "",
          dataServicesHeading: 'US Preventative Services',
          dataServicesSubHeading: 'Preventative Task Force',
          imageReferenceText:
              'assets/care_plan/hypertension-in-adults-screening.png',
        ));
      }
    }
  }
}
