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

/// A model specifying information about the data use agreement.
class DataUseAgreement {
  const DataUseAgreement({required this.source, required this.version});

  /// The version of the DUA
  final String version;
  /// The URI where the DUA "lives"
  final Uri source;

  static DataUseAgreement fromJson(Map<String, dynamic> data) {
    final sourceData = data["source"];
    if (sourceData is! String) {
      throw const FormatException("Invalid or missing source in DataUseAgreement");
    }
    final versionData = data["version"];
    if (versionData is! String) {
      throw const FormatException("Invalid or missing version in DataUseAgreement");
    }
    return DataUseAgreement(source: Uri.parse(sourceData), version: versionData);
  }
}