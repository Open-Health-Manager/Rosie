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

import 'package:flutter_test/flutter_test.dart';
import 'package:rosie/src/care_plan/blood_pressure/blood_pressure_vis_screen.dart';


const healthKitUrn = 'urn:apple:health-kit';

void main() {
  group('BloodPressureScale', () {
    // Create a local one to ensure that, even if the numbers change later,
    // these tests are using known values.
    const scale =
      BloodPressureScale([90, 140, 180, 230], [60, 90, 110, 140]);
    test('returns the last slice if the value is out of range high', () {
      expect(scale.activeSlice(240, 150), equals(3));
      expect(scale.activeSlice(160, 150), equals(3));
      expect(scale.activeSlice(240, 120), equals(3));
    });

    test('returns the first slice if the value is out of range low', () {
      expect(scale.activeSlice(0, 0), equals(0));
    });
  });
}
