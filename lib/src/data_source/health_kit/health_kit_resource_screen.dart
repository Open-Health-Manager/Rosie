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
import 'package:flutter/material.dart';
import 'health_kit.dart';

/// Intended mostly for debugging, this shows information about a
/// HealthKitResource. It should be embedded within a Material Scaffold.
class HealthKitResourceScreen extends StatelessWidget {
  const HealthKitResourceScreen({
    Key? key,
    required this.resource,
  }) : super(key: key);

  final HealthKitResource resource;

  @override
  Widget build(BuildContext context) {
    final keys = resource.resource.keys.toList(growable: false);
    return ListView(
      children: <Widget>[
        ListTile(
          title: const Text('FHIR Version'),
          trailing: Text(
            _fhirVersionString(resource.fhirVersion),
          ),
        ),
        ...keys.map(
          (key) => ListTile(
            title: Text(key),
            subtitle: SelectableText(_formatValue(key, resource.resource[key])),
          ),
        ),
      ],
    );
  }
}

String _fhirVersionString(FhirVersion version) {
  switch (version) {
    case FhirVersion.dstu2:
      return "DSTU2";
    case FhirVersion.r4:
      return "R4";
    default:
      return "Unknown";
  }
}

String _formatValue(String key, dynamic value) {
  if (value == null) {
    return "null";
  }
  // If the key is "encoded" then see if it's base64 encoded and can be
  // converted back to a text string
  if (key == 'data' && value is String) {
    try {
      final binary = base64.decode(value);
      // See if it can be decoded into a string
      return utf8.decode(binary);
    } on FormatException catch (_) {
      // FormatException can happen on either the base64 decode or the UTF8
      // decode. In both cases, it doesn't matter, just return the original
      // string
      return value;
    }
  }
  return value.toString();
}
