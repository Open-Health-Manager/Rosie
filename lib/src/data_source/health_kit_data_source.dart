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

import "data_source.dart";

class HealthKitDataSource extends DataSource {
  HealthKitDataSource() : super("Apple HealthKit", description: "Health data and clinical records stored within your local HealthKit profile.");

  @override
  Widget createConnectionScreen(BuildContext context) {
    return const _HealthKitConnectionScreen();
  }

  @override
  Widget? createIcon(BuildContext context) {
    // TODO: Pull HealthKit icon
    return null;
  }

}

class _HealthKitConnectionScreen extends StatefulWidget {
  const _HealthKitConnectionScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HealthKitConnectionScreenState();
}

class _HealthKitConnectionScreenState extends State<_HealthKitConnectionScreen> {
  @override
  Widget build(BuildContext context) {
    return const Text("Hello");
  }
}