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
import 'package:provider/provider.dart';
import 'care_plan/care_plan_home.dart';
import 'get_started/get_started.dart';
import 'app_config.dart';
import 'app_state.dart';
import 'rosie_theme.dart';

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
    _selectedIndex = context.read<AppState>().initialLogin ? 2 : 1;
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
        child: Container(
          decoration: createRosieScreenBoxDecoration(),
          child: child
        ),
        value: SystemUiOverlayStyle.dark
      );
  }

  Widget _buildSelectedPage() {
    switch (_selectedIndex) {
      case 1:
        return _addRosieBackground(Center(
          child: _uspstfApiKey == null ?
            const Text("Not configured (API key missing)") :
            CarePlanHome(apiKey: _uspstfApiKey!)
          ));
      case 2:
        return _addRosieBackground(const Center(child: GetStarted()));
      default:
        return _addRosieBackground(const Center(child: Text("Not Implemented")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        child: _buildSelectedPage(),
        value: SystemUiOverlayStyle.dark
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Data Manager',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Care Plan'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_upward),
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.share),
            label: 'Community'
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped
      ),
    );
  }
}