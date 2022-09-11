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
import 'account.dart';
import 'open_health_manager.dart';

/// Patient consent object. Patient consents that represent database-backed
/// objects **must** have an [id]. Patient consents that do not represent a
/// database-backed object **must** have `null` for an `id`.
class PatientConsent {
  const PatientConsent({
    this.id,
    required this.approve,
    required this.fhirResource,
    required this.client,
  });

  /// The ID of the original entry. When `null`, this represents a consent that
  /// **is not** stored within the database.
  final String? id;
  final bool approve;
  final String fhirResource;
  final FHIRClient client;

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{
      "approve": approve,
      "fhirResource": fhirResource,
      "client": client.toJson(),
    };
    if (id != null) {
      result["id"] = id;
    }
    return result;
  }

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

extension PatientConsentsQuerying on OpenHealthManager {
  /// Loads a part of the list of patient consent data.
  Future<List<PatientConsent>> getPatientConsents() async {
    final url = serverUrl.resolve('api/fhir-patient-consents');
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
    final consents = await getPatientConsents();
    print('Got ${consents.length} existing consents');
    // final consents = <PatientConsent>[];
    final existingConsents = Map.fromEntries(
        consents.map((consent) => MapEntry(consent.client.uri, consent)));
    return clients.map<PatientConsent>((client) {
      final existing = existingConsents[client.uri];
      if (existing != null) {
        return existing;
      } else {
        return PatientConsent(
          id: null,
          approve: false,
          fhirResource: '',
          client: client,
        );
      }
    }).toList();
  }

  /// Updates a patient consent object with the given changes.
  Future<PatientConsent> updatePatientConsent(
    PatientConsent consent,
    Account account,
    bool approve,
  ) async {
    // This is almost identical depending on if the ID is null or not.
    // If null, POST. If non-null, PUT.
    var url = serverUrl.resolve('api/fhir-patient-consents');
    final id = consent.id;
    if (id != null) {
      url = url.resolve(id);
    }
    final jsonData = <String, dynamic>{
      "approve": approve,
      "user": {"id": account.id},
      "client": {"id": consent.client.id}
    };
    if (consent.id != null) {
      jsonData["id"] = consent.id;
    }
    final result = await sendJsonObject(
        consent.id == null ? 'POST' : 'PUT', url, jsonData);
    // Currently, the result for POSTing returns an invalid client, so
    // merge in the new values with the existing client info
    final newId = result["id"];
    final newApprove = result["approve"];
    final newFhirResource = result["fhirResource"];
    if (newId is String && newApprove is bool && newFhirResource is String) {
      return PatientConsent(
        id: newId,
        approve: newApprove,
        fhirResource: newFhirResource,
        client: consent.client,
      );
    } else {
      throw const FormatException('Invalid or missing ID from server');
    }
  }
}
