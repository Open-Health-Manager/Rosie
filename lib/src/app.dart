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

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app_config.dart';
import 'home.dart';
import '../open_health_manager/open_health_manager.dart';
import '../open_health_manager/patient_data.dart';
import 'rosie_theme.dart';
import 'onboarding/onboarding.dart';

const defaultFhirBase = "http://localhost:8080/fhir/";

OpenHealthManager _createDefaultHealthManager() => OpenHealthManager(fhirBase: Uri.parse(defaultFhirBase));

OpenHealthManager _createOpenHealthManager(AppConfig config) {
  try {
    final healthManager = OpenHealthManager.fromConfig(config.config);
    log("Successfully loaded configuration, end point is ${healthManager.fhirBase}");
    return healthManager;
  } catch (error, stackTrace) {
    log("Invalid JSON configuration, defaulting to $defaultFhirBase", error: error, stackTrace: stackTrace, level: 900);
  }
  return _createDefaultHealthManager();
}
class RosieApp extends StatefulWidget {
  const RosieApp({Key? key}) : super(key: key);

  @override
  State createState() => _RosieAppState();
}

class _RosieAppState extends State<RosieApp> {
  /// Application configuration data
  AppConfig? _config;
  /// The health manager - provides API access.
  OpenHealthManager? _healthManager;
  /// Patient data manager.
  PatientData? _patientData;

  @override
  initState() {
    super.initState();
    // Start loading our configuration.
    AppConfig.fromAssetBundle(rootBundle).then((config) {
      setState(() {
        _config = config;
        // Next attempt to create the rest
        final manager = _createOpenHealthManager(config);
        _healthManager = manager;
        _patientData = PatientData(manager);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This is so the compiler knows it won't change during the build
    final manager = _healthManager;
    final patientData = _patientData;
    if (manager != null && patientData != null) {
      // Otherwise, we have what we need to create providers, which need to be above the MaterialApp to ensure they're
      // accessible on all routes.
      return Provider.value(
        value: _config,
        child: ChangeNotifierProvider<OpenHealthManager>.value(
          value: manager,
          child: ChangeNotifierProvider<PatientData>.value(
            value: patientData,
            child: MaterialApp(
              title: 'Rosie',
              theme: createRosieTheme(),
              darkTheme: createRosieTheme(brightness: Brightness.dark),
              home: const _RosieHome()
            )
          )
        )
      );
    } else {
      // While still loading our config, present a simplified loading screen
      return Container(
        color: Colors.white,
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: Text("Rosie"))
        )
      );
    }
  }
}

class _RosieHome extends StatelessWidget {
  const _RosieHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<OpenHealthManager>();
    if (model.isSignedIn) {
      return const HomeScreen();
    } else {
      return const Onboarding();
    }
  }
}
