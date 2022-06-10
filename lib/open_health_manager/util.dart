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

/// Internal utilities for pulling out fields.

import 'package:fhir/r4.dart' show CodeableConcept, Coding, Quantity;

/// Well known FHIR system URIs.
class Systems {
  /// LOINC
  static const loinc = "http://loinc.org";

  /// Units of Measure
  static const unitsOfMeasure = "http://unitsofmeasure.org";

  /// SNOMED-CT
  static const sct = "http://snomed.info/sct";
}

bool Function(Coding) matchesCodes(Map<String, List<String>> systems) {
  return (Coding coding) {
    final system = coding.system;
    final code = coding.code;
    if (system == null || code == null) {
      // If either are missing, it can't match
      return false;
    }
    final codes = systems[system.toString()];
    if (codes == null) {
      return false;
    }
    return codes.contains(coding.code.toString());
  };
}

/// Attempts to find a Coding that matches the given matcher within the list of codings. The first coding that matches
/// is returned. If none matches, returns null. If the codings list itself is null, this returns null.
Coding? findCoding(List<Coding>? codings, bool Function(Coding) matcher) {
  // To make this API somewhat more forgiving, allow nulls for the input as otherwise they'd always need to be checked.
  if (codings == null) {
    return null;
  }
  for (final code in codings) {
    if (matcher(code)) {
      return code;
    }
  }
  return null;
}

/// Attempts to find a coding within a given CodeableConcept. The first coding that matches is returned. If none can be
/// found, returns null. If the CodeableConcept is null, this returns null.
Coding? findCodingInConcept(CodeableConcept? concept, bool Function(Coding) matcher) {
  if (concept == null) {
    return null;
  }
  return findCoding(concept.coding, matcher);
}

/// A unit within FHIR. This is the combination of a system (which is almost always [Systems.unitsOfMeasure]) and a
/// code that describes a unit within that system.
///
/// This class is merely a descriptor of a unit, it does not include any translations between units.
class Unit {
  const Unit(this.code, { this.system = Systems.unitsOfMeasure });
  final String system;
  final String code;
}

/// Attempts to convert a quantity to a given unit. Note: Does **not** actually function at this point, just makes
/// sure the unit matches and returns it!
double? convertToUnit(Quantity quantity, Unit unit) {
  if (quantity.system.toString() == unit.system && quantity.code?.value == unit.code) {
    return quantity.value?.value;
  } else {
    return null;
  }
}