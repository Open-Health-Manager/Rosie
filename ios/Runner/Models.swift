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

// declares that class can convert to FHIR JSON
protocol FHIRJSONSerializable {
    func toJson() -> String
}
// declares that class can convert to FHIR XML
protocol FHIRXMLSerializable {
    func toXML() -> String
}
/// Consider: remove the above because structure map's may take care of them

/// Abstract Class for Apple Health Kit
class AppleHealthKitObject {
    var uuid: String { get; set }
    var metadata: Dictionary [String: String]? // TODO value choice type

    var device: Device?; struct Device {
        var udiDeviceIdentifier: String?
        var firmwareVersion: String?
        var hardwareVersion: String?
        var localIdentifier: String?
        var manufacturer: String?
        var model: String?
        var name: String?
        var softwareVersion? String
    }

    struct SourceRevision {
        var source: Source; struct Source {
            var bundleIdentifier: String
            var name: String
        }

        var version: String?

        var operatingSystemVersion: OperatingSystemVersion?; struct OperatingSystemVersion {
            var majorVersion: Int?
            var minorVersion: Int?
            var patchVersion: Int?
        }

        var productType: String?
    }
}

class AppleHealthKitSample: AppleHealthKitObject {
    var startDate: Date?
    var endDate: Date?
    var hasUndeterminedDuration: Bool?
    var sampleType: String // confirmed?
}

class AppleHealthKitCategorySample: AppleHealthKitSample, FHIRJSONSerializable {
    var categoryType: String
    var value: Int

    func toJson() -> String {
        return "{}" // TODO
    }
}

