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

OpenHealthManager _createDefaultHealthManager() =>
    OpenHealthManager.forServerURL(Uri.parse(defaultServerUrl));

OpenHealthManager _createOpenHealthManager(AppConfig config) {
  try {
    final healthManager = OpenHealthManager.fromConfig(config.config);
    log.config(
        "Successfully loaded configuration, end point is ${healthManager.fhirBase}");
    return healthManager;
  } catch (error, stackTrace) {
    log.severe("Invalid JSON configuration, defaulting to $defaultFhirBase",
        error, stackTrace);
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

  /// Patient data manager. This only exists when logged in and is only
  /// generated when the health manager indicates success.
  PatientData? _patientData;

  @override
  initState() {
    super.initState();
    // Start loading our configuration.
    _loadApp().catchError((error) {
      // Not much can be done with errors here other than to log them
      log.severe("Error while initializing app - things may not work properly!",
          error);
    });
  }

  Future<void> _loadApp() async {
    final appState = AppState();
    final config = await AppConfig.fromAssetBundle(rootBundle);
    final manager = _createOpenHealthManager(config);
    // With the config loaded, attempt to restore the session
    manager.authData =
        await AuthData.readFromSecureStorage(appState.secureStorage);
    // If this worked to restore a session, also create the patient data.
    final patientData = manager.authData == null ? null : PatientData(manager);
    // Also add a listener so that any future changes to AuthData will be stored
    manager.addListener(() {
      // For now, always assume the auth data has changed, and attempt to save it
      final authData = manager.authData;
      if (authData == null) {
        // Delete the auth key. Note that this is async, but not waited on
        appState.secureStorage.delete(key: "auth");
        // Delete the patient manager (if it exists)
        final patientData = _patientData;
        if (patientData != null) {
          setState(() {
            log.info('Disposing of patient data store.');
            patientData.dispose();
            _patientData = null;
          });
        }
      } else {
        // Otherwise, attempt to write the new one
        authData.writeToSecureStorage(appState.secureStorage);
        setState(() {
          log.info('Generating fresh patient data store.');
          _patientData ??= PatientData(manager);
        });
      }
    });
    // Once that's done, set our local values.
    setState(() {
      _config = config;
      _appState = appState;
      _healthManager = manager;
      _patientData = patientData;
    });
  }

  /// Creates the Rosie home part
  Widget _createRosieHome(BuildContext context) {
    final patientData = _patientData;
    if (patientData == null) {
      // Patient data existing is our signal that the account is logged in -
      // it's created only after a successful signin, and then nulled when the
      // session is disposed of.
      // With no patient data, create the Onboarding app without providing
      // the patient data.
      return _createRosieMaterialApp(context, home: const Onboarding());
    } else {
      // The patient data provider has to be kept outside the MaterialApp
      // wrapper, so create it here.
      return ChangeNotifierProvider<PatientData>.value(
        value: patientData,
        child: _createRosieMaterialApp(context, home: const HomeScreen()),
      );
    }
  }

  MaterialApp _createRosieMaterialApp(BuildContext context,
      {required Widget home}) {
    return MaterialApp(
      title: 'Rosie',
      debugShowCheckedModeBanner: false,
      theme: createRosieTheme(),
      darkTheme: createRosieTheme(brightness: Brightness.dark),
      home: home,
    );
  }

  @override
  Widget build(BuildContext context) {
    // This is so the compiler knows it won't change during the build
    final manager = _healthManager;
    if (manager != null) {
      // Otherwise, we have what we need to create providers, which need to be above the MaterialApp to ensure they're
      // accessible on all routes.
      return ChangeNotifierProvider.value(
        value: _appState,
        child: Provider.value(
          value: _config,
          child: ChangeNotifierProvider<OpenHealthManager>.value(
            value: manager,
            child: _createRosieHome(context),
          ),
        ),
      );
    } else {
      // While still loading our config, present a simplified loading screen
      return Container(
        color: Colors.white,
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: Text("Rosie")),
        ),
      );
    }
  }
}
