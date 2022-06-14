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
import 'package:fhir/r4.dart' show Id;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rosie/src/open_health_manager/jwt_token.dart';
import 'package:rosie/src/open_health_manager/open_health_manager.dart';
import 'open_health_manager.mocks.dart';

/// Used to match only parts of a request (basically, ignore extra headers)
class RequestMatcher extends Matcher {
  RequestMatcher(this.method, this.url, {this.body, this.headers = const <String,String>{}});

  final String method;
  final Uri url;
  final Matcher? body;
  final Map<String, String> headers;

  @override
  Description describe(Description description) {
    return description.add('Request $method $url');
  }

  @override
  bool matches(item, Map matchState) {
    if (item is http.Request) {
      // Basic checks first:
      if (item.method != method || item.url != url) {
        return false;
      }
      final bodyMatcher = body;
      // If the body matcher is not null, just ignore the body
      if (bodyMatcher != null && !bodyMatcher.matches(item.body, matchState)) {
        return false;
      }
      // Make sure headers match
      for (final entry in headers.entries) {
        if (item.headers[entry.key] != entry.value) {
          return false;
        }
      }
      // If finally down here, it matched
      return true;
    } else {
      // Not a request? Doesn't match
      return false;
    }
  }
}

RequestMatcher matchesRequest(String method, Uri url, {Matcher? body, headers = const <String,String>{}})
  => RequestMatcher(method, url, body: body, headers: headers);

@GenerateMocks([http.Client])
void main() {
  final testBaseUri = Uri.https('localhost:8080', '');
  group('account login', () {
    test('fetches bearer token', () async {
      final client = MockClient();
      // The response needs to contain a valid JWT token
      final token = Token({"alg":"none"}, {"patient": "42"}).encoded();
      final response = http.StreamedResponse(
        Stream.value(
          utf8.encode(
            json.encode({
              "id_token": token
            })
          )
        ), 200);
      when(
        client.send(
          argThat(
            matchesRequest(
              'POST',
              Uri.https('localhost:8080', '/api/authenticate'),
              body: equals('{"username":"testuser","password":"password","rememberMe":false}')
            )
          )
        )
      ).thenAnswer((_) async => response);
      final testManager = OpenHealthManager.forServerURL(testBaseUri, client: client);
      final authData = await testManager.signIn("testuser", "password");
      verify(client.send(any)).called(1);
      expect(authData, isNotNull);
      // Now repeat that Dart knows it isn't null locally
      if (authData != null) {
        expect(authData.bearerToken, equals('Bearer ' + token));
        expect(authData.id, equals(Id("42")));
      }
    });

    test('uses bearer token', () async {
      final client = MockClient();
      final response = http.StreamedResponse(Stream.value('{"hello":"world"}'.codeUnits), 200);
      when(
        client.send(argThat(matchesRequest('GET', Uri.https('localhost:8080', '/fhir/Patient'))))
      ).thenAnswer((_) async => response);
      final testManager = OpenHealthManager.forServerURL(testBaseUri, client: client);
      testManager.authData = AuthData(Id('1'), 'test', 'Bearer example_token', false);
      // Don't care about the result for this text
      await testManager.getJsonObject(Uri.https('localhost:8080', '/fhir/Patient'));
      expect(verify(client.send(captureAny)).captured.single.headers, containsPair('Authorization', 'Bearer example_token'));
    });
  });
}