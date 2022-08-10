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
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'app_config.dart';
import 'app_state.dart';
import 'home.dart';
import 'onboarding/onboarding.dart';
import 'open_health_manager/open_health_manager.dart';
import 'open_health_manager/patient_data.dart';
import 'rosie_theme.dart';

const defaultServerUrl = "http://localhost:8080/";

final log = Logger('Rosie');

OpenHealthManager _createDefaultHealthManager() => OpenHealthManager.forServerURL(Uri.parse(defaultServerUrl));

OpenHealthManager _createOpenHealthManager(AppConfig config) {
  try {
    final healthManager = OpenHealthManager.fromConfig(config.config);
    log.config("Successfully loaded configuration, end point is ${healthManager.fhirBase}");
    return healthManager;
  } catch (error, stackTrace) {
    log.severe("Invalid JSON configuration, defaulting to $defaultFhirBase", error, stackTrace);
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
  /// Application state.
  AppState? _appState;
  /// The health manager - provides API access.
  OpenHealthManager? _healthManager;
  /// Patient data manager.
  PatientData? _patientData;

  @override
  initState() {
    super.initState();
    // Start loading our configuration.
    _loadApp().catchError((error) {
      // Not much can be done with errors here other than to log them
      log.severe("Error while initializing app - things may not work properly!", error);
    });
  }

  Future<void> _loadApp() async {
    final appState = AppState();
    final config = await AppConfig.fromAssetBundle(rootBundle);
    final manager = _createOpenHealthManager(config);
    // With the config loaded, attempt to restore the session
    manager.authData = await AuthData.readFromSecureStorage(appState.secureStorage);
    // Also add a listener so that any future changes to AuthData will be stored
    manager.addListener(() {
      // For now, always assume the auth data has changed, and attempt to save it
      final authData = manager.authData;
      if (authData == null) {
        // Delete the auth key. Note that this is async.
        appState.secureStorage.delete(key: "auth");
      } else {
        // Otherwise, attempt to write the new one
        authData.writeToSecureStorage(appState.secureStorage);
      }
    });
    // Once that's done, set our local values.
    setState(() {
      _config = config;
      _appState = appState;
      _healthManager = manager;
      _patientData = PatientData(manager);
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
      return ChangeNotifierProvider.value(
        value: _appState,
        child: Provider.value(
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
