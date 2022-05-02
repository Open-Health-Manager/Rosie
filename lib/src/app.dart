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
