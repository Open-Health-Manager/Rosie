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
        Decimal,
        FhirDateTime,
        FhirUri,
        Instant,
        Observation,
        ObservationComponent,
        ObservationStatus,
        Quantity,
        Reference;
import 'open_health_manager.dart';
import 'util.dart';

enum SmokingStatus { unknown, neverSmoked, formerSmoker, currentSmoker }

extension ToSnomed on SmokingStatus {
  Coding toSnomedCoding() {
    switch (this) {
      case SmokingStatus.unknown:
        return Coding(
            system: FhirUri(Systems.sct),
            code: Code('266927001'),
            display: "Tobacco smoking consumption unknown (finding)");
      case SmokingStatus.neverSmoked:
        return Coding(
            system: FhirUri(Systems.sct),
            code: Code('266919005'),
            display: "Never smoked tobacco (finding)");
      case SmokingStatus.formerSmoker:
        return Coding(
            system: FhirUri(Systems.sct),
            code: Code('8517006'),
            display: "Ex-smoker (finding)");
      case SmokingStatus.currentSmoker:
        return Coding(
            system: FhirUri(Systems.sct),
            code: Code('77176002'),
            display: "Smoker (finding)");
    }
  }
}

/// An observation of a Smoking Status.
class SmokingStatusObservation {
  final SmokingStatus smokingStatus;

  const SmokingStatusObservation(this.smokingStatus);

  /// Attempts to parse a Smoking Status observation from a given FHIR observation.
  ///
  /// The coding in the observation itself is **ignored**. This will assume it's a valid coding, and will look for the
  /// smoking status value
  factory SmokingStatusObservation.fromObservation(Observation observation) {
    final valueCodes = observation.valueCodeableConcept?.coding;
    if (valueCodes == null || valueCodes.isEmpty) {
      throw const InvalidResourceException(
          "No valueCodes in smoking status observation.");
    }
    SmokingStatus smokingStatus = SmokingStatus.unknown;
    for (final aValueCode in valueCodes) {
      final theCode = aValueCode.code?.value;
      if (theCode == "266919005") {
        // Never smoked tobacco (finding)
        smokingStatus = SmokingStatus.neverSmoked;
      } else if (theCode == "266927001") {
        // Tobacco smoking consumption unknown (finding)
        smokingStatus = SmokingStatus.unknown;
      } else if (theCode == "428041000124106") {
        // Occasional tobacco smoker (finding)
        smokingStatus = SmokingStatus.currentSmoker;
      } else if (theCode == "428061000124105") {
        // Light tobacco smoker (finding)
        smokingStatus = SmokingStatus.currentSmoker;
      } else if (theCode == "428071000124103") {
        // Heavy tobacco smoker (finding)
        smokingStatus = SmokingStatus.currentSmoker;
      } else if (theCode == "449868002") {
        // Smokes tobacco daily (finding)
        smokingStatus = SmokingStatus.currentSmoker;
      } else if (theCode == "77176002") {
        // Smoker (finding)
        smokingStatus = SmokingStatus.currentSmoker;
      } else if (theCode == "8517006") {
        // Ex-smoker (finding)
        smokingStatus = SmokingStatus.formerSmoker;
      }
    }

    return SmokingStatusObservation(smokingStatus);
  }

  /// Generates a FHIR Observation record for this smoking status record.
  Observation generateObservation(Reference? subject) {
    final effectiveDateTime = DateTime.now();

    return Observation(
        code: CodeableConcept(coding: <Coding>[
          Coding(
              system: FhirUri(Systems.loinc),
              code: Code('72166-2'),
              display: "Tobacco smoking status")
        ]),
        effectiveDateTime: (effectiveDateTime == null)
            ? null
            : FhirDateTime.fromDateTime(effectiveDateTime),
        valueCodeableConcept:
            CodeableConcept(coding: <Coding>[smokingStatus.toSnomedCoding()]),
        subject: subject,
        status: ObservationStatus.final_,
        category: [
          CodeableConcept(coding: <Coding>[
            Coding(
                system: FhirUri(
                    "http://terminology.hl7.org/CodeSystem/observation-category"),
                code: Code('social-history'),
                display: "Social History")
          ])
        ]);
  }
}

extension SmokingStatusQuerying on OpenHealthManager {
  /// Loads a list of Smoking observations.
  ///
  /// Any exceptions during loading are thrown, and any exceptions during parsing are logged to the FINE (500) log level
  /// but otherwise eaten and simply left out of the result.
  Future<List<SmokingStatusObservation>> querySmokingStatus() async {
    // return most recent ones first
    final bundle = await queryResource(
        "Observation", {"code": "http://loinc.org|72166-2", "_sort": "-date"});
    final results = <SmokingStatusObservation>[];
    final entries = bundle.entry;
    if (entries == null) {
      return results;
    }
    for (final entry in entries) {
      final resource = entry.resource;
      if (resource != null && resource is Observation) {
        try {
          // add to front so that most recent entries are last in the list
          results.insert(0, SmokingStatusObservation.fromObservation(resource));
        } on InvalidResourceException catch (error) {
          log('Unable to parse Observation for a Smoking Status',
              level: 500, error: error);
        }
      }
    }
    return results;
  }

  /// Attempts to post the given smoking status observation back to the Open Health Manager.
  Future<void> postSmokingStatus(SmokingStatusObservation observation,
      {bool addToBatch = false}) async {
    Observation fhirResource =
        observation.generateObservation(createPatientReference());
    if (addToBatch) {
      transactionManager.addEntryToUpdateBatch(fhirResource);
    } else {
      postResource(fhirResource);
    }
  }
}
