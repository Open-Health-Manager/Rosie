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

/// Abstract Class for Apple Health Kit
class AppleHealthKitObject: Codable {
    var uuid: String;
    var metadata: [String:String]?;

    var device: Device?; struct Device: Codable {
        var udiDeviceIdentifier: String?;
        var firmwareVersion: String?;
        var hardwareVersion: String?;
        var localIdentifier: String?;
        var manufacturer: String?;
        var model: String?;
        var name: String?;
        var softwareVersion: String?;
    }

    var sourceRevision: SourceRevision?; struct SourceRevision: Codable {
        var source: Source; struct Source: Codable {
            var bundleIdentifier: String;
            var name: String;
        }

        var version: String?

        var operatingSystemVersion: OperatingSystemVersion?; struct OperatingSystemVersion: Codable {
            var majorVersion: Int?;
            var minorVersion: Int?;
            var patchVersion: Int?;
        }

        var productType: String?;
    }
    
}

/// Abstract Class for Apple Health Kit Sample, inherits codable
class AppleHealthKitSample: AppleHealthKitObject {
    var startDate: Date?
    var endDate: Date?
    var hasUndeterminedDuration: Bool?
    var sampleType: String
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
      }

    override func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)

    }
    
}

/// CategorySample class
class AppleHealthKitCategorySample: AppleHealthKitSample {
    var categoryType: String
    var value: Int
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
      }

    override func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        
    }
}

