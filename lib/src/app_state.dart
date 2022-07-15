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

import 'package:flutter/foundation.dart';

/// Rosie app state. This represents parts of Rosie that are app-specific.
class AppState with ChangeNotifier {
  bool _initialLogin = false;

  bool get initialLogin => _initialLogin;

  set initialLogin(bool newValue) {
    _initialLogin = newValue;
    notifyListeners();
  }
}