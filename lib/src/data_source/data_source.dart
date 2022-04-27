

// Class that handles accessing data sources
import 'package:flutter/material.dart';
import "health_kit_data_source.dart";

// Attempts to determine which data sources are available. Provides a stream of DataSource objects that may nor may
// not be available on this platform.
Stream<DataSource> lookUpDataSources() {
  // This function may eventually become async later when a "proper" method for hooking into data sources is provided.
  // For now it's static.
  final availableSources = [ HealthKitDataSource() ];
  return Stream.fromIterable(availableSources);
}

// Base class of data sources
abstract class DataSource {
  DataSource(this.name, { this.description = "" });

  // The name for the data source
  final String name;
  // The description for the data source.
  final String description;

  // Determine if this data source is available on this platform. This is asynchronous because some data sources have to
  // do data lookups. The default implementation immediately returns true.
  Future<bool> isAvailable() async {
    return true;
  }

  // Determine if this data source is actively connected.
  Future<bool> isConnected() async {
    return false;
  }

  // Generate an icon to represent the source. Any widget may be used.
  // If this returns null, then the data source list won't have an icon for that
  // data source. The default returns null.
  Widget? createIcon(BuildContext context) {
    return null;
  }

  // Build the connection screen for this data source.
  Widget createConnectionScreen(BuildContext context);
}