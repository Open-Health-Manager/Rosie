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
import 'package:faiadashu/faiadashu.dart';
import 'package:fhir/r4.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    _createLaunchContext().then((launchContext) {
      setState(() {
        _launchContext = launchContext;
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

  Future<LaunchContext> _createLaunchContext() async {
    // Grab locale before any async code
    final patient = await context.read<OpenHealthManager>().queryPatient();
    return LaunchContext(patient: patient);
  }

  Widget _submitButton(BuildContext context) {
    return Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () {
          final response = QuestionnaireResponseFiller.of(context)
              .aggregator<QuestionnaireResponseAggregator>()
              .aggregate(responseStatus: QuestionnaireResponseStatus.completed);
          if (response == null) {
            showDialog<void>(
              context: context,
              builder: (context) => const AlertDialog(
                title: Text('No response'),
                content: Text('Did not receive a response'),
              ),
            );
          } else {
            // For now, just display a dialog that show the response JSON
            showDialog<void>(
              context: context,
              builder: (context) {
                final jsonText = json.encode(response.toJson());
                return AlertDialog(
                  title: const Text('Response'),
                  content:
                      SingleChildScrollView(child: SelectableText(jsonText)),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: jsonText));
                      },
                      child: const Text('Copy'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        },
        child: const Text('Submit'),
      );
    });
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
    } else {
      return QuestionnaireScroller(
        scaffoldBuilder: _RosieQuestionnaireScaffoldBuilder(
          persistentFooterButtons: [_submitButton(context)],
        ),
        fhirResourceProvider: _resourceProvider,
        launchContext: launchContext,
      );
    }
  }
}

/// The default scaffold includes a back button that goes nowhere, along with a
/// few toolbar items that aren't needed. This provides a basic scaffold.
class _RosieQuestionnaireScaffoldBuilder
    extends QuestionnairePageScaffoldBuilder {
  const _RosieQuestionnaireScaffoldBuilder({this.persistentFooterButtons});

  final List<Widget>? persistentFooterButtons;

  @override
  Widget build(
    BuildContext context, {
    required void Function(void Function() p1) setStateCallback,
    required Widget child,
  }) {
    final questionnaire = QuestionnaireResponseFiller.of(context)
        .questionnaireResponseModel
        .questionnaireModel
        .questionnaire;
    return Scaffold(
      appBar: AppBar(
        title: Text(questionnaire.title ?? 'Survey'),
      ),
      body: child,
      floatingActionButton: const QuestionnaireFillerCircularProgress(),
      persistentFooterButtons: persistentFooterButtons,
    );
  }
}
