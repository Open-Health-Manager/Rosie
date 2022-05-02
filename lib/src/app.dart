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
import 'rosie_theme.dart';
import 'home.dart';
import 'onboarding/onboarding.dart';

const defaultFhirBase = "http://localhost:8080/fhir/";

OpenHealthManager _createDefaultHealthManager() => OpenHealthManager(fhirBase: Uri.parse(defaultFhirBase));

Future<OpenHealthManager> _createOpenHealthManager(BuildContext context) async {
  // Load our configuration.
  final String configString;
  try {
    configString = await DefaultAssetBundle.of(context).loadString('assets/config/config.json');
  } catch (error, stackTrace) {
    log("Error parsing configuration, defaulting to $defaultFhirBase", error: error, stackTrace: stackTrace, level: 900);
    return _createDefaultHealthManager();
  }
  try {
    final config = json.decode(configString);
    if (config is Map<String, dynamic>) {
      final healthManager = OpenHealthManager.fromConfig(config);
      log("Successfully loaded configuration, end point is ${healthManager.fhirBase}");
      return healthManager;
    } else {
      // level 900 = warning
      log("Invalid configuration object from JSOM, defaulting to $defaultFhirBase", level: 900);
    }
  } catch (error, stackTrace) {
    log("Error parsing configuration, defaulting to $defaultFhirBase", error: error, stackTrace: stackTrace, level: 900);
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
    return model.isSignedIn ? const HomeScreen() : const Onboarding();
  }
}
