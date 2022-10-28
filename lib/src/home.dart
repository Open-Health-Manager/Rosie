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

// The home screen

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'account_settings/account_settings.dart';
import 'care_plan/care_plan_home.dart';
import 'get_started/get_started.dart';
import 'questionnaire/questionnaire_screen.dart';
import 'app_config.dart';
import 'app_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Selected tab
  late int _selectedIndex;
  String? _uspstfApiKey;

  @override
  void initState() {
    super.initState();
    _selectedIndex = context.read<AppState>().initialLogin ? 1 : 0;
    // Grab the API key if possible
    _uspstfApiKey = context.read<AppConfig>().getString("uspstfApi.key");
  }

  _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _addRosieBackground(Widget child) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark, child: child);
  }

  Widget _buildSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _addRosieBackground(
          Center(
            child: _uspstfApiKey == null
                ? const Text("Not configured (API key missing)")
                : CarePlanHome(apiKey: _uspstfApiKey!),
          ),
        );
      case 1:
        return _addRosieBackground(const Center(child: GetStarted()));
      case 3:
        return QuestionnaireScreen(
          questionnaire:
              'assets/Questionnaire-SDOHCC-QuestionnairePRAPARE.json',
          locale: Localizations.localeOf(context),
        );
      case 4:
        return _addRosieBackground(const AccountSettingsScreen());
      default:
        return _addRosieBackground(
            const Center(child: Text("Not Implemented")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: _buildSelectedPage(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: localizations.tabCarePlan,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.folder),
            label: localizations.tabRecords,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: localizations.tabPrivacy,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.question_mark),
            label: localizations.tabQuestionnaire,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_circle_outlined),
            label: localizations.tabHelp,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
