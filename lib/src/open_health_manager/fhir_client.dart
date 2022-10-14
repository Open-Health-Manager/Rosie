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

import '../data_source/health_kit/health_kit.dart';

/// Information about a specific FHIR client that can be used to pull FHIR data
/// from some source.
class FHIRClient {
  const FHIRClient({
    required this.id,
    required this.name,
    required this.displayName,
    required this.uri,
    required this.fhirOrganizationId,
    required this.clientDirection,
  });

  final int id;
  final String name;
  final String displayName;
  final String uri;
  final String fhirOrganizationId;
  final String clientDirection;

  /// Determines if this FHIR client is supported on the current device. This
  /// method is asynchronous as determining if the client is supported may
  /// involve an asynchronous method call.
  Future<bool> isClientSupported() {
    // For now, only check if the URI is the HealthKit client
    if (uri == 'https://developer.apple.com/health-fitness/') {
      return HealthKit.supportsHealthRecords();
    } else {
      return Future.value(true);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "displayName": displayName,
      "uri": uri,
      "fhirOrganizationId": fhirOrganizationId,
      "clientDirection": clientDirection,
    };
  }

  static FHIRClient fromJson(dynamic jsonData) {
    if (jsonData is Map<String, dynamic>) {
      final id = jsonData['id'];
      final name = jsonData['name'];
      final displayName = jsonData['displayName'];
      final uri = jsonData['uri'];
      final fhirOrganizationId = jsonData['fhirOrganizationId'];
      final clientDirection = jsonData['clientDirection'];
      if (id is num &&
          name is String &&
          displayName is String &&
          uri is String &&
          fhirOrganizationId is String &&
          clientDirection is String) {
        return FHIRClient(
          id: id.toInt(),
          name: name,
          displayName: displayName,
          uri: uri,
          fhirOrganizationId: fhirOrganizationId,
          clientDirection: clientDirection,
        );
      } else {
        throw const FormatException('Missing key or invalid data');
      }
    } else {
      // Otherwise, throw a FormatException
      throw const FormatException('Invalid object type for client');
    }
  }
}