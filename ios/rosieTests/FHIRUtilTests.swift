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

final class FHIRUtilTests: XCTestCase {
    var gregorianCalendar = Calendar(identifier: .gregorian)

    override func setUp() {
        gregorianCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
    }

    func testCreateFHIRDate() throws {
        XCTAssertEqual(FHIRUtils.createFHIRDate(fromDateComponents: DateComponents(calendar: gregorianCalendar, year: 2022)), "2022")
        XCTAssertEqual(FHIRUtils.createFHIRDate(fromDateComponents: DateComponents(calendar: gregorianCalendar, year: 2022, month: 2)), "2022-02")
        XCTAssertEqual(FHIRUtils.createFHIRDate(fromDateComponents: DateComponents(calendar: gregorianCalendar, year: 2022, day: 9)), "2022")
        XCTAssertEqual(FHIRUtils.createFHIRDate(fromDateComponents: DateComponents(calendar: gregorianCalendar, year: 2022, month: 2, day: 9)), "2022-02-09")
    }

    func testCreateFHIRDateTime() throws {
        // These tests are also sort of a test of how Apple handles dates *at all*
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        let testDate = formatter.date(from: "2022-04-10T10:12:13-04:00")
        // Fail test if nil
        XCTAssertNotNil(testDate)
        // And let Swift know it isn't nil
        if let testDate = testDate {
            let testDateComponents = gregorianCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .calendar, .timeZone], from: testDate)
            XCTAssertEqual(FHIRUtils.createFHIRDateTime(fromDateComponents: testDateComponents), "2022-04-10T14:12:13Z")
        }
    }

    func testCreateDateTimeZone() throws {
        // Basically: test to see what happens if we exclude the timezone
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        let testDate = formatter.date(from: "2022-10-31T23:59:59+00:00")
        XCTAssertNotNil(testDate)
        if let testDate = testDate {
            XCTAssertEqual(FHIRUtils.createFHIRDateTime(fromDateComponents:gregorianCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .calendar], from: testDate)), "2022-10-31T23:59:59Z")
        }
    }
}
