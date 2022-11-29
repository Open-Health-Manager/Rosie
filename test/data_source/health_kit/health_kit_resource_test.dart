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
import 'package:flutter_test/flutter_test.dart';
import 'package:rosie/src/data_source/health_kit/health_kit_resource.dart';

/// Perform the encoding expected to happen
String encodeBase64(Map<String, dynamic> jsonObject) {
  return base64.encode(utf8.encode(json.encode(jsonObject)));
}

const healthKitUrn = 'urn:apple:health-kit';

void main() {
  final healthKitUri = Uri.parse(healthKitUrn);
  group('fromNonFhirR4', () {
    // This is based on a sample HKQuantitySample
    final quantitySampleJson = <String, dynamic>{
      "uuid": "6FD4961E-AA98-4747-8AC9-38095BA3259B",
      "value": "notApplicable",
      "endDate": "4000-12-31",
      "startDate": "2022-10-04",
      "sampleType": "HKCategoryTypeIdentifierPregnancy",
    };
    final quantitySampleBase64 =
        encodeBase64(quantitySampleJson);
    // This is based on a sample HKCategorySample
    final bloodPressureSampleJson = <String, dynamic>{
      "uuid": "50BCE4F4-CAF4-413B-A6B4-64CD38744151",
      "sampleType": "HKCorrelationTypeIdentifierBloodPressure",
      "diastolicValue": "80.000000",
      "systolicValue": "120.000000",
      "effectiveDate": "2022-10-14",
    };
    final bloodPressureSampleBase64 = encodeBase64(bloodPressureSampleJson);
    test('converts data from HealthKit', () {
      final actual = HealthKitResource.fromNonFhirR4(
          quantitySampleJson, healthKitUrn, FhirVersion.unknown);
      // Do test check to properly flag failure
      expect(actual, isNotNull);
      // And then "real" check to satisfy compiler-time checks
      if (actual != null) {
        expect(actual.fhirVersion, equals(FhirVersion.r4));
        expect(
          actual.resource,
          equals(
            <String, dynamic>{
              'resourceType': 'Binary',
              'contentType': 'application/json',
              // Checking the data relies on the JSON value being stable, which it
              // should be.
              'data': equals(quantitySampleBase64),
            },
          ),
        );
        expect(actual.sourceUrl, equals(healthKitUri));
      }
    });

    test('converts data to FHIR DSTU2', () {
      final actual = HealthKitResource.fromNonFhirR4(
          quantitySampleJson, healthKitUrn, FhirVersion.dstu2);
      // Do test check to properly flag failure
      expect(actual, isNotNull);
      // And then "real" check to satisfy compiler-time checks
      if (actual != null) {
        // Yes, it's still R4 in the generated version, unclear why
        expect(actual.fhirVersion, equals(FhirVersion.r4));
        expect(
          actual.resource,
          equals(
            <String, dynamic>{
              'resourceType': 'Binary',
              'contentType': 'application/fhir+json',
              // Checking the data relies on the JSON value being stable, which it
              // should be.
              'data': equals(quantitySampleBase64),
            },
          ),
        );
        expect(actual.sourceUrl, equals(healthKitUri));
      }
    });

    test('converts blood pressure', () {
      final actual = HealthKitResource.fromNonFhirR4(bloodPressureSampleJson, healthKitUrn, FhirVersion.r4);
      expect(actual, isNotNull);
      if (actual != null) {
        expect(actual.fhirVersion, equals(FhirVersion.r4));
        expect(
          actual.resource,
          equals(
            <String, dynamic>{
              'resourceType': 'Binary',
              'contentType': 'application/json',
              // Checking the data relies on the JSON value being stable, which it
              // should be.
              'data': equals(bloodPressureSampleBase64),
            },
          ),
        );
        expect(actual.sourceUrl, equals(healthKitUri));
      }
    });
  });
}
