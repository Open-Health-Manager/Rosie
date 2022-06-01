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
import 'package:rosie/src/open_health_manager/patient_data.dart';
import 'package:rosie/src/open_health_manager/smoking_status.dart';

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
  ServerErrorException.fromResponse(http.Response response, String message)
      : this(response.statusCode, response.reasonPhrase, message);

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

/// Thrown when the configuration information given in the config object is invalid.
class InvalidConfigError extends Error {
  InvalidConfigError(this.message) : super();
  final String message;

  @override
  String toString() {
    return message;
  }
}

extension ToSnomed on SmokingStatus {
  String? toTaskForceAPIParam() {
    switch (this) {
      case SmokingStatus.unknown:
        return null;
      case SmokingStatus.neverSmoked:
        return "N";
      case SmokingStatus.formerSmoker:
        return "N";
      case SmokingStatus.currentSmoker:
        return "Y";
    }
  }
}

/// Provides APIs for accessing parts of Open Health Manager.
/// This also holds on to the authentication information.
class PreventativeServicesTaskForce with ChangeNotifier {
  PreventativeServicesTaskForce({required this.apiKey});

  /// The api key used to authenticate requests
  ///
  /// Resolved URIs are created via [fhirBase.resolve].
  final String apiKey;
  final Uri _serviceURL =
      Uri.parse("https://data.uspreventiveservicestaskforce.org/api/json");

  static PreventativeServicesTaskForce fromConfig(Map<String, dynamic> config) {
    if (!config.containsKey("uspstfAPIKey")) {
      throw InvalidConfigError('Missing required key "uspstfAPIKey"');
    }
    var apiKey = config["uspstfAPIKey"];
    if (apiKey is String) {
      return PreventativeServicesTaskForce(apiKey: apiKey);
    } else {
      throw InvalidConfigError('Invalid value for key "uspstfAPIKey": $apiKey');
    }
  }

  Future<Map<String, dynamic>?> getRecommendedServicesForPatient(
      PatientData? patientData) async {
    final smokingStatusList = await patientData?.smokingStatus.get();
    final smokingStatusValue =
        (smokingStatusList != null && smokingStatusList.isNotEmpty)
            ? smokingStatusList[0].smokingStatus
            : null;
    final demographics = await patientData?.patientDemographics.get();
    final int? age = (demographics != null && demographics.dateOfBirth != null)
        ? DateTime.now().difference(demographics.dateOfBirth!).inDays ~/ 365
        : null;
    String? gender = (demographics != null && demographics.gender != null)
        ? demographics.gender
        : null;

    return await getRecommendedServices(
        age, gender, null, smokingStatusValue?.toTaskForceAPIParam(), null);
  }

  Future<Map<String, dynamic>> getRecommendedServices(int? age, String? sex,
      bool? pregnant, String? tobaccoUser, bool? sexuallyActive) {
    final queryParameters = <String, dynamic>{};
    if (age != null) {
      queryParameters.addAll(<String, dynamic>{"age": age.toString()});
    }
    if (sex != null) {
      queryParameters.addAll(<String, dynamic>{"sex": sex});
    }
    if (pregnant != null) {
      queryParameters
          .addAll(<String, dynamic>{"pregnant": pregnant ? "Y" : "N"});
    }
    if (tobaccoUser != null) {
      queryParameters.addAll(<String, dynamic>{"tobaccoUser": tobaccoUser});
    }
    if (sexuallyActive != null) {
      queryParameters.addAll(
          <String, dynamic>{"sexuallyActive": sexuallyActive ? "Y" : "N"});
    }
    return getRecommendedServicesQuery(queryParameters);
  }

  /// Attempts to get recommended services based on inputs
  /// as a query map
  ///
  Future<Map<String, dynamic>> getRecommendedServicesQuery(
      [Map<String, dynamic>? query]) async {
    final queryParameters = <String, dynamic>{
      "key": apiKey,
      "grade": <String>["A", "B"],
      "tools": "N"
    };
    if (query != null) {
      queryParameters.addAll(query);
    }
    final Uri targetURI = _serviceURL.replace(queryParameters: queryParameters);
    final Uri copy = targetURI;
    log("targetURI: " + targetURI.toString());
    return await getJsonObject(targetURI);
  }

  /// Parse a response as a JSON object, throwing an [InvalidResponseException] if the JSON response isn't a JSON object.
  /// Throws a [FormatException] if the given data cannot be parsed as JSON.
  Map<String, dynamic> _parseJsonResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 299) {
      final parsed = json.decode(response.body);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      } else {
        throw const InvalidResponseException(
            'Expected a JSON object response.');
      }
    } else {
      throw ServerErrorException.fromResponse(
          response, 'Server returned an error');
    }
  }

  /// Helper method designed to ensure the result from the server was a JSON object.
  ///
  /// If the response cannot be parsed as JSON, this will throw a [FormatException]. If the response can be parsed as
  /// JSON but is otherwise invalid, throws a [InvalidResponseException].
  Future<Map<String, dynamic>> getJsonObject(Uri uri) async {
    return _parseJsonResponse(await http.get(uri));
  }
}
