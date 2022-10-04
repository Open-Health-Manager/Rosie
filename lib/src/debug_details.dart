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
import 'open_health_manager/open_health_manager.dart';
import 'data_source/health_kit/health_kit.dart';
import 'data_source/health_kit/health_kit_debug.dart';

/// Shows debug details in a Scaffold.
class DebugDetailsScreen extends StatelessWidget {
  const DebugDetailsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Details'),
      ),
      body: const DebugDetails(),
    );
  }
}

/// Provides more detailed information about the current environment
class DebugDetails extends StatefulWidget {
  const DebugDetails({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DebugDetailsState();
}

class _DebugDetailsState extends State<DebugDetails> {
  var _healthKitAvailable = false;

  @override
  void initState() {
    super.initState();
    HealthKit.isHealthDataAvailable().then((available) {
      setState(() {
        _healthKitAvailable = available;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthManager = context.read<OpenHealthManager>();
    return ListView(
      children: <Widget>[
        ListTile(
          title: const Text('OHM Endpoint'),
          subtitle: Text(healthManager.serverUrl.toString()),
        ),
        if (_healthKitAvailable)
          ListTile(
            title: const Text('HealthKit'),
            subtitle: const Text(
                'Showing details will trigger a HealthKit permission request'),
            trailing: TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HealthKitDebugScreen(),
                    ));
              },
              child: const Text('Details'),
            ),
          )
      ],
    );
  }
}
