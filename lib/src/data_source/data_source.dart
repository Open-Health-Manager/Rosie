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