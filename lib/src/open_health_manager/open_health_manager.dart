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
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fhir/r4.dart';
import 'transaction_manager.dart';

class InternalException implements Exception {
  const InternalException(this.message);
  final String message;

  @override
  String toString() {
    return "Internal Error: $message";
  }
}

/// Indicates the server raised an error.
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

/// Thrown when the server indicates a success, but the response could not be handled.
class InvalidResponseException implements Exception {
  const InvalidResponseException(this.message);
  final String message;

  @override
  String toString() {
    return message;
  }
}

/// Thrown when an otherwise valid resource (that is, one that successfully parsed as JSON and is otherwise valid FHIR)
/// has parts that are either missing or otherwise invalid such that it cannot be used.
class InvalidResourceException implements Exception {
  const InvalidResourceException(this.message);
  final String message;

  @override
  String toString() {
    return message;
  }
}

/// Thrown when an attempt is made to execute a method that requires an authenticated session.
class NotAuthenticatedError extends Error {
  NotAuthenticatedError(this.message) : super();
  final String message;

  @override
  String toString() {
    return message;
  }
}

/// Thrown when the configuration information given in the config object is invalid.
class InvalidConfigError extends Error {
  InvalidConfigError(this.message) : super();
  final String message;

  @override
  String toString() {
    return message;
  }
}

/// Mostly a place-holder class, this represents the authentication information. At present, this just contains the
/// patient ID.
class AuthData {
  AuthData(this.id, this.username, this.dataConnected);
  final Id id;
  final String username;

  MessageHeader createHeader({String? endpoint}) {
    return MessageHeader(
      // TODO: Id
      eventUri: FhirUri("urn:mitre:healthmanager:pdr"),
      source: MessageHeaderSource(endpoint: FhirUrl(endpoint ?? "urn:mitre:rosie")),
      extension_: <FhirExtension>[
        FhirExtension(
          url: FhirUri("https://github.com/Open-Health-Manager/patient-data-receipt-ig/StructureDefinition/AccountExtension"),
          valueString: username)
      ]
    );
  }

  // true if logged in, false if created. should not ultimately live here.
  bool dataConnected;
}

/// Provides APIs for accessing parts of Open Health Manager.
/// This also holds on to the authentication information.
class OpenHealthManager with ChangeNotifier {
  OpenHealthManager({required this.fhirBase});

  /// The base URI for FHIR requests.
  ///
  /// Resolved URIs are created via [fhirBase.resolve].
  final Uri fhirBase;
  final transactionManager = TransactionManager();

  /// Internal client used for all requests.
  final client = http.Client();
  AuthData? _authData;

  AuthData? get authData => _authData;
  bool get isSignedIn => _authData != null;

  static OpenHealthManager fromConfig(Map<String, dynamic> config) {
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

  /// Attempts to sign in. Returns `null` if the sign in attempt failed. Raises an exception on communication failure.
  Future<AuthData?> signIn(String email, String password) async {
    final jsonData = await getJsonObjectFromResource('Patient', {
      "identifier": "urn:mitre:healthmanager:account:username|$email"
    });
    final bundle = Bundle.fromJson(jsonData);
    // Pull out the entries (mostly so the compiler can confirm we throw on null)
    final entries = bundle.entry;
    if (entries == null || entries.isEmpty) {
      // Empty or missing means no matching user means "login" failed
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
    final auth = AuthData(patientId, email, true);
    _authData = auth;
    notifyListeners();
    return _authData;
  }

  /// Attempts to create an account. Throws an exception on error. Returns the associated AuthData for the newly created
  /// account on success.
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
    final auth = AuthData(id, email, false);
    _authData = auth;
    notifyListeners();
    return auth;
  }

  /// Assuming the user is logged in, attempts to create a reference to their patient record.
  ///
  /// It's possible this method may need to be refactored elsewhere in the
  /// future, but since this class currently maintains "authentication" data and
  /// therefore "who the user is," it's likely that generating a reference to
  /// the subject will remain here as well.
  Reference? createPatientReference() {
    final id = authData?.id;
    return id == null ? null : Reference(reference: "Patient/${id.value}");
  }

  /// Attempts to pull the Patient resource for this patient.
  ///
  /// This method will raise a [NotAuthenticatedError] if invoked when [isSignedIn] is false. For a list of valid query
  /// parameters, see the [FHIR documentation](https://hl7.org/fhir/R4/search.html).
  Future<Patient> queryPatient() async {
    final patientId = _authData?.id.toString();
    if (patientId == null) {
      throw NotAuthenticatedError("No current session");
    }
    final uri = fhirBase.resolve("Patient/$patientId");
    log("targetURI: " + uri.toString());
    final jsonObject = await getJsonObject(uri);
    return Patient.fromJson(jsonObject);
  }

  /// Attempts to query a given resource.
  ///
  /// This method will raise a [NotAuthenticatedError] if invoked when [isSignedIn] is false. For a list of valid query
  /// parameters, see the [FHIR documentation](https://hl7.org/fhir/R4/search.html).
  Future<Bundle> queryResource(String name, [Map<String, dynamic>? query]) async {
    final patientId = _authData?.id.toString();
    if (patientId == null) {
      throw NotAuthenticatedError("No current session");
    }
    var uri = fhirBase.resolve(name);
    final queryParameters = <String, dynamic>{"patient": patientId};
    if (query != null) {
      queryParameters.addAll(query);
    }
    uri = uri.replace(queryParameters: queryParameters);
    final jsonObject = await getJsonObject(uri);
    return Bundle.fromJson(jsonObject);
  }

  /// Core method for sending HTTP requests. This will add any necessary authentication headers to the request before
  /// sending it. See [http.Client.send] for details about the underlying method used. If an error prevents the request
  /// from being sent, an [http.ClientException] may be raised.
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Currently this does nothing. In the future it will set the Bearer token.
    return client.send(request);
  }

  /// Sends a request, parsing the response as a JSON object and returning that JSON object.
  ///
  /// This wraps [send] and therefore may throw [http.ClientException]. If the response cannot be parsed as JSON, this
  /// will throw a [FormatException]. IF it can be parsed but does not contain a JSON object, it will throw a
  /// [InvalidResponseException]. If the server response is an error, this will throw a [ServerErrorException].
  Future<Map<String, dynamic>> sendJsonRequest(http.BaseRequest request) async {
    final streamedResponse = await send(request);
    final response = await http.Response.fromStream(streamedResponse);
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

  /// Send a JSON object and receive a JSON object in response. This wraps [sendJsonRequest] and generates a
  /// [http.Request] containing the given object as the HTTP body.
  Future<Map<String, dynamic>> sendJsonObject(String method, Uri uri, Map<String, dynamic> object) {
    final request = http.Request(method, uri);
    request.headers['Content-Type'] = 'application/json; charset=utf8';
    request.body = json.encode(object);
    return sendJsonRequest(request);
  }

  /// Sends a GET query to a specific FHIR resource and retrieve a parsed JSON object.
  ///
  /// This does not attempt to compartmentalize to a given patient.
  Future<Map<String, dynamic>> getJsonObjectFromResource(String resource, [Map<String, dynamic>? queryParameters]) {
    Uri uri = fhirBase.resolve(resource);
    if (queryParameters != null) {
      uri = uri.replace(queryParameters: queryParameters);
    }
    return getJsonObject(uri);
  }

  /// Helper method designed to ensure the result from the server was a JSON object.
  ///
  /// If the response cannot be parsed as JSON, this will throw a [FormatException]. If the response can be parsed as
  /// JSON but is otherwise invalid, throws a [InvalidResponseException].
  Future<Map<String, dynamic>> getJsonObject(Uri uri) {
    final request = http.Request("GET", uri);
    // TODO: Make this a parameter or something?
    request.headers["Cache-Control"] = "no-cache";
    return sendJsonRequest(request);
  }

  /// Helper method for POSTing a JSON object to the server and receiving a JSON object as a response. This wraps
  /// [sendJsonRequest] and can throw exceptions it can.
  Future<Map<String, dynamic>> postJsonObject(Uri url, Map<String, dynamic> object) {
    return sendJsonObject('POST', url, object);
  }

  /// Helper method for PUTting a JSON object to the server and receiving a JSON object as a response. This wraps
  /// [sendJsonRequest] and can throw exceptions it can.
  Future<Map<String, dynamic>> putJsonObject(Uri url, Map<String, dynamic> object) {
    return sendJsonObject('PUT', url, object);
  }

  /// Sends a process message with the given set of resources.
  Future<Map<String, dynamic>> sendProcessMessage(Iterable<Map<String, dynamic>> resources, {String? fhirVersion, String? endpoint}) {
    final authData = _authData;
    if (authData == null) {
      throw NotAuthenticatedError("Cannot post message when not authenticated");
    }
    // Build a bundle based on that
    final bundle = <String, dynamic>{
      "resourceType": "Bundle",
      "type": "message",
      "entry": <Map<String, dynamic>> [
        <String, dynamic>{
          "resource": authData.createHeader(endpoint: endpoint).toJson()
        },
        ...resources.map<Map<String, dynamic>>((resource) {
          // Create an individual entry
          return <String, dynamic>{
            "resource": resource
          };
        })
      ]
    };
    var uri = fhirBase.resolve("\$process-message");
    log('Sending process message: ${json.encode(bundle)}', level: 800);
    if (fhirVersion != null) {
      uri = uri.replace(queryParameters: {
        "fhir_version": fhirVersion
      });
    }
    return postJsonObject(uri, bundle);
  }

  /// Wrapper around postJsonObjectToResource to post a given resource.
  ///
  /// The resource **must** have a defined [resource.resourceType] or this will
  /// raise an [InvalidResourceException].
  Future<Map<String, dynamic>> postResource(Resource resource) {
    final resourceType = resource.resourceTypeString;
    if (resourceType == null) {
      throw const InvalidResourceException("Cannot post resources without a type (they are invalid)");
    }
    return postJsonObjectToResource(resourceType, resource.toJson());
  }

  /// Wrapper around postJsonObject to post a transaction.
  Future<Map<String, dynamic>> postTransaction(Bundle transaction) {
    return postJsonObject(fhirBase, transaction.toJson());
  }

  /// Wrapper around putJsonObjectToResource to PUT a given resource.
  ///
  /// The resource **must** have a defined [resource.resourceType] or this will
  /// raise an [InvalidResourceException].
  Future<Map<String, dynamic>> putResource(Resource resource) {
    final resourceType = resource.resourceTypeString;
    if (resourceType == null) {
      throw const InvalidResourceException(
          "Cannot post resources without a type (they are invalid)");
    }
    final resourceId = resource.id?.value;
    if (resourceId == null) {
      throw const InvalidResourceException(
          "Cannot post resources without an id");
    }
    return putJsonObjectToResourceId(
        resourceType, resourceId, resource.toJson());
  }
  /// Helper method for posting a JSON object to a specific FHIR resource on the server, and receiving a JSON object as
  /// a response.
  Future<Map<String, dynamic>> postJsonObjectToResource(String resource, Map<String, dynamic> object) {
    return postJsonObject(fhirBase.resolve(resource), object);
  }

  /// Helper method for putting a JSON object to a specific FHIR resource on the server, and receiving a JSON object as
  /// a response.
  Future<Map<String, dynamic>> putJsonObjectToResourceId(
      String resource, String id, Map<String, dynamic> object) {
    return putJsonObject(fhirBase.resolve("$resource/$id"), object);
  }
}