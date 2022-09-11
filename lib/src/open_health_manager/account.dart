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

import 'open_health_manager.dart';

/// Represents an account within the Open Health Manager.
class Account {
  const Account({
    required this.id,
    required this.login,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.imageUrl,
    required this.activated,
    required this.langKey,
    required this.createdBy,
    required this.createdDate,
    required this.lastModifiedBy,
    required this.lastModifiedDate,
    required this.authorities,
  });
  final int id;
  final String login;
  final String firstName;
  final String lastName;
  final String email;
  final String? imageUrl;
  final bool activated;
  final String langKey;
  final String createdBy;
  final DateTime createdDate;
  final String lastModifiedBy;
  final DateTime lastModifiedDate;
  final List<String> authorities;

  static Account fromJson(dynamic jsonData) {
    if (jsonData is Map<String, dynamic>) {
      final id = jsonData["id"];
      final login = jsonData["login"];
      final firstName = jsonData["firstName"];
      final lastName = jsonData["lastName"];
      final email = jsonData["email"];
      final imageUrl = jsonData["imageUrl"];
      final activated = jsonData["activated"];
      final langKey = jsonData["langKey"];
      final createdBy = jsonData["createdBy"];
      final createdDateString = jsonData["createdDate"];
      final lastModifiedBy = jsonData["lastModifiedBy"];
      final lastModifiedDateString = jsonData["lastModifiedDate"];
      final authoritiesJson = jsonData["authorities"];
      if (authoritiesJson is List<dynamic>) {
        final authorities = authoritiesJson.whereType<String>().toList();
        if (id is num &&
            login is String &&
            firstName is String &&
            lastName is String &&
            email is String &&
            (imageUrl is String || imageUrl == null) &&
            activated is bool &&
            langKey is String &&
            createdBy is String &&
            createdDateString is String &&
            lastModifiedBy is String &&
            lastModifiedDateString is String) {
          // One last parse step - parse dates
          final createdDate =
              OpenHealthManager.parseDateTime(createdDateString);
          final lastModifiedDate =
              OpenHealthManager.parseDateTime(lastModifiedDateString);
          return Account(
            id: id.toInt(),
            login: login,
            firstName: firstName,
            lastName: lastName,
            email: email,
            imageUrl: imageUrl,
            activated: activated,
            langKey: langKey,
            createdBy: createdBy,
            createdDate: createdDate,
            lastModifiedBy: lastModifiedBy,
            lastModifiedDate: lastModifiedDate,
            authorities: authorities,
          );
        }
        // If parsing fails, fall through to the final exception
      }
    }
    print('Unable to parse $jsonData');
    throw const FormatException('Unable to parse Account object');
  }
}

extension AccountQuerying on OpenHealthManager {
  Future<Account> getAccount() async {
    // Account data should be determined by the JWT
    if (authData == null) {
      throw AuthenticationStateError('Account data only exists when logged in');
    }
    return Account.fromJson(
        await getJsonObject(serverUrl.resolve("api/account")));
  }
}
