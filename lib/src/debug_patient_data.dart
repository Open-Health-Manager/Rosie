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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'open_health_manager/patient_data.dart';

/// Shows debug details in a Scaffold.
class DebugPatientDataScreen extends StatelessWidget {
  const DebugPatientDataScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Data'),
      ),
      body: const DebugPatientData(),
    );
  }
}

class _CachedDataTile<T> extends StatefulWidget {
  final CachedData<T> data;
  final String name;

  const _CachedDataTile({Key? key, required this.name, required this.data})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CachedDataTileState();
}

class _CachedDataTileState extends State<_CachedDataTile> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Get whether or not this is currently loading
    _loading = widget.data.state == LoadState.loading;
  }

  TextStyle _unloadedStyle(BuildContext context, [Color? color]) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium!.copyWith(
      fontStyle: FontStyle.italic,
      color: color ?? theme.textTheme.bodySmall!.color,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget trailing;
    Widget subtitle;
    if (_loading) {
      trailing = const CircularProgressIndicator();
    } else {
      trailing = TextButton(
        onPressed: () {
          setState(() {
            _loading = true;
            widget.data.reload().whenComplete(() {
              setState(() {
                _loading = false;
              });
            });
          });
        },
        child: widget.data.state == LoadState.unloaded
            ? const Icon(Icons.download)
            : const Icon(Icons.replay),
      );
    }
    switch (widget.data.state) {
      case LoadState.done:
        // If possible, load the data.
        subtitle = Text(widget.data.value.toString());
        break;
      case LoadState.loading:
        subtitle = Text(
          'Loading...',
          style: _unloadedStyle(context),
        );
        break;
      case LoadState.unloaded:
        subtitle = Text(
          'Empty (never loaded or cache emptied).',
          style: _unloadedStyle(context),
        );
        break;
      case LoadState.error:
        subtitle = Text(
          'Error while loading',
          style: _unloadedStyle(context, Theme.of(context).errorColor),
        );
        break;
    }
    return ListTile(
      title: Text(widget.name),
      subtitle: subtitle,
      trailing: trailing,
    );
  }
}

/// Provides more detailed information about the current environment
class DebugPatientData extends StatelessWidget {
  const DebugPatientData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final patientData = Provider.of<PatientData>(context);
    return ListView(
      children: <Widget>[
        _CachedDataTile(
          name: 'Patient Demographics',
          data: patientData.patientDemographics,
        ),
        _CachedDataTile(
          name: 'Blood Pressure',
          data: patientData.bloodPressure,
        ),
        _CachedDataTile(
          name: 'Smoking Status',
          data: patientData.smokingStatus,
        ),
        _CachedDataTile(
          name: 'Account',
          data: patientData.account,
        ),
      ],
    );
  }
}
