import 'package:flutter/material.dart';
import 'package:rosie/src/care_plan/care_plan_cards.dart';
import 'package:rosie/src/service/preventative_services_task_force.dart';
import 'package:rosie/src/open_health_manager/patient_data.dart';
import 'package:provider/provider.dart';

class CarePlanHome extends StatefulWidget {
  const CarePlanHome({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CarePlanHomeState();
}

class _CarePlanHomeState extends State<CarePlanHome> {
  late Future<Map<String, dynamic>?>? _taskforceAPIFuture;

  @override
  void initState() {
    super.initState();
    _taskforceAPIFuture = PreventativeServicesTaskForce(
            apiKey: "a49dac2626acf9ab1aef69b961e40dd2")
        .getRecommendedServicesForPatient(
            Provider.of<PatientData>(context, listen: false));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: FutureBuilder<Map<String, dynamic>?>(
              builder: (context, snapshot) {
                final List<CarePlanCards> cards = <CarePlanCards>[];
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    cards.add(const CarePlanCards(
                      title: 'Blood Pressure',
                      heading: 'Blood Pressure Screening',
                      subheading: 'Annual',
                      screeningText: 'Based on your ',
                      patientInfoText: 'current info ',
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
                    cards.add(const CarePlanCards(
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
                    ));
                    break;
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.data != null) {
                      for (dynamic rec
                          in snapshot.data?["specificRecommendations"]) {
                        if (rec["title"]
                            .startsWith("Hypertension in Adults: Screening")) {
                          // put hypertension first if present
                          cards.insert(
                              0,
                              const CarePlanCards(
                                title: 'Blood Pressure',
                                heading: 'Blood Pressure Screening',
                                subheading: 'Annual',
                                screeningText:
                                    'Based on your last blood pressure ',
                                patientInfoText:
                                    'more than a year ago and your age (42 years old), ',
                                recommendationText:
                                    'you should get your blood pressure checked at least once a year.',
                                dataServicesHeading: 'US Preventative Services',
                                dataServicesSubHeading:
                                    'Preventative Task Force',
                                imageReferenceText:
                                    'assets/care_plan/hypertension-in-adults-screening.png',
                              ));
                        } else {
                          cards.add(CarePlanCards(
                            title: rec["title"] ?? "",
                            heading: rec["title"] ?? "",
                            subheading: '',
                            screeningText:
                                (rec["text"] ?? "").replaceAll("<br>", ""),
                            patientInfoText: "",
                            recommendationText: "",
                            dataServicesHeading: 'US Preventative Services',
                            dataServicesSubHeading: 'Preventative Task Force',
                            imageReferenceText:
                                'assets/care_plan/lung-cancer-screening.png',
                          ));
                        }
                      }
                    }
                }
                return Column(children: cards);
              },
              future: _taskforceAPIFuture)),
    );
  }
}
