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

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'open_health_manager/open_health_manager.dart';
import 'open_health_manager/patient_data.dart';
import 'rosie_theme.dart';
import 'home.dart';
import 'onboarding/onboarding.dart';

const defaultFhirBase = "http://localhost:8080/fhir/";

OpenHealthManager _createDefaultHealthManager() => OpenHealthManager(fhirBase: Uri.parse(defaultFhirBase));

Future<Map<String, dynamic>> _loadConfig(AssetBundle bundle, String path, { logMissing = false }) async {
  final String configString;
  try {
    configString = await bundle.loadString(path);
  } catch (error, stackTrace) {
    if (logMissing) {
      log("Unable to load config file $path", error: error, stackTrace: stackTrace, level: 900);
    }
    return const <String, dynamic>{};
  }
  try {
    final config = json.decode(configString);
    if (config is Map<String, dynamic>) {
      return config;
    } else {
      log("Invalid JSON object $config parsed from $path, ignoring", level: 900);
      return const <String, dynamic>{};
    }
  } catch (error, stackTrace) {
    log("Unable to parse config file $path", error: error, stackTrace: stackTrace, level: 900);
    return const <String, dynamic>{};
  }
}

Future<OpenHealthManager> _createOpenHealthManager(BuildContext context) async {
  final bundle = DefaultAssetBundle.of(context);
  final config = <String, dynamic>{};
  // First, attempt to load the root
  config.addEntries((await _loadConfig(bundle, 'assets/config/config.json', logMissing: true)).entries);
  // Then, attempt to load any overrides that may exist
  config.addEntries((await _loadConfig(bundle, 'assets/config/config.local.json')).entries);
  // Next, attempt to use this configuration
  try {
    final healthManager = OpenHealthManager.fromConfig(config);
    log("Successfully loaded configuration, end point is ${healthManager.fhirBase}");
    return healthManager;
  } catch (error, stackTrace) {
    log("Invalid JSON configuration, defaulting to $defaultFhirBase", error: error, stackTrace: stackTrace, level: 900);
  }
  return _createDefaultHealthManager();
}
class RosieApp extends StatelessWidget {
  const RosieApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rosie',
      theme: createRosieTheme(),
      darkTheme: createRosieTheme(brightness: Brightness.dark),
      home: FutureProvider<OpenHealthManager?>(
        create: _createOpenHealthManager,
        initialData: null,
        child: const _RosieLoadingScreen()
      )
    );
  }
}

class _RosieLoadingScreen extends StatelessWidget {
  const _RosieLoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<OpenHealthManager?>();
    if (model == null) {
      return const Scaffold(
        body: Center(child: Text("Rosie"))
      );
    } else {
      return ChangeNotifierProvider<OpenHealthManager>.value(value: model, child: const _RosieHome());
    }
  }
}

class _RosieHome extends StatelessWidget {
  const _RosieHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<OpenHealthManager>();
    if (model.isSignedIn) {
      return ChangeNotifierProvider<PatientData>(
        create: (_) {
          final data = PatientData(model);
          // For now, initialize blood pressure to a known value
          data.bloodPressure = BloodPressureSample(118, 76, DateTime(2017, 10, 17, 10, 32));
          return data;
        },
        child: const HomeScreen()
      );
    } else {
      return const Onboarding();
    }
  }
}
