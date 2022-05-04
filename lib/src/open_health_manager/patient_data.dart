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

// This is a simple model for storing basic patient data. It is specifically
// NOT a FHIR record, it is instead data stored in such a way as to make it
// useful as a Flutter model.

import 'package:flutter/foundation.dart';
import 'open_health_manager.dart';

// A sample indicating blood pressure.
class BloodPressureSample {
  const BloodPressureSample(this.systolic, this.diastolic, [this.taken]);

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
}

class PatientData extends ChangeNotifier {
  PatientData(this.healthManager);

  final OpenHealthManager healthManager;

  BloodPressureSample? _bloodPressure;

  BloodPressureSample? get bloodPressure => _bloodPressure;
  set bloodPressure(BloodPressureSample? newValue) {
    _bloodPressure = newValue;
    notifyListeners();
  }
}