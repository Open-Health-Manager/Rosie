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

import 'dart:developer';
import 'package:fhir/r4.dart'
    show
        Code,
        CodeableConcept,
        Coding,
        FhirDateTime,
        FhirUri,
        Observation,
        ObservationStatus,
        Reference;
import 'open_health_manager.dart';
import 'util.dart';

/// A condition of a Pregnancy Status.
class PregnancyStatusObservation {
  final bool pregnancyStatus;

  const PregnancyStatusObservation(this.pregnancyStatus);

  /// Attempts to parse a Pregnancy Status condition from a given FHIR condition.
  ///
  /// The coding in the condition itself is **ignored**. This will assume it's a valid coding, and will look for the
  /// pregnancy status value
  factory PregnancyStatusObservation.fromObservation(Observation observation) {
    final observationCodes = observation.valueCodeableConcept?.coding;
    if (observationCodes == null || observationCodes.isEmpty) {
      throw const InvalidResourceException(
          "No observationCodes in pregnancy status observation.");
    }
    bool pregnancyStatus = false;

    var dateTime = observation.effectiveDateTime?.valueDateTime;

    final now = DateTime.now();

    if (dateTime != null) {
      for (final observationCode in observationCodes) {
        final theCode = observationCode.code?.value;

        if (theCode == "77386006") {
          // Pregnant Status Code
          if (now.isAfter(dateTime)) {
            pregnancyStatus = true;
          } else {
            pregnancyStatus = false;
          }
        } else if (theCode == "60001007") {
          // Not Pregnant Status Code
          if (now.isBefore(dateTime)) {
            pregnancyStatus = true;
          } else {
            pregnancyStatus = false;
          }
        }
      }
    }
    return PregnancyStatusObservation(pregnancyStatus);
  }
}

extension PregnancyStatusQuerying on OpenHealthManager {
  /// Loads a list of Pregnancy observations.
  ///
  /// Any exceptions during loading are thrown, and any exceptions during parsing are logged to the FINE (500) log level
  /// but otherwise eaten and simply left out of the result.
  Future<List<PregnancyStatusObservation>> queryPregnancyStatus() async {
    // returns most recent Observations first
    final bundle = await queryResource(
        "Observation", {"code": "http://loinc.org|82810-3", "_sort": "-date"});
    final results = <PregnancyStatusObservation>[];
    var entries = bundle.entry;
    if (entries == null) {
      return results;
    }

    // Get latest entry - first Observation
    var finalEntry = entries.first;

    final resource = finalEntry.resource;
    if (resource != null && resource is Observation) {
      try {
        var pregnancyStatusObservation =
            PregnancyStatusObservation.fromObservation(resource);
        // add to result list
        results.insert(0, pregnancyStatusObservation);
      } on InvalidResourceException catch (error) {
        log('Unable to parse Observation for a Pregnancy Status',
            level: 500, error: error);
      }
    }

    return results;
  }
}
