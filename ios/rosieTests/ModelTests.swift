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
 
final class ModelTests: XCTestCase {
    
    func testCategorySample() throws {
        // test json -> model
        let json_data_src = Data("""
            {
                "uuid":"d7e824b5-1aa1-4a36-b556-870d9ff5066e",
                "sourceRevision":{
                    "bundleIdentifier":"123",
                    "name":"rosie"
                },
                "sampleType":"category",
                "categoryType":"fever",
                "value":1
            }
        """.utf8);
        let decoder = JSONDecoder();
        
        let category_sample = try decoder.decode(AppleHealthKitCategorySample.self, from: json_data_src);
        XCTAssertNotNil(category_sample);
        
        // test model -> json
        let encoder = JSONEncoder();
        let json_data_out = try encoder.encode(category_sample);
        print(String(data: json_data_out, encoding: .utf8)!);
        XCTAssertNotNil(json_data_out);
        XCTAssertEqual(json_data_src, json_data_out);
        
    }
    
}
