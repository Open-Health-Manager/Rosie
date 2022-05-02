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

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fhir/r4.dart';

class InternalException implements Exception {
  const InternalException(this.message);
  final String message;

  @override
  String toString() {
    return "Internal Error: $message";
  }
}

// Indicates the server raised an error.
class ServerErrorException implements Exception {
  const ServerErrorException(this.statusCode, this.reasonPhrase, this.message);
  ServerErrorException.fromResponse(http.Response response, String message) : this(response.statusCode, response.reasonPhrase, message);

  final String message;
  final int statusCode;
  final String? reasonPhrase;

  @override
  String toString() {
    var b = StringBuffer()
      ..write('Server error: ')
      ..write(message)
      ..write(' (HTTP ')
      ..write(statusCode.toString());
    if (reasonPhrase != null) {
      b.write(' ');
      b.write(reasonPhrase);
    }
    b.write(')');
    return b.toString();
  }
}

// Thrown when the server indicates a success, but the response could not be handled.
class InvalidResponseException implements Exception {
  const InvalidResponseException(this.message);
  final String message;

  @override
  String toString() {
    return message;
  }
}

class InvalidConfigError extends Error {
  InvalidConfigError(this.message) : super();
  final String message;

  @override
  String toString() {
    return message;
  }
}

// Mostly a place-holder class, this represents the authentication information. At present, this just contains the
// patient ID.
class AuthData {
  const AuthData(this.id);
  final Id id;
}

// Provides APIs for accessing parts of Open Health Manager.
// This also holds on to the authentication information.
class OpenHealthManager with ChangeNotifier {
  OpenHealthManager({required this.fhirBase});

  final Uri fhirBase;
  AuthData? _authData;

  bool get isSignedIn => _authData != null;

  static OpenHealthManager fromConfig(Map<String,dynamic> config) {
    if (!config.containsKey("fhirBase")) {
      throw InvalidConfigError('Missing required key "fhirBase"');
    }
    var fhirBase = config["fhirBase"];
    if (fhirBase is String) {
      return OpenHealthManager(fhirBase: Uri.parse(fhirBase));
    } else {
      throw InvalidConfigError('Invalid value for key "fhirBase": $fhirBase');
    }
  }

  // Attempts to sign in. Returns null if the sign in attempt was rejected. Raises an exception on communication failure.
  Future<AuthData?> signIn(String email, String password) async {
    final jsonData = await getJsonObjectFromResource('Patient', {
      "identifier": "urn:mitre:healthmanager:account:username|$email"
    });
    final bundle = Bundle.fromJson(jsonData);
    // Pull out the entries (mostly so the compiler can confirm we throw on null)
    final entries = bundle.entry;
    if (entries == null) {
      throw const InvalidResponseException('Server response did not include an entries');
    }
    if (entries.isEmpty) {
      // Empty means no matching user means "login" failed
      return null;
    }
    final patientResource = entries.first.resource;
    if (patientResource == null) {
      // This is invalid
      throw const InvalidResponseException('Server bundle did not include a resource');
    }
    final patientId = patientResource.id;
    if (patientId == null) {
      throw const InvalidResponseException('Patient returned has no associated ID');
    }
    final auth = AuthData(patientId);
    _authData = auth;
    notifyListeners();
    return _authData;
  }

  // Attempts to create an account. Throws an exception on error. Returns the associated AuthData for the newly created
  // account on success.
  Future<AuthData> createAccount(String fullName, String email) async {
    final response = await postJsonObjectToResource("Patient", {
      "resourceType": "Patient",
      "identifier": [
        {
          "system": "urn:mitre:healthmanager:account:username",
          "value": email
        }
      ],
      "name": [
        { "text": fullName }
      ]
    });
    // Try and parse the response
    final patient = Patient.fromJson(response);
    // Make sure we have an ID
    final id = patient.id;
    if (id == null) {
      throw const InvalidResponseException('Returned response has no patient ID');
    }
    final auth = AuthData(id);
    _authData = auth;
    notifyListeners();
    return auth;
  }

  Map<String, dynamic> _parseJsonResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 299) {
      final parsed = json.decode(response.body);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      } else {
        throw const InvalidResponseException('Expected a JSON object response.');
      }
    } else {
      throw ServerErrorException.fromResponse(response, 'Server returned an error');
    }
  }

  Future<Map<String, dynamic>> getJsonObjectFromResource(String resource, [Map<String, dynamic>? queryParameters]) {
    Uri uri = fhirBase.resolve(resource);
    if (queryParameters != null) {
      uri = uri.replace(queryParameters: queryParameters);
    }
    return getJsonObject(uri);
  }

  // Helper method designed to ensure the result from the server was a JSON object.
  Future<Map<String, dynamic>> getJsonObject(Uri uri) async {
    return _parseJsonResponse(await http.get(uri));
  }

  Future<Map<String, dynamic>> postJsonObjectToResource(String resource, Map<String, dynamic> object) {
    return postJsonObject(fhirBase.resolve(resource), object);
  }

  Future<Map<String, dynamic>> postJsonObject(Uri url, Map<String, dynamic> object) async {
    return _parseJsonResponse(await http.post(url, headers: {
      "Content-type": "application/json; charset=utf-8"
    }, body: json.encode(object)));
  }
}