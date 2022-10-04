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
import 'health_kit.dart';
import '../../open_health_manager/open_health_manager.dart';
import '../../open_health_manager/patient_data.dart';

class SendHealthKitScreen extends StatefulWidget {
  const SendHealthKitScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SendHealthKitScreenState();
}

/// Filters out resources that can't be handled.
Iterable<HealthKitResource> filterResources(
    Iterable<HealthKitResource> resources) {
  // Set of resource types that can't be handled by DSTU2 to R4 HAPI converter
  const blacklist = <String>{
    'allergyintolerance',
    'immunization',
    'medicationorder',
    'medicationrequest',
    'procedure'
  };
  return resources.where((resource) {
    return !blacklist
        .contains(resource.resource['resourceType'].toString().toLowerCase());
  });
}

class _SendHealthKitScreenState extends State<SendHealthKitScreen> {
  late final OpenHealthManager healthManager;
  Future<List<HealthKitResource>>? recordFuture;
  var currentActivity = "";

  @override
  void initState() {
    super.initState();
    healthManager = context.read<OpenHealthManager>();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HealthKitResource>>(
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return buildBaseScreen(context);
            case ConnectionState.waiting:
            case ConnectionState.active:
              return buildBaseScreen(context, loading: true);
            case ConnectionState.done:
              return buildBaseScreen(
                context,
                reload: true,
                uploadCount: snapshot.data?.length,
                error: snapshot.error,
              );
          }
        },
        future: recordFuture);
  }

  void loadRecords() {
    setState(() {
      recordFuture =
          HealthKit.queryAllClinicalRecords(healthManager).then((records) {
        setState(() {
          currentActivity = "Sending records to Open Health Manager...";
        });
        return healthManager
            .sendProcessMessage(
              filterResources(records)
                  .map<Map<String, dynamic>>((e) => e.asFhirR4Resource()),
              fhirVersion: "dstu2",
              endpoint: "urn:apple:health-kit",
            )
            .then((_) => records);
      });
      currentActivity = "Loading records from HealthKit...";
    });
  }

  Widget buildBaseScreen(
    BuildContext context, {
    bool loading = false,
    bool reload = false,
    int? uploadCount,
    Object? error,
  }) {
    final theme = Theme.of(context);
    final void Function()? onLoadPressed = loading
        ? null
        : () {
            loadRecords();
          };
    if (uploadCount != null && uploadCount > 0) {
      // if records were uploaded
      // trigger a reload of the local data store
      context.read<PatientData>().reloadAll();
    }
    return Container(
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            "HealthKit Connected",
            style: theme.textTheme.headline4,
            softWrap: true,
          ),
          const SizedBox(height: 20),
          Text(
            "HealthKit has been connected and data can now be loaded from it.",
            style: theme.textTheme.bodyMedium,
            softWrap: true,
          ),
          if (uploadCount != null) ...[
            const SizedBox(height: 20),
            Text("Sent $uploadCount records"),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onLoadPressed,
            child: Text(reload ? "Reload Records" : "Load Records"),
          ),
          if (loading) ...[
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                const CircularProgressIndicator(),
                Expanded(
                  child: Text(
                    currentActivity,
                    style: theme.textTheme.bodyMedium,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: 20),
            Text(
              "Error loading records: $error",
              style: theme.textTheme.bodyMedium?.apply(color: theme.errorColor),
              softWrap: true,
            ),
          ],
        ],
      ),
    );
  }
}
