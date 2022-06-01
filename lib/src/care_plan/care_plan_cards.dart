import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../rosie_theme.dart';
import 'blood_pressure/blood_pressure_vis_screen.dart';

class CarePlanCards extends StatelessWidget {
  final String title;
  final String heading;
  final String subheading;
  final String screeningText;
  final String imageReferenceText;
  final String dataServicesHeading;
  final String dataServicesSubHeading;
  final String patientInfoText;
  final Function()? patientInfoOnTap;
  final String recommendationText;

  const CarePlanCards(
      {Key? key,
      required this.heading,
      required this.subheading,
      required this.screeningText,
      required this.dataServicesHeading,
      required this.dataServicesSubHeading,
      required this.imageReferenceText,
      required this.patientInfoText,
      required this.patientInfoOnTap,
      required this.recommendationText,
      required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30.0),
      child: Card(
        color: Colors.white,
        elevation: 4.0,
        child: Column(
          children: [
            ListTile(
              title: Text(
                heading,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
              ),
              subtitle: Text(
                subheading,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(
              height: 170.0,
              child: Placeholder(),
            ),
            ListTile(
              title: Text(
                dataServicesHeading,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                dataServicesSubHeading,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(text: screeningText),
                      TextSpan(
                          text: patientInfoText,
                          style: const TextStyle(
                              color: Color(0xFF6750A4),
                              fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = patientInfoOnTap),
                      TextSpan(text: recommendationText),
                    ]),
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  child: const Text('Remind Later',
                      style: TextStyle(color: Color(0xFF6750A4))),
                  onPressed: () {/* ... */},
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white, shape: const StadiumBorder()),
                ),
                ElevatedButton(
                  child: Text('Update $title',
                      style: const TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                          Scaffold(
                            appBar: AppBar(),
                            body: Container(
                              decoration: createRosieScreenBoxDecoration(),
                              child: const SafeArea(child: BloodPressureVisualizationScreen())
                            )
                          )
                      )
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF6750A4),
                      shape: const StadiumBorder()),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}