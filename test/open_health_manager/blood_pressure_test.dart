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
import 'package:fhir/r4.dart';
import 'package:rosie/src/open_health_manager/blood_pressure.dart';

void main() {
  test("test blood pressure parse", () {
    // Create our test observation:
    final obs = Observation(
      id: Id("2634785"),
      code: CodeableConcept(
        text: "BP-blood pressure",
        coding: <Coding>[
          Coding(system: FhirUri("http://loinc.org"), code: Code("55284-4"))
        ]
      ),
      issued: Instant.fromDateTime(DateTime.utc(2017, 10, 18)),
      status: ObservationStatus.final_,
      category: <CodeableConcept>[
        CodeableConcept(
          coding: <Coding>[
            Coding(
              system: FhirUri("http://hl7.org/fhir/observation-category"),
              code: Code("vital-signs")
            )
          ],
          text: "Vital Signs"
        )
      ],
      component: <ObservationComponent>[
        ObservationComponent(
          code: CodeableConcept(
            coding: <Coding>[
              Coding(
                display: "Systolic blood pressure",
                system: FhirUri("http://loinc.org"),
                code: Code("8480-6")
              )
            ],
            text: "Systolic blood pressure"
          ),
          valueQuantity: Quantity(
            code: Code("mm[Hg]"),
            system: FhirUri("http://unitsofmeasure.org"),
            value: Decimal(110.0),
            unit: "mm[Hg]"
          )
        ),
        ObservationComponent(
          code: CodeableConcept(
            coding: <Coding>[
              Coding(
                display: "Diastolic blood pressure",
                system: FhirUri("http://loinc.org"),
                code: Code("8462-4")
              )
            ],
            text: "Diastolic blood pressure"
          ),
          valueQuantity: Quantity(
            code: Code("mm[Hg]"),
            system: FhirUri("http://unitsofmeasure.org"),
            value: Decimal(70.0),
            unit: "mm[Hg]"
          )
        )
      ],
      encounter: Reference(reference: "Encounter/129837645"),
      subject: Reference(reference: "Patient/100")
    );
    // Now create our observation using it
    final actual = BloodPressureObservation.fromObservation(obs);
    // And make sure the values are what we expect
    expect(actual.systolic, closeTo(110.0, 2e-10));
    expect(actual.diastolic, closeTo(70.0, 2e-10));
  });
}