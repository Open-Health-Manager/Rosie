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

// This shows the getting started page.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data_source/list_data_sources_screen.dart';
import '../rosie_text_balloon.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Get Started with Preventative Health Check",
              style: GoogleFonts.ubuntu(fontSize: 24.0),
            ),
            const SizedBox(height: 20),
            // const SizedBox(width: 238, height: 214, child: Placeholder()),
            const Expanded(child: SizedBox()),
            RosieTextBalloon.text(
              "Looks like you don\u2019t have any health data sources yet. Connect your health data to have a more complete view of your own health.",
              action: ElevatedButton(
                child: const Text("Connect Data & Services"),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ListDataSourcesScreen()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
