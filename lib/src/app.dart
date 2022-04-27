import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'open_health_manager/open_health_manager.dart';
import 'open_health_manager/open_health_manager_scope.dart';
import 'auth.dart';
import 'rosie_theme.dart';
import 'home.dart';
import 'onboarding/onboarding.dart';

const defaultFhirBase = "http://localhost:8080/fhir/";

class RosieApp extends StatefulWidget {
  const RosieApp({Key? key}) : super(key: key);

  @override
  _RosieState createState() => _RosieState();
}

class _RosieState extends State<RosieApp> {
  OpenHealthManagerAuth? auth;

  @override
  void initState() {
    super.initState();
    // Can't actually create the health manager yet, since we need to load
    // configuration first.
    rootBundle.loadString('assets/config/config.json').then((configString) {
      OpenHealthManager? healthManager;
      try {
        var config =json.decode(configString);
        if (config is Map<String, dynamic>) {
          healthManager = OpenHealthManager.fromConfig(config);
          log("Successfully loaded configuration, end point is ${healthManager.fhirBase}");
        } else {
          // level 900 = warning
          log("Invalid configuration object from JSOM, defaulting to $defaultFhirBase", level: 900);
        }
      } catch (error, stackTrace) {
        log("Error parsing configuration, defaulting to $defaultFhirBase", error: error, stackTrace: stackTrace, level: 900);
      }
      // No matter what happened above, create it
      _createHealthManagerAuth(healthManager);
    }, onError: (error, stackTrace) {
      log("Unable to load configuration, defaulting to $defaultFhirBase", error: error, stackTrace: stackTrace, level: 900);
      _createHealthManagerAuth(null);
    });
  }

  void _createHealthManagerAuth(OpenHealthManager? healthManager) {
    final hManager = healthManager ?? OpenHealthManager(fhirBase: Uri.parse(defaultFhirBase));
    final managerAuth = OpenHealthManagerAuth(hManager);
    managerAuth.addListener(_handleAuthStateChanged);
    setState(() {
      auth = managerAuth;
    });
  }

  Widget _buildHome() {
    if (auth == null) {
      return const Scaffold(body: Center(child: Text("Rosie")));
    } else {
      return OpenHealthManagerScope(
        manager: auth!.healthManager,
        child: OpenHealthManagerAuthScope(
          notifier: auth!,
          child: auth!.signedIn ? const HomeScreen() : const Onboarding()
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rosie',
      theme: createRosieTheme(),
      darkTheme: createRosieTheme(brightness: Brightness.dark),
      home: _buildHome(),
    );
  }

  void _handleAuthStateChanged() {
    setState(() {
      // nothing to change ourselves, we received notification of a change
    });
  }

  @override
  void dispose() {
    auth?.removeListener(_handleAuthStateChanged);
    super.dispose();
  }
}
