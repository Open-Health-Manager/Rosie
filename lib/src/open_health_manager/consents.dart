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

import 'package:http/http.dart';
import 'open_health_manager.dart';

class PatientConsent {
  const PatientConsent({
    required this.id,
    required this.approve,
    required this.fhirResource,
    required this.client,
  });

  final String id;
  final bool approve;
  final String fhirResource;
  final FHIRClient client;

  static PatientConsent fromJson(dynamic jsonData) {
    if (jsonData is Map<String, dynamic>) {
      final id = jsonData['id'];
      final approve = jsonData['approve'];
      final fhirResource = jsonData['fhirResource'];
      final client = jsonData['client'];
      if (id is String && approve is bool && fhirResource is String) {
        return PatientConsent(
            id: id,
            approve: approve,
            fhirResource: fhirResource,
            client: FHIRClient.fromJson(client));
      } else {
        throw const FormatException('Missing key or invalid data');
      }
    } else {
      // Otherwise, throw a FormatException
      throw const FormatException('Invalid object type for patient consent');
    }
  }
}

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

extension PatientConsentsQuerying on OpenHealthManager {
  /// Loads a part of the list of patient consent data.
  Future<List<PatientConsent>> getPatientConsents({
    int page = 0,
    int size = 20,
  }) async {
    final url = serverUrl.resolve('api/fhir-patient-consents?page=$page&size=$size&eagerload=true');
    final list = await sendJsonArrayRequest(Request('GET', url));
    return list.map((json) => PatientConsent.fromJson(json)).toList();
  }

  Future<List<FHIRClient>> getFHIRClients({int page = 0, int size = 20}) async {
    final url = serverUrl.resolve('api/fhir-clients?page=$page&size=$size');
    final results = await sendJsonArrayRequest(Request('GET', url));
    return results.map((json) => FHIRClient.fromJson(json)).toList();
  }

  /// By default, getPatientConsents() only gets the patient consents that
  /// exist. This will create empty patient consents for the clients that don't
  /// have any, with approve set to false.
  Future<List<PatientConsent>> getAllPatientConsents() async {
    // For now, just use the default page/size
    final clients = await getFHIRClients();
    print('Got ${clients.length} clients');
    // Next, get the existing consents
    // final consents = await getPatientConsents();
    // print('Got ${consents.length} existing consents');
    // Consents appear to be broken.
    final consents = <PatientConsent>[];
    final existingConsents = Map.fromEntries(
        consents.map((consent) => MapEntry(consent.client.uri, consent)));
    return clients.map<PatientConsent>((client) {
      final existing = existingConsents[client.uri];
      if (existing != null) {
        return existing;
      } else {
        return PatientConsent(
          id: client.id.toString(),
          approve: false,
          fhirResource: '',
          client: client,
        );
      }
    }).toList();
  }
}
