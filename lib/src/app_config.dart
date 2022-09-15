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
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const defaultFhirBase = "http://localhost:8080/fhir/";

Future<Map<String, dynamic>> _loadConfig(AssetBundle bundle, String path,
    {logMissing = false}) async {
  final String configString;
  try {
    configString = await bundle.loadString(path);
  } catch (error, stackTrace) {
    if (logMissing) {
      log("Unable to load config file $path",
          error: error, stackTrace: stackTrace, level: 900);
    }
    return const <String, dynamic>{};
  }
  try {
    final config = json.decode(configString);
    if (config is Map<String, dynamic>) {
      return config;
    } else {
      log("Invalid JSON object $config parsed from $path, ignoring",
          level: 900);
      return const <String, dynamic>{};
    }
  } catch (error, stackTrace) {
    log("Unable to parse config file $path",
        error: error, stackTrace: stackTrace, level: 900);
    return const <String, dynamic>{};
  }
}

/// Contains app configuration data. Essentially wraps a `Map<String, dynamic>`.
class AppConfig {
  AppConfig(this.config);

  final Map<String, dynamic> config;

  static Future<AppConfig> fromAssetBundle(AssetBundle bundle) async {
    final config = <String, dynamic>{};
    // First, attempt to load the root
    config.addEntries((await _loadConfig(bundle, 'assets/config/config.json',
            logMissing: true))
        .entries);
    if (kIsWeb) {
      // Override with web config if possible
      config.addEntries(
          (await _loadConfig(bundle, 'assets/config/web/config.json')).entries);
    } else {
      if (Platform.isAndroid) {
        // Override with Android config if possible
        config.addEntries(
            (await _loadConfig(bundle, 'assets/config/android/config.json'))
                .entries);
      } else if (Platform.isIOS) {
        // Override with iOS config if possible
        config.addEntries(
            (await _loadConfig(bundle, 'assets/config/ios/config.json'))
                .entries);
      }
    }
    // Then, attempt to load any overrides that may exist
    config.addEntries(
        (await _loadConfig(bundle, 'assets/config/config.local.json')).entries);
    // Use whatever the final config is
    return AppConfig(config);
  }

  dynamic operator [](String key) => config[key];

  /// Gets a string value. This will split the path as via get(String key). If
  /// the value at that path is not a String, this returns null.
  String? getString(String key) {
    final result = get(key);
    return result is String ? result : null;
  }

  /// Gets a given value by a given dot-separated path. For example,
  /// get('foo.bar') is the same as ['foo']['bar'], except with type checks
  /// through the path to ensure that a missing or incompatible value returns
  /// null. See [dig] for details.
  dynamic get(String key) {
    return dig(key.split('.'));
  }

  /// Attempts to dig a value. Returns null if the path does not exist within
  /// the configuration, or there is a non-Map value in the path. Note that
  /// there is no way to determine if a given path exists via this method.
  ///
  /// For example:
  ///
  /// ```
  /// AppConfig({'foo': { 'bar': 42 }}).dig(['foo', 'bar'])
  /// ```
  ///
  /// Will result in 42, while:
  ///
  /// ```
  /// AppConfig({'foo': 42}).dig(['foo', 'bar'])
  /// ```
  ///
  /// Will get `null`.
  dynamic dig(Iterable<String> path) {
    dynamic value = config;
    for (final part in path) {
      if (value is Map<String, dynamic>) {
        // Can continue
        value = value[part];
      } else {
        return null;
      }
    }
    return value;
  }

  /// Determines if the given path exists.
  bool digExists(Iterable<String> path) {
    dynamic value = config;
    for (final part in path) {
      if (value is Map<String, dynamic>) {
        // Can continue
        value = value[part];
      } else {
        return false;
      }
    }
    return true;
  }
}
