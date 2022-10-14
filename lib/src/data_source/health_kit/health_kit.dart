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

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fhir/r4.dart';
import 'package:flutter/services.dart';
import '../../open_health_manager/open_health_manager.dart';

enum FhirVersion {
  dstu2,
  r4,
  unknown,
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
  const HealthKitResource({
    required this.resource,
    required this.fhirVersion,
    this.sourceUrl,
  });

  /// The (string form) of URNs used for HealthKit
  static const healthKitUrnString = 'urn:apple:health-kit';

  /// Creates a [Uri] representing the URN used for HealthKit resources
  static get healthKitUri => Uri.parse(healthKitUrnString);

  /// FHIR version of the resource
  final FhirVersion fhirVersion;

  /// Source URL of the resource
  final Uri? sourceUrl;

  /// The actual JSON data of the resource, if available
  final Map<String, dynamic> resource;

  /// Attempts to parse the HealthKitResource *as sent from the Swift backend* -
  /// this is *not* expecting a FHIR resource!
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
      } on FormatException catch (error, stackTrace) {
        // Log but otherwise ignore
        log(
          "Unparseable URL",
          level: 800,
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    var resourceJson = jsonObject["resource"];
    // Resource will be a string that needs to be parsed as JSON
    Map<String, dynamic> resource;
    if (resourceJson is String) {
      try {
        resource = json.decode(resourceJson);
      } on FormatException catch (error, stackTrace) {
        // Log the error but otherwise ignore it
        log(
          'Error parsing FHIR record',
          level: 800,
          error: error,
          stackTrace: stackTrace,
        );
        return null;
      }
    } else if (resourceJson is Map<String, dynamic>) {
      resource = resourceJson;
    } else {
      // Log this but otherwise ignore it
      log(
        'Invalid object from FHIR record: expected JSON object, got ${resourceJson.runtimeType}',
        level: 800,
      );
      return null;
    }

    return HealthKitResource(
      fhirVersion: version,
      sourceUrl: sourceUrl,
      resource: resource,
    );
  }

  /// If this is not a FHIR R4 resource, creates a representation of it as if it
  /// where one. This does not do any conversion, instead, it wraps the existing
  /// resource within a FHIR R4 Binary resource.
  Map<String, dynamic> asFhirR4Resource() {
    if (fhirVersion == FhirVersion.r4) {
      return resource;
    }
    return <String, dynamic>{
      "resourceType": "Binary",
      "contentType": fhirVersion == FhirVersion.dstu2
          ? "application/fhir+json"
          : "application/json",
      "data": base64.encode(utf8.encode(json.encode(resource))),
    };
  }
}

/// Represents a HealthKitSample - something that likely can't be represented as
/// FHIR but may have embedded data that can be used.
class HealthKitSample extends HealthKitResource {
  HealthKitSample({
    required this.uuid,
    required this.sampleType,
    required this.fields,
    required super.resource,
    required super.fhirVersion,
    super.sourceUrl,
  });

  /// HealthKit UUID of the sample (required)
  final String uuid;
  /// HealthKit sample type (required)
  final String sampleType;
  /// Sample-specific fields.
  final Map<String, dynamic> fields;

  static HealthKitSample? fromJson(
      Map<String, dynamic> jsonObject, Uri? sourceUrl) {
    final uuid = jsonObject["uuid"];
    final sampleType = jsonObject["sampleType"];
    if (uuid is String &&
        sampleType is String) {
      return HealthKitSample(
        uuid: uuid,
        sampleType: sampleType,
        fields: jsonObject,
        resource: <String, dynamic>{
          "resourceType": "Binary",
          "contentType": "application/json",
          "data": base64.encode(utf8.encode(json.encode(jsonObject)))
        },
        fhirVersion: FhirVersion.r4,
        sourceUrl: sourceUrl,
      );
    } else {
      return null;
    }
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
          Map<String, dynamic>.from(results), currentPatient),
    );
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

  static Future<List<HealthKitSample>> queryCategoryData(String type) async {
    final results = await platform.invokeListMethod<Map<dynamic, dynamic>>(
        "queryCategoryData", type);
    if (results == null) {
      // Just return an empty list
      return <HealthKitSample>[];
    }
    final healthKitUri = HealthKitResource.healthKitUri;
    return results
        .map<HealthKitSample?>((e) => HealthKitSample.fromJson(
            Map<String, dynamic>.from(e), healthKitUri))
        .whereType<HealthKitSample>()
        .toList(growable: false);
  }

  static Future<List<HealthKitSample>> queryCorrelationData(String type) async {
    final results = await platform.invokeListMethod<Map<dynamic, dynamic>>(
        "queryCorrelationData", type);
    if (results == null) {
      // Just return an empty list
      return <HealthKitSample>[];
    }
    final healthKitUri = HealthKitResource.healthKitUri;
    return results
        .map<HealthKitSample?>((e) => HealthKitSample.fromJson(
            Map<String, dynamic>.from(e), healthKitUri))
        .whereType<HealthKitSample>()
        .toList(growable: false);
  }
}
