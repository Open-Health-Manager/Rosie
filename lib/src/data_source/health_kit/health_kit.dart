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

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fhir/r4.dart';
import 'package:flutter/services.dart';
import 'health_kit_resource.dart';
import '../../open_health_manager/open_health_manager.dart';

export 'health_kit_resource.dart';

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
    if (!kIsWeb && Platform.isIOS) {
      final available = await platform.invokeMethod("isHealthDataAvailable");
      return available as bool;
    } else {
      return false;
    }
  }

  /// Determines if health records are supported on this device.
  static Future<bool> supportsHealthRecords() async {
    if (!kIsWeb && Platform.isIOS) {
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
    final supported =
        await platform.invokeListMethod<String>("supportedClinicalTypes");
    return supported ?? <String>[];
  }

  static Future<List<String>> supportedCategoryTypes() async {
    final supported =
        await platform.invokeListMethod<String>("supportedCategoryTypes");
    return supported ?? <String>[];
  }

  static Future<List<String>> supportedCorrelationTypes() async {
    final supported =
        await platform.invokeListMethod<String>("supportedCorrelationTypes");
    return supported ?? <String>[];
  }

  /// Starts a query on the given set of clinical records. This method is truly asynchronous: it is also asynchronous
  /// on the HealthKit side.
  static Future<List<HealthKitResource>> queryClinicalRecords(
      String type) async {
    final results = await platform.invokeListMethod<Map<dynamic, dynamic>>(
        "queryClinicalRecords", type);
    if (results == null) {
      // Just return an empty list
      return <HealthKitResource>[];
    }
    return results
        .map<HealthKitResource?>(
            (e) => HealthKitResource.fromJson(Map<String, dynamic>.from(e)))
        .whereType<HealthKitResource>()
        .toList(growable: false);
  }

  static Future<HealthKitResource?> getPatientCharacteristicData(
      Patient currentPatient) async {
    final results =
        await platform.invokeMapMethod("getPatientCharacteristicData");
    if (results == null) {
      // if no data, return nothing
      return null;
    }
    return HealthKitResource(
        fhirVersion: FhirVersion.r4,
        sourceUrl: Uri.parse("urn:apple:health-kit"),
        resource: getHealthKitPatientFHIRJSON(
            Map<String, dynamic>.from(results), currentPatient));
  }

  /// Attempts to query all known supported types.
  static Future<List<HealthKitResource>> queryAllClinicalRecords(
      OpenHealthManager healthManager) async {
    final supportedTypes = await supportedClinicalTypes();
    // With the list of types, create futures for each supported type
    final results = await Future.wait(
      supportedTypes.map<Future<List<HealthKitResource>>>(
        (String type) => queryClinicalRecords(type),
      ),
    );
    // need current patient to update it with new data from HealthKit
    final currentPatient = await healthManager.queryPatient();
    final patientData = await getPatientCharacteristicData(currentPatient);
    // category types
    final supportedCatTypes = await supportedCategoryTypes();
    // With the list of types, create futures for each supported type
    final categoryResults = await Future.wait(
      supportedCatTypes.map<Future<List<HealthKitResource>>>(
        (String type) => queryCategoryData(type),
      ),
    );

    // correlation types
    final supportedCorTypes = await supportedCorrelationTypes();
    // With the list of types, create futures for each supported type
    final correlationResults = await Future.wait(
      supportedCorTypes.map<Future<List<HealthKitResource>>>(
        (String type) => queryCorrelationData(type),
      ),
    );

    // Results is a list of lists, so flatten it
    final resourceList = results.expand((e) => e).toList();
    if (patientData != null) {
      resourceList.add(patientData);
    }
    final categoryList = categoryResults.expand((e) => e).toList();
    resourceList.addAll(categoryList);

    final correlationList = correlationResults.expand((e) => e).toList();
    resourceList.addAll(correlationList);

    return resourceList;
  }

  // Updates the current FHIR patient record with Health Kit
  // data and returns the JSON representation
  static Map<String, dynamic> getHealthKitPatientFHIRJSON(
      Map<String, dynamic> healthKitCharacteristics, Patient currentPatient) {
    final patientJSON = currentPatient.toJson();

    // clean up JSON metadata and text
    patientJSON.remove("meta");
    patientJSON.remove("text");

    // update gender and birthdate if information provided
    // otherwise, leave existing data
    if (healthKitCharacteristics["gender"] != "") {
      patientJSON["gender"] = healthKitCharacteristics["gender"];
    }
    if (healthKitCharacteristics["dateOfBirth"] != "") {
      patientJSON["birthDate"] = healthKitCharacteristics["dateOfBirth"];
    }

    return patientJSON;
  }

  static Future<List<HealthKitResource>> queryCategoryData(String type) async {
    final results = await platform.invokeListMethod<Map<dynamic, dynamic>>(
        "queryCategoryData", type);
    if (results == null) {
      // Just return an empty list
      return <HealthKitResource>[];
    }

    return results
        .map<HealthKitResource?>((e) => HealthKitResource.fromNonFhirR4(
            Map<String, dynamic>.from(e),
            "urn:apple:health-kit",
            FhirVersion.unknown))
        .whereType<HealthKitResource>()
        .toList(growable: false);
  }

  static Future<List<HealthKitResource>> queryCorrelationData(
      String type) async {
    final results = await platform.invokeListMethod<Map<dynamic, dynamic>>(
        "queryCorrelationData", type);
    if (results == null) {
      // Just return an empty list
      return <HealthKitResource>[];
    }

    return results
        .map<HealthKitResource?>((e) => HealthKitResource.fromNonFhirR4(
            Map<String, dynamic>.from(e),
            "urn:apple:health-kit",
            FhirVersion.unknown))
        .whereType<HealthKitResource>()
        .toList(growable: false);
  }
}
