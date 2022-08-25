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
import 'blood_pressure.dart';
import 'smoking_status.dart';
import 'patient_demographics.dart';

/// The load state of a piece of data
enum LoadState {
  /// No data has been loaded
  unloaded,

  /// Data is presently being loaded
  loading,

  /// Loading has finished successfully
  done,

  /// Loading has finished but with an error that prevented a value from being loaded
  error
}

/// Some data that can be fetched and is then cached until reloaded.
class CachedData<T> {
  CachedData(this.fetch, [T? initialValue]) : _value = initialValue;

  final Future<T> Function() fetch;
  // Cached value
  T? _value;
  // Current state
  var _state = LoadState.unloaded;
  // Active Future (if any)
  Future<T>? _future;
  // If non-null, an error has happened
  dynamic _error;

  /// The current loading state.
  LoadState get state => _state;

  /// Gets the current value, or null if it isn't loaded. This will never trigger a load. Use get() to do that.
  T? get value => _value;

  /// Attempts to get the value. Returns a [Future] that completes based on the value. If done or error, this always
  /// returns a Future that completes immediately (via [Future.value] or [Future.error]). If loading, returns the
  Future<T> get() {
    switch (_state) {
      case LoadState.unloaded:
        // Start the load:
        final future = fetch();
        // Assign our handlers
        future.then((value) {
          _value = value;
          _state = LoadState.done;
          _future = null;
        }).catchError((error) {
          _error = error;
          _state = LoadState.error;
          _future = null;
        });
        _future = future;
        return future;
      case LoadState.loading:
        // Return the existing future:
        // (It not existing in this case is an error)
        return _future!;
      case LoadState.done:
        return Future.value(_value);
      case LoadState.error:
        return Future.error(_error);
    }
  }

  /// Forcibly overrides the given value to the specified value. This will move the state into done.
  ///
  /// Note that if the load state is currently loading, the eventual completion will *override* this value!
  void set(T value) {
    _state = LoadState.done;
    _value = value;
    _error = null;
  }

  /// Reload, clearing the current result by resetting the state to unloaded and invoking [get].
  Future<T> reload() {
    _state = LoadState.unloaded;
    _value = null;
    _error = null;
    return get();
  }
}

/// The PatientData class provides access to patient data stored within the backend. Patient data is loaded via the
/// OpenHealthManager instance given.
class PatientData extends ChangeNotifier {
  PatientData(this.healthManager);

  final OpenHealthManager healthManager;

  late final patientDemographics = CachedData<PatientDemographics?>(() async {
    return await healthManager.queryPatientDemographics();
  });
  late final bloodPressure =
      CachedData<List<BloodPressureObservation>>(() async {
    return await healthManager.queryBloodPressure();
  });
  late final smokingStatus =
      CachedData<List<SmokingStatusObservation>>(() async {
    return await healthManager.querySmokingStatus();
  });

  void reloadAll() {
    patientDemographics.reload();
    bloodPressure.reload();
    smokingStatus.reload();
  }

  /// Adds a blood pressure observation to the current data (even if it hasn't been loaded yet) and then attempts to
  /// write it to the backend.
  Future<void> addBloodPressureObservation(BloodPressureObservation obs,
      {bool inBatch = false}) async {
    final List<BloodPressureObservation>? bps = bloodPressure.value;
    if (bps == null) {
      // Set a single value list
      bloodPressure.set(<BloodPressureObservation>[obs]);
    } else {
      bps.add(obs);
    }
    // And then do this:
    await healthManager.postBloodPressure(obs, addToBatch: inBatch);
  }

  /// Adds a smoking status observation to the current data (even if it hasn't been loaded yet) and then attempts to
  /// write it to the backend.
  Future<void> addSmokingStatusObservation(SmokingStatusObservation obs,
      {bool inBatch = false}) async {
    final List<SmokingStatusObservation>? statusObsList = smokingStatus.value;
    if (statusObsList == null) {
      // Set a single value list
      smokingStatus.set(<SmokingStatusObservation>[obs]);
    } else {
      statusObsList.add(obs);
    }
    // And then do this:
    await healthManager.postSmokingStatus(obs, addToBatch: inBatch);
  }

  /// writes the current patient demographics to the backend (if loaded)
  Future<void> updatePatientDemographics({bool inBatch = false}) async {
    if (patientDemographics._state == LoadState.done) {
      PatientDemographics? currentDemographics = patientDemographics.value;
      if (currentDemographics != null) {
        await healthManager.putPatientDemographics(currentDemographics,
            addToBatch: inBatch);
      }
    }
  }

  Future<void> postCurrentTransaction() async {
    await healthManager.transactionManager
        .postCurrentUpdateBatch(healthManager);
  }
}
