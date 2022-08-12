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

class FieldError {
  const FieldError(this.field, this.message);

  final String field;
  final String message;

  static FieldError fromJson(dynamic jsonData) {
    if (jsonData is Map<String, dynamic>) {
      // Attempt to pull out the two field
      final field = jsonData['field'];
      final message = jsonData['message'];
      if (field is String && message is String) {
        return FieldError(field, message);
      }
    }
    throw const FormatException('Could not parse field error');
  }

  /// Parses a list of JSON field errors.
  static List<FieldError> fromJsonList(List<dynamic> fieldErrors) {
    return fieldErrors
        .map((error) => FieldError.fromJson(error))
        .toList(growable: false);
  }
}

/// Represents a parsed error message from the server.
class ServerErrorMessage {
  const ServerErrorMessage({
    this.title,
    this.message,
    required this.fieldErrors,
  });

  final String? title;
  final String? message;
  final List<FieldError> fieldErrors;

  /// Attempts to parse a server error message. If given a JSON object, this
  /// will populate the JSON fields. If given a list, assumes it's a list and
  /// returns an object only containing that. Otherwise, raises a
  /// [FormatException].
  static ServerErrorMessage fromJson(dynamic jsonData) {
    // Allow two types here: a list, and an object
    if (jsonData is List<dynamic>) {
      // In this case, create the objects from that
      return ServerErrorMessage(fieldErrors: FieldError.fromJsonList(jsonData));
    } else if (jsonData is Map<String, dynamic>) {
      final title = jsonData["title"];
      final message = jsonData["message"];
      final fieldErrors = jsonData["fieldErrors"];
      return ServerErrorMessage(
        title: title is String ? title : null,
        message: message is String ? message : null,
        fieldErrors: fieldErrors is List<dynamic>
            ? FieldError.fromJsonList(fieldErrors)
            : [],
      );
    }
    // Otherwise, not parseable
    throw const FormatException(
        'Unable to parse field errors: invalid object type');
  }
}
