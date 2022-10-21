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
import 'package:fhir/r4/resource_types/clinical/summary/summary.dart';
import 'open_health_manager.dart';

/// A condition of a Pregnancy Status.
class PregnancyStatusCondition {
  final bool pregnancyStatus;

  const PregnancyStatusCondition(this.pregnancyStatus);

  /// Attempts to parse a Pregnancy Status condition from a given FHIR condition.
  ///
  /// The coding in the condition itself is **ignored**. This will assume it's a valid coding, and will look for the
  /// pregnancy status value
  factory PregnancyStatusCondition.fromCondition(Condition condition) {
    final conditionCodes = condition.code?.coding;
    if (conditionCodes == null || conditionCodes.isEmpty) {
      throw const InvalidResourceException(
          "No conditionCodes in pregnancy status condition.");
    }
    bool pregnancyStatus = false;

    var period = condition.onsetPeriod;
    var startDate = period?.start?.valueDateTime;
    var endDate = period?.end?.valueDateTime;

    final now = DateTime.now();

    if (startDate != null) {
      for (final conditionCode in conditionCodes) {
        final theCode = conditionCode.code?.value;

        if (theCode == "77386006") {
          if (now.isAfter(startDate) &&
              (endDate == null || now.isBefore(endDate))) {
            pregnancyStatus = true;
          } else {
            pregnancyStatus = false;
          }
        }
      }
    }

    return PregnancyStatusCondition(pregnancyStatus);
  }
}

extension PregnancyStatusQuerying on OpenHealthManager {
  /// Loads a list of Pregnancy conditions.
  ///
  /// Any exceptions during loading are thrown, and any exceptions during parsing are logged to the FINE (500) log level
  /// but otherwise eaten and simply left out of the result.
  Future<List<PregnancyStatusCondition>> queryPregnancyStatus() async {
    // return most recent ones first
    final bundle = await queryResource("Condition",
        {"code": "http://snomed.info/sct|77386006", "_sort": "-onset-date"});
    final results = <PregnancyStatusCondition>[];
    final entries = bundle.entry;
    if (entries == null) {
      return results;
    }
    for (final entry in entries) {
      final resource = entry.resource;
      if (resource != null && resource is Condition) {
        try {
          // add to front so that most recent entries are last in the list
          results.insert(0, PregnancyStatusCondition.fromCondition(resource));
        } on InvalidResourceException catch (error) {
          log('Unable to parse Condition for a Pregnancy Status',
              level: 500, error: error);
        }
      }
    }
    return results;
  }
}
