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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'blood_pressure/blood_pressure_vis_screen.dart';
import '../rosie_theme.dart';

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

  const CarePlanCards({
    Key? key,
    required this.heading,
    required this.subheading,
    required this.screeningText,
    required this.dataServicesHeading,
    required this.dataServicesSubHeading,
    required this.imageReferenceText,
    required this.patientInfoText,
    required this.patientInfoOnTap,
    required this.recommendationText,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rosiePalette = theme.extension<RosieThemeExtension>()!.palette;
    final titleTextStyle =
        theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    final subtitleTextStyle =
        theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.normal);
    final linkTextStyle = theme.textTheme.bodyLarge?.copyWith(
      color: rosiePalette.interactive,
      fontWeight: FontWeight.bold,
    );
    return Container(
      margin: const EdgeInsets.only(top: 30.0),
      child: Card(
        elevation: 4.0,
        child: Column(
          children: [
            ListTile(
              title: Text(
                heading,
                textAlign: TextAlign.center,
                style: titleTextStyle,
              ),
              subtitle: Text(
                subheading,
                textAlign: TextAlign.center,
                style: subtitleTextStyle,
              ),
            ),
            SizedBox(
              height: 80, //170.0,
              child: Image(
                image: AssetImage(imageReferenceText),
                //fit: BoxFit.cover,
              ),
            ),
            ListTile(
              title: Text(
                dataServicesHeading,
                style: titleTextStyle,
              ),
              subtitle: Text(
                dataServicesSubHeading,
                style: subtitleTextStyle,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyLarge,
                  children: <TextSpan>[
                    TextSpan(text: screeningText),
                    TextSpan(
                      text: patientInfoText,
                      style: linkTextStyle,
                      recognizer: TapGestureRecognizer()
                        ..onTap = patientInfoOnTap,
                    ),
                    TextSpan(text: recommendationText),
                  ],
                ),
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {/* ... */},
                  child: const Text(
                    'Remind Later',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: Text(title)),
                          body: const SafeArea(
                            child: BloodPressureVisualizationScreen(),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(
                      //'Update $title',
                      title == 'Blood Pressure' ? 'Update $title' : 'Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
