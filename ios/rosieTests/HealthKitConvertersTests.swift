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

import XCTest
import HealthKit

final class HealthKitConvertersTests: XCTestCase {
    let gregorianCalendar = Calendar(identifier: .gregorian)
    let formatter = ISO8601DateFormatter()
    var previousTimeZone: TimeZone? = nil

    override func setUpWithError() throws {
        formatter.formatOptions = .withInternetDateTime
        previousTimeZone = NSTimeZone.default
        NSTimeZone.default = TimeZone(secondsFromGMT: 0)!
    }

    override func tearDownWithError() throws {
        if let previousTimeZone = previousTimeZone {
            NSTimeZone.default = previousTimeZone
            self.previousTimeZone = nil
        }
    }

    func testCreateCategoryResponse() throws {
        // Create a test sample
        let sample = HKCategorySample(type: HKCategoryType.categoryType(forIdentifier: .pregnancy)!, value: HKCategoryValue.notApplicable.rawValue, start: formatter.date(from: "2022-01-01T12:00:00Z")!, end: formatter.date(from: "2022-09-01T12:00:00Z")!)
    }
    
    func testCreateCorrelationValueResponse() throws {
        let date = formatter.date(from: "2022-06-09T15:02:04Z")!
        let systolicSample = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!, quantity: HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: 120.0), start: date, end: date)
        let diastolicSample = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!, quantity: HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: 80.0), start: date, end: date)
        let sample = HKCorrelation(type: HKCorrelationType.correlationType(forIdentifier: .bloodPressure)!, start: date, end: date, objects: [systolicSample, diastolicSample])
        let actual = createCorrelationValueResponse(fromCorrelation: sample)
        XCTAssertNotNil(actual)
        if let actual = actual {
            XCTAssertEqual(Set(actual.keys), Set(["uuid", "sampleType", "systolicValue", "diastolicValue", "effectiveDate"]))
            XCTAssertEqual(actual["uuid"], sample.uuid.uuidString)
            XCTAssertEqual(actual["sampleType"], sample.sampleType.identifier)
            XCTAssertEqual(actual["systolicValue"], String(format: "%f", 120.0))
            XCTAssertEqual(actual["diastolicValue"], String(format: "%f", 80.0))
            XCTAssertEqual(actual["effectiveDate"], "2022-06-09T15:02:04.000Z")
        }
    }


}
