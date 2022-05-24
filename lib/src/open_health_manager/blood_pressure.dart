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
import 'package:fhir/r4.dart' show Code, CodeableConcept, Coding, Decimal,
  FhirUri, Instant, Observation, ObservationComponent, Quantity, Reference;
import 'open_health_manager.dart';
import 'util.dart';

// Known systolic codes by system.
const systolicCoding = <String, List<String>>{
  "http://loinc.org": [
    "8480-6"
  ]
};
// Known diastolic codes by system.
const diastolicCoding = <String, List<String>>{
  "http://loinc.org": [
    "8462-4"
  ]
};

/// An observation of a blood pressure reading.
class BloodPressureObservation {
  const BloodPressureObservation(this.systolic, this.diastolic, [this.taken]);

  /// Attempts to parse a blood pressure observation from a given FHIR observation.
  ///
  /// The coding in the observation itself is **ignored**. This will assume it's a valid coding, and will look for the
  /// systolic and diastolic values in the Observation's components.
  factory BloodPressureObservation.fromObservation(Observation observation) {
    final components = observation.component;
    if (components == null || components.isEmpty) {
      throw const InvalidResourceException("No components in observation.");
    }
    const mmHg = Unit("mm[Hg]");
    double? systolic;
    double? diastolic;
    for (final component in components) {
      final quantity = component.valueQuantity;
      if (quantity == null) {
        // Can't do anything without a quantity.
        continue;
      }
      if (findCodingInConcept(component.code, matchesCodes(systolicCoding)) != null) {
        // This component is a systolic value.
        systolic = convertToUnit(quantity, mmHg);
      }
      if (findCodingInConcept(component.code, matchesCodes(diastolicCoding)) != null) {
        // This component is a diastolic value.
        diastolic = convertToUnit(quantity, mmHg);
      }
    }
    if (systolic != null && diastolic != null) {
      return BloodPressureObservation(systolic, diastolic, observation.effectiveDateTime?.value);
    } else {
      throw const InvalidResourceException("Could not locate a valid blood pressure within given Observation");
    }
  }

  final double systolic;
  final double diastolic;
  final DateTime? taken;

  // Determine if this sample is "outdated" - currently defined to be "more than
  // a year out of date." If the taken time is unknown, this is always assumed
  // to be out of date.
  bool isOutdated([DateTime? now]) {
    final DateTime? takenAt = taken;
    if (takenAt == null) {
      return true;
    }
    DateTime compareTo = now ?? DateTime.now();
    // FIXME: Decide if this is correct for leap years. It's probably fine.
    compareTo = compareTo.subtract(const Duration(days: 365));
    return takenAt.isBefore(compareTo);
  }

  /// Generates a FHIR Observation record for this blood pressure record.
  Observation generateObservation(Reference? subject) {
    final issued = taken;
    return Observation(
      code: CodeableConcept(
        coding: <Coding>[
          Coding(system: FhirUri(Systems.loinc), code: Code('55284-4'))
        ]
      ),
      issued: issued == null ? null : Instant.fromDateTime(issued),
      component: <ObservationComponent>[
        ObservationComponent(
          code: CodeableConcept(
            text: 'Systolic blood pressure',
            coding: <Coding>[
              Coding(
                display: 'Systolic blood pressure',
                system: FhirUri(Systems.loinc),
                code: Code("8480-6")
              )
            ]
          ),
          valueQuantity: Quantity(
            system: FhirUri(Systems.unitsOfMeasure),
            code: Code('mm[Hg]'),
            unit: 'mm[Hg]',
            value: Decimal(systolic)
          )
        ),
        ObservationComponent(
          code: CodeableConcept(
            text: 'Diastolic blood pressure',
            coding: <Coding>[
              Coding(
                display: 'Diastolic blood pressure',
                system: FhirUri(Systems.loinc),
                code: Code("8462-4")
              )
            ]
          ),
          valueQuantity: Quantity(
            system: FhirUri(Systems.unitsOfMeasure),
            code: Code('mm[Hg]'),
            unit: 'mm[Hg]',
            value: Decimal(diastolic)
          )
        )
      ],
      subject: subject
    );
  }
}

extension BloodPressureQuerying on OpenHealthManager {
  /// Loads a list of blood pressure observations.
  ///
  /// Any exceptions during loading are thrown, and any exceptions during parsing are logged to the FINE (500) log level
  /// but otherwise eaten and simply left out of the result.
  Future<List<BloodPressureObservation>> queryBloodPressure() async {
    final bundle = await queryResource("Observation", {
      "code": "http://loinc.org|55284-4"
    });
    final results = <BloodPressureObservation>[];
    final entries = bundle.entry;
    if (entries == null) {
      return results;
    }
    for (final entry in entries) {
      final resource = entry.resource;
      if (resource != null && resource is Observation) {
        try {
          results.add(BloodPressureObservation.fromObservation(resource));
        } on InvalidResourceException catch(error) {
          log('Unable to parse Observation into blood pressure', level: 500, error: error);
        }
      }
    }
    return results;
  }

  /// Attempts to post the given blood pressure observation back to the Open Health Manager.
  Future<void> postBloodPressure(BloodPressureObservation observation) async {
    postResource(observation.generateObservation(createPatientReference()));
  }
}