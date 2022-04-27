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