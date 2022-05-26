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

import 'dart:io';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';

enum FhirVersion {
  dstu2,
  r4,
  unknown
}

FhirVersion parseFhirVersion(String version) {
  if (version == "dstu2") {
    return FhirVersion.dstu2;
  } else if (version == "r4") {
    return FhirVersion.r4;
  }
  return FhirVersion.unknown;
}

/// Represents a resource from HealthKit
class HealthKitResource {
  const HealthKitResource({required this.resource, required this.fhirVersion, this.sourceUrl});

  final FhirVersion fhirVersion;
  final Uri? sourceUrl;
  final Map<String, dynamic> resource;

  static HealthKitResource? fromJson(Map<String, dynamic> jsonObject) {
    // Basically make sure the data is there and correct
    var version = FhirVersion.unknown;
    var versionJson = jsonObject['fhirVersion'];
    if (versionJson is String) {
      version = parseFhirVersion(versionJson);
    }
    var sourceUrlJson = jsonObject['sourceUrl'];
    Uri? sourceUrl;
    if (sourceUrlJson is String) {
      try {
        sourceUrl = Uri.parse(sourceUrlJson);
      } on FormatException catch(error, stackTrace) {
        // Log but otherwise ignore
        log("Unparseable URL", level: 800, error: error, stackTrace: stackTrace);
      }
    }
    var resourceJson = jsonObject["resource"];
    // Resource will be a string that needs to be parsed as JSON
    if (resourceJson is String) {
      try {
        final resource = json.decode(resourceJson);
        if (resource is Map<String, dynamic>) {
          return HealthKitResource(fhirVersion: version, sourceUrl: sourceUrl, resource: resource);;
        } else {
          // Log this but otherwise ignore it
          log('Invalid object from FHIR record: expected JSON object, got ${resource.runtimeType}', level: 800);
          return null;
        }
      } on FormatException catch (error, stackTrace) {
        // Log the error but otherwise ignore it
        log('Error parsing FHIR record', level: 800, error: error, stackTrace: stackTrace);
        return null;
      }
    } else if (resourceJson is Map<String, dynamic>) {
      return HealthKitResource(fhirVersion: version, sourceUrl: sourceUrl, resource: resourceJson);
    }
    return null;
  }
}

/// HealthKit interface: provides methods for accessing HealthKit data.
class HealthKit {
  // Channel through which HealthKit requests are sent
  static const platform = MethodChannel('mitre.org/rosie/healthkit');

  HealthKit();

  /// Check if HealthKit is supported on this device. Can only return true on
  /// iOS devices, and specifically iPhones. If this method returns false, then
  /// all other function calls will return null!
  static Future<bool> isHealthDataAvailable() async {
    // Only possibly available on iOS
    if (Platform.isIOS) {
      final available = await platform.invokeMethod("isHealthDataAvailable");
      return available as bool;
    } else {
      return false;
    }
  }

  static Future<bool> supportsHealthRecords() async {
    if (Platform.isIOS) {
      final available = await platform.invokeMethod("supportsHealthRecords");
      return available as bool;
    } else {
      return false;
    }
  }

  /// Attempts to request access to HealthKit data. The exact fields that access is requested to are defined in the iOS
  /// portion of the app, this simply tells the iOS code to invoke them. The returned bool indicates whether this
  /// operation was successful.
  static Future<bool> requestAccess() async {
    return await platform.invokeMethod('requestAccess');
  }

  static Future<List<String>> supportedClinicalTypes() async {
    final supported = await platform.invokeListMethod<String>("supportedClinicalTypes");
    return supported ?? <String>[];
  }

  /// Starts a query on the given set of clinical records. This method is truly asynchronous: it is also asynchronous
  /// on the HealthKit side.
  static Future<List<HealthKitResource>> queryClinicalRecords(String type) async {
    final results = await platform.invokeListMethod<Map<dynamic, dynamic>>("queryClinicalRecords", type);
    if (results == null) {
      // Just return an empty list
      return <HealthKitResource>[];
    }
    return results.map<HealthKitResource?>(
      (e) => HealthKitResource.fromJson(Map<String, dynamic>.from(e))
    ).whereType<HealthKitResource>().toList(growable: false);
  }

  /// Attempts to query all known supported types.
  static Future<List<HealthKitResource>> queryAllClinicalRecords() async {
    final supportedTypes = await supportedClinicalTypes();
    // With the list of types, create futures for each supported type
    final results = await Future.wait(
      supportedTypes.map<Future<List<HealthKitResource>>>(
        (String type) => queryClinicalRecords(type)
      )
    );
    // Results is a list of lists, so flatten it
    return results.expand((e) => e).toList();
  }
}