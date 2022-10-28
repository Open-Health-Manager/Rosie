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

import 'package:faiadashu/faiadashu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../open_health_manager/open_health_manager.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen(
      {super.key, required this.questionnaire, required this.locale});

  final String questionnaire;
  final Locale locale;

  @override
  State<StatefulWidget> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  String? _error;
  LaunchContext? _launchContext;
  late AssetResourceProvider _resourceProvider;

  @override
  void initState() {
    super.initState();
    _resourceProvider = AssetResourceProvider.singleton(
      questionnaireResourceUri,
      widget.questionnaire,
    );
    _createModel().then((model) {
      setState(() {
        _launchContext = model.launchContext;
      });
    }, onError: (error) {
      setState(() {
        if (error != null) {
          _error = error.toString();
        } else {
          _error = 'Unable to load questionnaire';
        }
      });
    });
  }

  Future<QuestionnaireResponseModel> _createModel() async {
    // Grab locale before any async code
    final patient = await context.read<OpenHealthManager>().queryPatient();
    final launchContext = LaunchContext(patient: patient);
    final model = await QuestionnaireResponseModel.fromFhirResourceBundle(
      locale: widget.locale,
      fhirResourceProvider: _resourceProvider,
      launchContext: launchContext,
    );
    return model;
  }

  @override
  Widget build(BuildContext context) {
    final launchContext = _launchContext;
    if (launchContext == null) {
      return _error != null
          ? Center(child: Text('Error getting patient: $_error'))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                CircularProgressIndicator(),
                Text('Getting patient data...'),
              ],
            );
    }
    return QuestionnaireScrollerPage(
      fhirResourceProvider: _resourceProvider,
      launchContext: launchContext,
    );
  }
}
