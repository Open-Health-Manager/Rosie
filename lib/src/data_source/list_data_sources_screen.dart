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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_config.dart';
import '../open_health_manager/consents.dart';
import '../open_health_manager/open_health_manager.dart';
import '../open_health_manager/patient_data.dart';
import 'health_kit_connection_screen.dart';

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

class _DataSourceTile extends StatefulWidget {
  const _DataSourceTile({
    Key? key,
    required this.consent,
    required this.cupertinoSwitch,
  }) : super(key: key);

  final PatientConsent consent;
  final bool cupertinoSwitch;

  @override
  State<StatefulWidget> createState() => _DataSourceTileState();
}

class _DataSourceTileState extends State<_DataSourceTile> {
  Future? _changeFuture;
  bool _currentApprove = false;

  /// The most up-to-date version of the consent, as retrieved from the server.
  late PatientConsent _currentConsent;

  @override
  void initState() {
    super.initState();
    _currentApprove = widget.consent.approve;
    _currentConsent = widget.consent;
  }

  Widget _createSwitch(BuildContext context) {
    if (_changeFuture == null) {
      // Show the switch if it's not changing
      if (widget.cupertinoSwitch) {
        return CupertinoSwitch(
          value: _currentApprove,
          onChanged: changeApproval,
        );
      } else {
        return Switch(
          value: _currentApprove,
          onChanged: changeApproval,
        );
      }
    } else {
      // If the future is ongoing, show a progress spinner
      return const CircularProgressIndicator(
        semanticsLabel: 'Sending change',
      );
    }
  }

  void changeApproval(bool newValue) {
    setState(() {
      final future = _updateApproval(newValue);
      _changeFuture = future.then((result) {
        // These changes don't modify the widget's state so do them now - well,
        // sort of, the _currentApprove is used to indicate the switch state,
        // but that will happen later.
        _currentApprove = result.approve;
        _currentConsent = result;
        if (result.approve) {
          // FIXME: This works short term but a better method of finding
          // "post-approve UI" needs to be designed.
          // For now, if the URI for the client sent is HealthKit, trigger that
          if (widget.consent.client.uri ==
              'https://developer.apple.com/health-fitness/') {
            if (mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text("Connect to HealthKit")),
                    body: const HealthKitConnectionScreen(),
                  ),
                ),
              );
            }
          }
        }
      }).whenComplete(() {
        // Ensure that no matter what happens, the _changeFuture is unset
        setState(() {
          _changeFuture = null;
        });
      });
    });
  }

  Future<PatientConsent> _updateApproval(bool approve) async {
    final patientData = context.read<PatientData>();
    final healthManager = context.read<OpenHealthManager>();
    // First, grab the account information
    final account = await patientData.account.get();
    return await healthManager.updatePatientConsent(
        _currentConsent, account, approve);
  }

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
                child:
                    _DataSourceDescription(dataSource: widget.consent.client),
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
              return Center(
                  child:
                      Text('Error fetching data sources: ${snapshot.error}'));
            } else {
              final consents = snapshot.data;
              final cupertino = context.read<AppConfig>().useCupertinoWidgets;
              if (consents == null || consents.isEmpty) {
                return const Center(child: Text("No data sources."));
              } else {
                return ListView.builder(
                  itemBuilder: (context, index) => _DataSourceTile(
                    consent: consents[index],
                    cupertinoSwitch: cupertino,
                  ),
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
