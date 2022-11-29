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
import 'package:fhir/r4.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import '../../data_use_agreement/data_use_agreement.dart';
import 'jwt_token.dart' as jwt;
import 'transaction_manager.dart';

/// Logger for open_health_manager messages
final _log = Logger('rosie:open_health_manager');

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
  const ServerErrorException(
    this.statusCode,
    this.reasonPhrase,
    this.message,
    this.responseBody,
  );

  /// Creates an exception from the given error. This will attempt to
  ServerErrorException.fromResponse(
    http.Response response,
    String message,
  ) : this(
          response.statusCode,
          response.reasonPhrase,
          message,
          response.body,
        );

  final String message;
  final int statusCode;
  final String? reasonPhrase;
  final String? responseBody;

  /// Attempts to decode the response body as a JSON object. If there is no
  /// response body, this returns `null`. This uses [json.decode] and may raise
  /// a [FormatException].
  dynamic get responseObject {
    // Do not ask me why Dart requires this to be sure the _final_ property won't change
    final body = responseBody;
    return body == null ? null : json.decode(body);
  }

  static Future<ServerErrorException> fromStreamedResponse(
    http.StreamedResponse streamedResponse,
    String message,
  ) async {
    try {
      final response = await http.Response.fromStream(streamedResponse);
      return ServerErrorException.fromResponse(response, message);
    } on http.ClientException catch (_) {
      // Ignore this, as it likely happened when reading the response body
      return ServerErrorException(streamedResponse.statusCode,
          streamedResponse.reasonPhrase, message, null);
    }
  }

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

/// Thrown when an attempt is made to execute a method that requires the authentication state to be different than what
/// it currently is.
class AuthenticationStateError extends Error {
  AuthenticationStateError(this.message, {this.loginRequired = true}) : super();
  final String message;

  /// Indicates whether the error was caused by the login missing when required (true), or the login existing when not
  /// required (false). For example, creating a new account can only be done when logged out.
  final bool loginRequired;

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

/// Ensures that the given bearer token begins with `'Bearer '`. If the given string starts with `'Bearer '` (that exact
/// text, including the space), returns the token unmodified. Otherwise, returns the token with `'Bearer '` prepended to
/// it.
String _sanitizeBearerToken(String token) {
  return token.startsWith('Bearer ') ? token : 'Bearer $token';
}

/// Authentication information. This contains the JWT token used for authenticating requests with the server.
class AuthData {
  AuthData(this.id, this.username, String token)
      : bearerToken = _sanitizeBearerToken(token);
  final Id id;
  final String username;

  /// The bearer token. This always starts with the text "Bearer ".
  final String bearerToken;

  /// Gets the token minus the text "Bearer ".
  String get token => bearerToken.substring(7);

  MessageHeader createHeader({String? endpoint}) {
    return MessageHeader(
      // TODO: Id
      eventUri: FhirUri("urn:mitre:healthmanager:pdr"),
      source: MessageHeaderSource(endpoint: FhirUrl("urn:apple:health-kit")),
      focus: <Reference>[
        Reference(reference: "Patient/${id.value}"),
      ],
    );
  }

  Future<void> writeToSecureStorage(FlutterSecureStorage storage,
      [String key = "auth"]) {
    return storage.write(key: "auth", value: toJson());
  }

  /// Returns a string containing a JSON representation of this auth data.
  String toJson() {
    return json.encode(<String, String>{
      "id": id.toString(),
      "username": username,
      "token": token
    });
  }

  factory AuthData.fromJson(json) {
    if (json is Map<String, dynamic>) {
      final id = json["id"];
      final username = json["username"];
      final token = json["token"];
      if (id is String && username is String && token is String) {
        return AuthData(Id(id), username, token);
      } else {
        throw const FormatException("Invalid JSON: missing required key");
      }
    } else {
      throw const FormatException("Invalid JSON: not a JSON object");
    }
  }

  static Future<AuthData?> readFromSecureStorage(FlutterSecureStorage storage,
      [String key = "auth"]) async {
    final jsonData = await storage.read(key: key);
    if (jsonData == null) {
      return null;
    }
    // Otherwise, try and parse it
    try {
      return AuthData.fromJson(json.decode(jsonData));
    } on FormatException catch (error) {
      // Handle these by returning null
      _log.config("Unable to decode stored authentication data.", error);
      return null;
    }
  }
}

/// Provides APIs for accessing parts of Open Health Manager.
/// This also holds on to the authentication information.
class OpenHealthManager with ChangeNotifier {
  /// Create a new OpenHealthManager instance with the given configuration options.
  OpenHealthManager({
    required this.serverUrl,
    required this.fhirBase,
    http.Client? client,
  }) : client = client ?? http.Client();

  /// Creates the OpenHealthManager for a single server.
  OpenHealthManager.forServerURL(
    this.serverUrl, {
    http.Client? client,
  })  : fhirBase = serverUrl.resolve('fhir/'),
        client = client ?? http.Client();

  /// The base URI for the backend server.
  final Uri serverUrl;

  /// The base URI for FHIR requests. This is generally just [serverUrl] with
  /// the path `fhir/` added to the end.
  ///
  /// Resolved URIs are created via [fhirBase.resolve].
  final Uri fhirBase;
  final transactionManager = TransactionManager();

  /// Internal client used for all requests.
  final http.Client client;
  AuthData? _authData;

  /// The current authentication data.
  AuthData? get authData => _authData;

  /// Sets new authentication data and notifies listeners that it has been changed. This can be used to restore an
  /// existing set of authentication data that was persisted without requiring the user log in again. It can also be
  /// used to "log out" by setting back to null without actually logging out of the server.
  set authData(AuthData? newValue) {
    _authData = newValue;
    notifyListeners();
  }

  bool get isSignedIn => _authData != null;

  /// Creates an OpenHealthManager with the given configuration. Currently this looks for a single key in the given
  /// object, `"openHealthManager"`, which is a string that's used to populate [serverUrl]. In the future this may
  /// accept an object with more settings.
  ///
  /// If the value is missing or invalid, this throws [InvalidConfigError].
  static OpenHealthManager fromConfig(Map<String, dynamic> config) {
    if (!config.containsKey("openHealthManager")) {
      throw InvalidConfigError('Missing required key "openHealthManager"');
    }
    var ohmConfig = config["openHealthManager"];
    if (ohmConfig is String) {
      final Uri serverUrl;
      try {
        serverUrl = Uri.parse(ohmConfig);
      } on FormatException catch (_) {
        throw InvalidConfigError(
            'Could not parse URL "$ohmConfig" as a valid URI');
      }
      return OpenHealthManager.forServerURL(serverUrl);
    } else {
      // In the future this may also accept a map of more specific values
      throw InvalidConfigError(
          'Invalid value for key "openHealthManager": $ohmConfig');
    }
  }

  /// Attempts to sign in. Returns `null` if the sign in attempt failed. Raises an exception on communication failure.
  Future<AuthData?> signIn(String email, String password) async {
    if (_authData != null) {
      throw AuthenticationStateError("Cannot login while currently logged in",
          loginRequired: false);
    }
    final jsonData = await postJsonObject(
        serverUrl.resolve("api/authenticate"), <String, dynamic>{
      "username": email,
      "password": password,
      // Currently always false, unclear if it matters
      "rememberMe": false
    });
    // JSON response will only contain the bearer token
    final token = jsonData["id_token"];
    if (token is! String) {
      // Missing or otherwise invalid
      throw const InvalidResponseException(
          'Missing or invalid "id_token" from server');
    }
    final auth = AuthData(_getIdFromJWT(token), email, token);
    // Set authData through the setter so listeners get fired
    authData = auth;
    return auth;
  }

  /// Signs out.
  Future<void> signOut() {
    if (_authData == null) {
      throw AuthenticationStateError("Cannot sign out when not signed in");
    }
    authData = null;
    // In the future this may invoke a server call to invalidate the session or something, but for now, it just
    // discards the authentication data.
    return Future.value();
  }

  /// Get an ID from a JWT. Throws an InvalidResponseException if the JWT is missing the patient ID.
  Id _getIdFromJWT(String token) {
    try {
      final parsedToken = jwt.Token.parse(token);
      _log.info('Received JWT $parsedToken');
      final id = parsedToken.payload['patient'];
      if (id is! String) {
        throw const InvalidResponseException(
            'Missing or invalid "patient" in JWT payload');
      }
      return Id(id);
    } on FormatException catch (error) {
      throw InvalidResponseException(
          'Invalid JWT from server: ${error.message}');
    }
  }

  /// Attempts to create an account. Throws an exception on error. Accounts are created inactive and unverified and
  /// cannot be initially used. If the future completes successfully, the account has been created but is inactive.
  ///
  /// Both `duaAccepted` and `ageAttested` must be true. If they are false, this method will throw an ArgumentError
  /// and refuse to continue.
  Future<void> createAccount(
    String email,
    String password, {
    required DataUseAgreement dataUseAgreement,
    required bool duaAccepted,
    required bool ageAttested,
    String? firstName,
    String? lastName,
  }) async {
    if (_authData != null) {
      throw AuthenticationStateError(
          "Cannot create an account while currently logged in",
          loginRequired: false);
    }
    if (!duaAccepted) {
      throw ArgumentError.value(
          duaAccepted, "duaAccepted", "User must accept data use agreement");
    }
    if (!ageAttested) {
      throw ArgumentError.value(
          duaAccepted, "ageAttested", "User must indicate they are 18 or older");
    }
    // The way this currently works involves first creating the account and then automatically attempting to log in to
    // the newly created account.
    final requestJson = <String, dynamic>{
      "login": email,
      "email": email,
      "password": password,
      // It's unclear if this is needed, but keep it for now:
      "langKey": "en",
      "authorities": <String>["ROLE_USER"],
      "userDUADTO": {
        "active": duaAccepted,
        "version": dataUseAgreement.version,
        "ageAttested": ageAttested
      }
    };
    if (firstName != null) {
      requestJson["firstName"] = firstName;
    }
    if (lastName != null) {
      requestJson["lastName"] = lastName;
    }
    final request = http.Request('POST', serverUrl.resolve("api/register"));
    request.headers['Content-type'] = 'application/json; charset=UTF-8';
    request.body = json.encode(requestJson);
    final response = await client.send(request);
    if (response.statusCode != 201) {
      throw await ServerErrorException.fromStreamedResponse(
          response, 'Error creating account');
    }
    // If here, the account was created successfully
  }

  /// Requests a password reset email be sent to the given email.
  ///
  /// A success doesn't necessarily mean an email was sent - attempting to reset accounts that do not exist will also
  /// receive a success response. It just means the server received and handled the request.
  Future<void> requestPasswordReset(String email) async {
    final request = http.Request(
        'POST', serverUrl.resolve("api/account/reset-password/init"));
    request.headers['Content-type'] = 'text/plain; charset=UTF-8';
    // JSON body is just the email as a JSON string
    request.body = email;
    final response = await client.send(request);
    if (response.statusCode != 200) {
      throw await ServerErrorException.fromStreamedResponse(
          response, 'Error resetting password');
    }
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
      throw AuthenticationStateError("No current session");
    }
    final uri = fhirBase.resolve("Patient/$patientId");
    final jsonObject = await getJsonObject(uri);
    return Patient.fromJson(jsonObject);
  }

  /// Attempts to query a given resource.
  ///
  /// This method will raise a [AuthenticationStateError] if invoked when [isSignedIn] is false. For a list of valid query
  /// parameters, see the [FHIR documentation](https://hl7.org/fhir/R4/search.html).
  Future<Bundle> queryResource(String name,
      [Map<String, dynamic>? query]) async {
    final patientId = _authData?.id.toString();
    if (patientId == null) {
      throw AuthenticationStateError("No current session");
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
  ///
  /// This does not handle error response from the server - in fact, it doesn't even see them, as the Future will
  /// resolve with the StreamedResponse before the error can be parsed.
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // If we have a bearer token, set it
    final authData = _authData;
    if (authData != null) {
      request.headers['Authorization'] = authData.bearerToken;
    }
    _log.finer('Sending request $request');
    return client.send(request);
  }

  /// Sends a request, including some basic error processing. If the server response is an error, this will throw a
  /// [ServerErrorException]. If the server indicates that the session has expired, this will reset [authData] to `null`
  /// and presently resolve. In the future it may trigger a method to handle logging back in.
  Future<http.Response> sendRequest(http.BaseRequest request) async {
    final streamedResponse = await send(request);
    final response = await http.Response.fromStream(streamedResponse);
    _log.finer('Received response $response');
    if (response.statusCode >= 200 && response.statusCode < 299) {
      // Success: return as-is
      return response;
    } else if (response.statusCode == 401) {
      _log.info(
          'Received 401 Not Authorized response, invalidating session (if set)');
      // For now, ignore the actual response, just invalidate the token
      authData = null;
      throw ServerErrorException.fromResponse(response, 'Session is invalid');
    } else {
      throw ServerErrorException.fromResponse(
          response, 'Server returned an error');
    }
  }

  /// Sends a request, parsing the response as a JSON object and returning that JSON object.
  ///
  /// This wraps [send] and therefore may throw [http.ClientException]. If the response cannot be parsed as JSON, this
  /// will throw a [FormatException]. If it can be parsed but does not contain a JSON object, it will throw a
  /// [InvalidResponseException]. If the server response is an error, this will throw a [ServerErrorException]. If the
  /// server indicates that the session has expired, this will reset [authData] to `null` and presently resolve. In the
  /// future it may trigger a method to handle logging back in.
  Future<Map<String, dynamic>> sendJsonRequest(http.BaseRequest request) async {
    final response = await sendRequest(request);
    final parsed = json.decode(response.body);
    if (parsed is Map<String, dynamic>) {
      return parsed;
    } else {
      throw const InvalidResponseException('Expected a JSON object response.');
    }
  }

  Future<List<dynamic>> sendJsonArrayRequest(http.BaseRequest request) async {
    final response = await sendRequest(request);
    final parsed = json.decode(response.body);
    if (parsed is List<dynamic>) {
      return parsed;
    } else {
      throw const InvalidResponseException('Expected a JSON array response.');
    }
  }

  /// Send a JSON object and receive a JSON object in response. This wraps [sendJsonRequest] and generates a
  /// [http.Request] containing the given object as the HTTP body.
  Future<Map<String, dynamic>> sendJsonObject(
    String method,
    Uri uri,
    Map<String, dynamic> object,
  ) {
    final request = http.Request(method, uri);
    request.headers['Content-Type'] = 'application/json; charset=UTF-8';
    request.body = json.encode(object);
    return sendJsonRequest(request);
  }

  /// Sends a GET query to a specific FHIR resource and retrieve a parsed JSON object.
  ///
  /// This does not attempt to compartmentalize to a given patient.
  Future<Map<String, dynamic>> getJsonObjectFromResource(
    String resource, [
    Map<String, dynamic>? queryParameters,
  ]) {
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
  Future<Map<String, dynamic>> postJsonObject(
    Uri url,
    Map<String, dynamic> object,
  ) {
    return sendJsonObject('POST', url, object);
  }

  /// Helper method for PUTting a JSON object to the server and receiving a JSON object as a response. This wraps
  /// [sendJsonRequest] and can throw exceptions it can.
  Future<Map<String, dynamic>> putJsonObject(
    Uri url,
    Map<String, dynamic> object,
  ) {
    return sendJsonObject('PUT', url, object);
  }

  /// Sends a process message with the given set of resources.
  Future<Map<String, dynamic>> sendProcessMessage(
    Iterable<Map<String, dynamic>> resources, {
    String? fhirVersion,
    String? endpoint,
  }) {
    final authData = _authData;
    if (authData == null) {
      throw AuthenticationStateError(
          "Cannot post message when not authenticated");
    }

    // avoids 422 error from API
    if (resources.isEmpty) {
      throw const InvalidResourceException("No records avalable.");
    }

    // Build a bundle based on that
    final bundle = <String, dynamic>{
      "resourceType": "Bundle",
      "type": "message",
      "entry": <Map<String, dynamic>>[
        <String, dynamic>{
          "resource": authData.createHeader(endpoint: endpoint).toJson()
        },
        ...resources.map<Map<String, dynamic>>((resource) {
          // Create an individual entry
          return <String, dynamic>{"resource": resource};
        })
      ]
    };
    var uri = fhirBase.resolve("\$process-message");
    _log.fine('Sending process message: ${json.encode(bundle)}');
    if (fhirVersion != null) {
      uri = uri.replace(queryParameters: {"fhir_version": fhirVersion});
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
      throw const InvalidResourceException(
          "Cannot post resources without a type (they are invalid)");
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
  Future<Map<String, dynamic>> postJsonObjectToResource(
    String resource,
    Map<String, dynamic> object,
  ) {
    return postJsonObject(fhirBase.resolve(resource), object);
  }

  /// Helper method for putting a JSON object to a specific FHIR resource on the server, and receiving a JSON object as
  /// a response.
  Future<Map<String, dynamic>> putJsonObjectToResourceId(
    String resource,
    String id,
    Map<String, dynamic> object,
  ) {
    return putJsonObject(fhirBase.resolve("$resource/$id"), object);
  }

  /// Utility function for parsing a DateTime generated by the OpenHealthManager
  /// backend. Throws a FormatException if the DateTime cannot be parsed.
  static DateTime parseDateTime(String dateTime) {
    // For now, just use DateTime.parse directly. It's looser in what it
    // accepts than dates generated by the server are expected to be, but that's
    // fine.
    return DateTime.parse(dateTime);
  }
}
