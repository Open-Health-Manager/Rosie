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

/// Container class for FHIR utility methods. May also be instantiated to set other values.
class FHIRUtils {
    /// Calendar used. Should always be Gregorian or the dates generated may not make sense!
    var calendar: Calendar

    init(calendar: Calendar = Calendar(identifier: .gregorian)) {
        self.calendar = calendar
        // Always set to GMT. For whatever reason this is returned as an Optional,
        // even though the underlying NSTimeZone(secondsFromGMT) does not return an
        // Optional, so just assume it's always safe? It failing may as well be a
        // fatal error anyway.
        self.calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    }

    /// Creates a FHIR date using the given calendar
    func createFHIRDateTime(fromDate date: Date?) -> String {
        guard let date = date else { return "" }
        return FHIRUtils.createFHIRDateTime(fromDateComponents: calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond, .calendar, .timeZone], from: date))
    }

    /// Formats just the FHIR Date part of a Date. This will fill out only to as far as the provided DateComponents have dates. This returns an empty string if no date information can be found (or the date components are nil).
    static func createFHIRDate(fromDateComponents dateComponents: DateComponents?) -> String {
        // If nil, return an empty string
        guard let dateComponents = dateComponents else { return "" }
        guard let year = dateComponents.year else { return "" }
        if let month = dateComponents.month {
            if let date = dateComponents.day {
                return String(format: "%d-%02d-%02d", year, month, date)
            }
            return String(format: "%d-%02d", year, month)
        } else {
            return "\(year)"
        }
    }

    /// Like createFHIRDate, but includes the time if possible. This is almost the same as the ISO8601DateFormatter, except for the ability to include milliseconds if nanoseconds are provided.
    /// Note that if you want timezone conversion to work, you MUST supply the `.calendar` when generating the components!
    static func createFHIRDateTime(fromDateComponents dateComponents: DateComponents?) -> String {
        guard let dateComponents = dateComponents else { return "" }
        // This only works if the calendar is the Gregorian calendar. However, the calendar used need not be provided,
        // so if it's nil, caveat salutator, I guess?
        guard dateComponents.calendar == nil || dateComponents.calendar?.identifier == .gregorian else { return "" }
        guard let year = dateComponents.year else { return "" }
        if let month = dateComponents.month {
            if let day = dateComponents.day {
                if let hour = dateComponents.hour {
                    // If we have a time, we may have a timezone
                    let timezone = dateComponents.timeZone
                    var timezoneStr = "-00:00";
                    // If timezone is set, attempt to generate a string for it
                    if let timezone = timezone, let dateObject = dateComponents.date {
                        let offset = timezone.secondsFromGMT(for: dateObject)
                        if offset != 0 {
                            // The 3 is because the sign counts as a pad digit
                            timezoneStr = String(format: "%+03d:%02d", offset / (60 * 60), (abs(offset) / 60) % 60)
                        }
                    }
                    let minute = dateComponents.minute ?? 0
                    let second = dateComponents.second ?? 0
                    if let nanosecond = dateComponents.nanosecond {
                        // FHIR doesn't like nanoseconds, but does allow milliseconds
                        // 1 ns = 1/1,000,000,000 of a second, 1 ms = 1/1,000 of a second
                        return String(format: "%d-%02d-%02dT%02d:%02d:%02d.%03d%@", year, month, day, hour, minute, second, nanosecond / 1_000_000, timezoneStr);
                    }
                    return String(format: "%d-%02d-%02dT%02d:%02d:%02d%@", year, month, day, hour, minute, second, timezoneStr)
                } else {
                    return String(format: "%d-%02d-%02d", year, month, day)
                }
            }
            return String(format: "%d-%02d", year, month)
        } else {
            return "\(year)"
        }
    }
}
