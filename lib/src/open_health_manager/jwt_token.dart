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
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Decodes a JWT URL-encoded string. (Essentially, restores lost padding and
/// passes it through the base encoder.)
Uint8List base64UrlDecode(String s) {
  final String padded;
  switch(s.length % 4) {
    case 0:
      padded = s; break;
    case 2:
      padded = s + '=='; break;
    case 3:
      padded = s + '='; break;
    // Only possible value for default is 1 but use default so the compiler
    // knows padded must be set
    default:
      throw const FormatException('Invalid input string');
  }
  return base64.decode(padded);
}

/// Reverse of [base64UrlEncode], this removes any trailing '='.
String base64UrlEncode(List<int> bytes) {
  final result = (const Base64Encoder.urlSafe()).convert(bytes);
  if (result.endsWith('==')) {
    return result.substring(0, result.length - 2);
  } else if (result.endsWith('=')) {
    return result.substring(0, result.length - 1);
  } else {
    return result;
  }
}

/// Encodes the given string to UTF-8 and then uses [base64UrlEncode] to encode it.
String base64UrlEncodeString(String s) {
  return base64UrlEncode(utf8.encode(s));
}

/// A JWT token. This class holds the various parts of a JWT, it makes no
/// attempt to validate the token it contains itself.
class Token {
  /// Creates a JWT token with the given header and payload.
  Token(this.header, this.payload);

  final Map<String, dynamic> header;
  final Map<String, dynamic> payload;

  /// Parse a JWT. Throws FormatException if the token is invalid. This does not attempt to verify the signature, if
  /// present.
  static Token parse(String encodedToken) {
    // Must be at least one '.'
    final headerEndIndex = encodedToken.indexOf('.');
    if (headerEndIndex < 0) {
      throw FormatException('Invalid JWT token (no "." to mark end of header found)', encodedToken, 0);
    }
    final header = json.decode(
      utf8.decode(
        base64UrlDecode(encodedToken.substring(0, headerEndIndex)),
        allowMalformed: false
      )
    );
    // Make sure the header is an object
    if (header is! Map<String, dynamic>) {
      throw FormatException('Unexpected header: not a JSON object', encodedToken, 0);
    }
    final payloadEndIndex = encodedToken.indexOf('.', headerEndIndex + 1);
    // In this case, -1 is actually valid: it means there is no signature, which
    // is only valid when the algorithm is "none", but is still allowed
    final payload = json.decode(
      utf8.decode(
        base64UrlDecode(encodedToken.substring(headerEndIndex + 1, payloadEndIndex >= 0 ? payloadEndIndex : encodedToken.length)),
        allowMalformed: false
      )
    );
    return Token(header, payload);
  }

  /// Encodes the JWT into a String representation. As the generated JSON *may be different* from the source JSON (and
  /// the intended method for encoding the JSON), parsing and regenerating a token *may not create* the same text.
  ///
  /// If given an HMAC to sign, this will automatically use that on the generated header/payload text.
  ///
  /// Note that this does **not** modify the header! If given an invalid Hmac based on the JWT header within the token,
  /// this will happily encode a junk token.
  String encoded([Hmac? hmac]) {
    final body = base64UrlEncodeString(json.encode(header)) + '.' +
      base64UrlEncodeString(json.encode(payload));
    if (hmac != null) {
      Digest signature = hmac.convert(utf8.encode(body));
      return body + '.' + base64UrlEncode(signature.bytes);
    } else {
      return body;
    }
  }

  /// Returns the string representation of the JWT.
  @override
  String toString() {
    return '[Header: $header, Payload: $payload]';
  }
}