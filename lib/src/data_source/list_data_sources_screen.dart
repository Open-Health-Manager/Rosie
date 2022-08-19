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

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../open_health_manager/open_health_manager.dart';
import '../open_health_manager/consents.dart';

class _DataSourceDescription extends StatelessWidget {
  const _DataSourceDescription({Key? key, required this.dataSource})
      : super(key: key);

  final FHIRClient dataSource;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          dataSource.displayName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 2),
        // Don't have a description for now
        Text(
          'Description',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.caption,
        ),
        Expanded(child: Container()),
      ],
    );
  }
}

class _DataSourceTile extends StatelessWidget {
  const _DataSourceTile({Key? key, required this.consent}) : super(key: key);

  final PatientConsent consent;

  Widget _createSwitch(BuildContext context) {
    if (Platform.isIOS || Platform.isMacOS) {
      return CupertinoSwitch(
        value: consent.approve,
        onChanged: changeApproval,
      );
    } else {
      return Switch(
        value: consent.approve,
        onChanged: changeApproval,
      );
    }
  }

  void changeApproval(bool newValue) {}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: SizedBox(
        height: 120,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Force the icon into a 72x72 box
            // Currently don't have a way to get the icon
            const SizedBox(
              width: 72.0,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Placeholder(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 2, 0),
                child: _DataSourceDescription(dataSource: consent.client),
              ),
            ),
            _createSwitch(context),
          ],
        ),
      ),
    );
  }
}

class ListDataSourcesScreen extends StatefulWidget {
  const ListDataSourcesScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ListDataSourcesState();
}

class _ListDataSourcesState extends State<ListDataSourcesScreen> {
  late Future<List<PatientConsent>> _patientConsentFuture;

  @override
  initState() {
    super.initState();
    _patientConsentFuture =
        context.read<OpenHealthManager>().getAllPatientConsents();
  }

  Widget _buildDataSourceList(BuildContext context) {
    return FutureBuilder(
        future: _patientConsentFuture,
        builder: (context, AsyncSnapshot<List<PatientConsent>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Show the list
            if (snapshot.hasError) {
              return Center(child: Text('Error fetching data sources: ${snapshot.error}'));
            } else {
              final consents = snapshot.data;
              if (consents == null || consents.isEmpty) {
                return const Center(child: Text("No data sources."));
              } else {
                return ListView.builder(
                  itemBuilder: (context, index) =>
                      _DataSourceTile(consent: consents[index]),
                  itemCount: consents.length,
                );
              }
            }
          } else {
            return Center(
              child: Column(
                children: const [
                  CircularProgressIndicator(),
                  Text("Finding available data sources..."),
                ],
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connect Data & Services")),
      body: _buildDataSourceList(context),
    );
  }
}
