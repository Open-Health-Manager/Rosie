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
import 'package:flutter_test/flutter_test.dart';
import 'package:rosie/src/open_health_manager/jwt_token.dart';

void main() {
  group('Token.parse', () {
    test('parses a token without a signature', () {
      // This is a very simple token
      final token = Token.parse(
        base64UrlEncode(utf8.encode('{"header":true}')) + '.' +
        base64UrlEncode(utf8.encode('{"payload":true}'))
      );
      expect(token.header, equals({'header': true}));
      expect(token.payload, equals({'payload': true}));
    });
    test('parses a token with a signature', () {
      // This is taken from https://jwt.io/ as an example token
      final token = Token.parse("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c");
      expect(token.header, equals({
        'alg': 'HS256',
        'typ': 'JWT'}
      ));
      expect(token.payload, equals({
        'iat': 1516239022,
        'name': 'John Doe',
        'sub': '1234567890'
      }));
    });
  });
}