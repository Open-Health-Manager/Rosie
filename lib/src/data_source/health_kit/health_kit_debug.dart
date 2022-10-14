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
import 'health_kit.dart';
import 'health_kit_resource_screen.dart';

/// Root of the HealthKit debug screens
class HealthKitDebugScreen extends StatelessWidget {
  const HealthKitDebugScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthKit Debug'),
      ),
      body: const HealthKitDebug(),
    );
  }
}

enum _HKType implements Comparable<_HKType> {
  category,
  clinical,
  correlation;

  @override
  int compareTo(_HKType other) {
    return other == this
        ? 0
        : index < other.index
            ? -1
            : 1;
  }
}

class _HKResourceType implements Comparable<_HKResourceType> {
  const _HKResourceType({required this.type, required this.name});
  final _HKType type;
  final String name;

  @override
  int compareTo(_HKResourceType other) {
    int compare = type.compareTo(other.type);
    return compare == 0 ? name.compareTo(other.name) : compare;
  }
}

class HealthKitDebug extends StatefulWidget {
  const HealthKitDebug({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HealthKitDebugState();
}

class _HealthKitDebugState extends State<HealthKitDebug> {
  bool loading = true;
  bool available = false;
  final List<_HKResourceType> _supportedTypes = [];

  @override
  void initState() {
    super.initState();
    _initHealthKit().then((void _) {
      setState(() {
        loading = false;
      });
    });
  }

  Future<void> _initHealthKit() async {
    available = await HealthKit.requestAccess();
    if (available) {
      _supportedTypes.addAll((await HealthKit.supportedClinicalTypes()).map(
          (clinicalType) =>
              _HKResourceType(type: _HKType.clinical, name: clinicalType)));
      _supportedTypes.addAll((await HealthKit.supportedCategoryTypes()).map(
          (categoryType) =>
              _HKResourceType(type: _HKType.category, name: categoryType)));
      _supportedTypes.addAll((await HealthKit.supportedCorrelationTypes()).map(
          (correlationType) => _HKResourceType(
              type: _HKType.correlation, name: correlationType)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!available) {
      return const Center(child: Text('HealthKit not available'));
    }
    final categoryTypes = _supportedTypes;
    return ListView.builder(
      itemBuilder: (context, index) {
        final type = categoryTypes[index];
        return ListTile(
          title: Text(type.name),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: Text(type.name),
                  ),
                  body: _RecordList(type: type),
                ),
              ),
            );
          },
        );
      },
      itemCount: categoryTypes.length,
    );
  }
}

class _RecordList extends StatefulWidget {
  const _RecordList({
    Key? key,
    required this.type,
  }) : super(key: key);

  final _HKResourceType type;

  @override
  State<StatefulWidget> createState() => _RecordListState();
}

class _RecordListState extends State<_RecordList> {
  List<HealthKitResource>? _resources;

  @override
  void initState() {
    super.initState();
    Future<List<HealthKitResource>> resourceFuture;
    switch (widget.type.type) {
      case _HKType.category:
        resourceFuture = HealthKit.queryCategoryData(widget.type.name);
        break;
      case _HKType.clinical:
        resourceFuture = HealthKit.queryClinicalRecords(widget.type.name);
        break;
      case _HKType.correlation:
        resourceFuture = HealthKit.queryCorrelationData(widget.type.name);
        break;
    }
    resourceFuture.then((results) {
      setState(() {
        _resources = results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final resources = _resources;
    if (resources == null) {
      return Center(
        child: Column(
          children: const <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      );
    } else {
      if (resources.isEmpty) {
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('No resources found for ${widget.type.name}'),
          ),
        );
      } else {
        return ListView.builder(
          itemCount: resources.length,
          itemBuilder: (context, index) {
            //final resource = resources[index];
            return ListTile(
              title: Text("Resource $index"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return Scaffold(
                      appBar: AppBar(
                        title: Text("${widget.type.name} $index"),
                      ),
                      body: HealthKitResourceScreen(
                        resource: resources[index],
                      ),
                    );
                  }),
                );
              },
            );
          },
        );
      }
    }
  }
}
