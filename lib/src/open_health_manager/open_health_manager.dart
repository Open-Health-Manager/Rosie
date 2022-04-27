import 'dart:convert';
import 'package:http/http.dart' as http;

class InternalException implements Exception {
  InternalException(this.message);
  final String message;

  @override
  String toString() {
    return "Internal Error: $message";
  }
}

class NoUserException implements Exception {
  NoUserException(this.message);
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

// Provides APIs for accessing parts of Open Health Manager.
class OpenHealthManager {
  final Uri fhirBase;

  const OpenHealthManager({required this.fhirBase});

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

  // Attempts to sign in. Throws exception on failure.
  signIn(String email, String password) async {
    final url = fhirBase.resolve("Patient").replace(queryParameters: {
      "identifier": "urn:mitre:healthmanager:account:username|$email"
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // Must parse, as the response will indicate if it worked
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      // In the decoded response, see if the user exists
      if (decodedResponse["resourceType"] != "Bundle") {
        throw InternalException("Invalid response from server");
      }
      if (decodedResponse["total"] is num) {
        if (decodedResponse["total"] == 0) {
          throw NoUserException("No such user $email");
        } else if (decodedResponse["total"] >= 1) {
          // Got a user
          return;
        }
      }
      throw InternalException("Unable to parse response from server.");
    } else {
      throw InternalException("Unexpected response from server: ${response.statusCode} ${response.reasonPhrase}");
    }
  }

  // Attempts to create an account. Throws an exception on error.
  createAccount(String fullName, String email) async {
    final url = fhirBase.resolve("Patient");
    final response = await http.post(url, headers: {
      "Content-type": "application/json"
    }, body: jsonEncode({
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
    }));
    // See if we can understand the response.
    if (response.statusCode == 201) {
      // TODO: Parse the response and ensure it's OK
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      print("Received response:");
      print(decodedResponse);
    } else {
      throw InternalException("Unexpected response from server: ${response.statusCode} ${response.reasonPhrase}");
    }
  }
}