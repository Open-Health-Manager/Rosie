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

    if (version == FhirVersion.r4) {
      return HealthKitResource(
          fhirVersion: version, sourceUrl: sourceUrl, resource: resource);
    } else if (version == FhirVersion.dstu2) {
      return fromFhirDstu2(resource, sourceUrlJson, version);
    }

    return null;
  }

  static HealthKitResource? fromFhirDstu2(Map<String, dynamic> resourceJson,
      String sourceUrl, FhirVersion version) {
    var blacklist = [
      //can't be handled by DSTU2 to R4 HAPI converter
      'AllergyIntolerance',
      'Immunization',
      'MedicationOrder',
      'MedicationRequest',
      'Procedure'
    ];
    if (blacklist.any((item) =>
        item.toLowerCase() ==
        resourceJson['resourceType'].toString().toLowerCase())) {
      return null;
    }
    return fromNonFhirR4(resourceJson, sourceUrl, version);
  }

  static HealthKitResource? fromNonFhirR4(
      Map<String, dynamic> jsonObject, String sourceUrl, FhirVersion version) {
    Map<String, dynamic> binaryResource = <String, dynamic>{};
    binaryResource["resourceType"] = "Binary";
    if (version == FhirVersion.dstu2) {
      binaryResource["contentType"] = "application/fhir+json";
    } else {
      binaryResource["contentType"] = "application/json";
    }

    final bytes = utf8.encode(jsonEncode(jsonObject));
    final base64Str = base64.encode(bytes);
    binaryResource["data"] = base64Str;
    return HealthKitResource(
        fhirVersion: FhirVersion.r4,
        sourceUrl: Uri.parse(sourceUrl),
        resource: binaryResource);
  }
}
