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

/// This class contains functions for converting HealthKit data to, at present, JSON data that can be returned via the Flutter API bridge.
class HealthKitConverter {
    /// FHIR utility class. This creates an instance that creates dates in GMT+00:00 rather than the device's local time zone.
    let fhirUtils = FHIRUtils()

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
            "effectiveDate": fhirUtils.createFHIRDateTime(fromDate: record.startDate),
            "encoded": encodeSample(sample: sample)
        ];
    }

    @available(iOS 12.0, *)
    func createCategoryValueResponse(fromCategory sample: HKSample) -> [String: String?]? {
        guard let record = sample as? HKCategorySample else { return nil }
        var value: String = "unknown"
        if #available(iOS 14.3, *) {
            if(type(of: record.sampleType.identifier) == type(of: HKCategoryTypeIdentifier.pregnancy.rawValue)){
                switch (record.value) {
                case HKCategoryValue.notApplicable.rawValue: value = "notApplicable"
                default: value = "unknown"
                }
            }
        }

        return [
            "uuid": record.uuid.uuidString,
            "sampleType": record.sampleType.identifier,
            "value": value,
            "startDate": fhirUtils.createFHIRDateTime(fromDate: record.startDate),
            "endDate": fhirUtils.createFHIRDateTime(fromDate: record.endDate),
            "encoded": encodeSample(sample: sample)
        ];
    }

    /// Attempts to encode a sample into a string. This doesn't appear to work in a useful fashion.
    @available(iOS 12.0, *)
    func encodeSample(sample: HKSample) -> String {
        // For now, just see what happens if we attempt to encode the metadata
        do {
            guard let metadata = sample.metadata else {
                return "null";
            }
            let data = try JSONSerialization.data(withJSONObject: metadata)
            guard let result = String(data: data, encoding: .utf8) else {
                return "\"error encoding\"";
            }
            return result
        } catch {
            // In this case, just return a string indicating an error.
            return "\"metadata could not be converted to JSON\""
        }
    }
}
