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

import Foundation
import HealthKit

@available(iOS 12.0, *)
func createCorrelationValueResponse(fromCorrelation sample: HKSample) -> [String: String?]? {
    guard let record = sample as? HKCorrelation else { return nil }
    var systolicString: String = "unknown"
    var diastolicString: String = "unknown"

    let systolicTypeOptional = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic)
    let diastolicTypeOptional = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic)

    if(type(of: record.sampleType.identifier) == type(of: HKCorrelationTypeIdentifier.bloodPressure.rawValue)){

        if let systolicType = systolicTypeOptional, let diastolicType = diastolicTypeOptional {
            if let data1 = record.objects(for: systolicType).first as? HKQuantitySample,
            let data2 = record.objects(for: diastolicType).first as? HKQuantitySample {
                let systolicValue = data1.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                let diastolicValue = data2.quantity.doubleValue(for: HKUnit.millimeterOfMercury())

                systolicString = String(format: "%f", systolicValue)
                diastolicString = String(format: "%f", diastolicValue)
            }
        }
    }

    return [
        "uuid": record.uuid.uuidString,
        "sampleType": record.sampleType.identifier,
        "systolicValue": systolicString,
        "diastolicValue": diastolicString,
        "effectiveDate": createFHIRDateTime(fromDate: record.startDate)
    ];
}
