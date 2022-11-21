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

import 'health_kit/health_kit.dart';
import 'health_kit/send_health_kit_screen.dart';

class HealthKitConnectionScreen extends StatefulWidget {
  const HealthKitConnectionScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HealthKitConnectionScreenState();
}

class _HealthKitConnectionScreenState
    extends State<HealthKitConnectionScreen> {
  late Future<bool> _healthKitAvailable;

  @override
  initState() {
    super.initState();
    _healthKitAvailable = _requestHealthKitAccess();
  }

  Widget _buildScreen(BuildContext context, String headline, String subtext,
      {showRetry = false}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(headline, style: theme.textTheme.headline4, softWrap: true),
          const SizedBox(height: 20),
          Text(subtext, style: theme.textTheme.bodyMedium, softWrap: true),
        ],
      ),
    );
  }

  Future<bool> _requestHealthKitAccess() async {
    return await HealthKit.requestAccess();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _healthKitAvailable,
        initialData: false,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              // In this case, data doesn't matter, display the text indicating loading is progressing
              return _buildScreen(
                context,
                "Requesting HealthKit access...",
                "iOS should ask for your permission to access HealthKit shortly.",
              );
            case ConnectionState.done:
              // Two cases in this case: it succeeded, or it failed.
              // (== true because it could also == null, and nullable expressions
              // cannot be used as a condition)
              if (snapshot.data == true) {
                return const SendHealthKitScreen();
              } else {
                if (snapshot.hasError) {
                  return _buildScreen(
                    context,
                    "Error Connecting to HealthKit",
                    "An error prevented connecting to HealthKit:\n${snapshot.error}",
                  );
                } else {
                  return _buildScreen(
                    context,
                    "HealthKit Not Connected",
                    "Permission to access HealthKit was not granted, so HealthKit data cannot be loaded.",
                    showRetry: true,
                  );
                }
              }
          }
        });
  }
}
