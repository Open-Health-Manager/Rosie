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
import 'data_source.dart';

class _DataSourceDescription extends StatelessWidget {
  const _DataSourceDescription({Key? key, required this.dataSource}) : super(key: key);

  final DataSource dataSource;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(dataSource.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge
        ),
        const SizedBox(height: 2),
        Text(dataSource.description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.caption
        ),
        Expanded(child: Container()),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              // When connecting to a data source, force it into a scaffold
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text("Connect to ${dataSource.name}")),
                  body: dataSource.createConnectionScreen(context)
                )
              )
            );
          },
          child: const Text("Connect")
        )
      ]
    );
  }
}

class _DataSourceTile extends StatelessWidget {
  const _DataSourceTile({Key? key, required this.dataSource}) : super(key: key);

  final DataSource dataSource;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: SizedBox(
        height: 120,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Force the icon into a 72x72 box
            SizedBox(
              width: 72.0,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: dataSource.createIcon(context) ?? const Placeholder()
              )
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 2, 0),
                child: _DataSourceDescription(dataSource: dataSource)
              )
            )
          ]
        )
      )
    );
  }
}

class ListDataSourcesScreen extends StatefulWidget {
  const ListDataSourcesScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ListDataSourcesState();
}

class _ListDataSourcesState extends State<ListDataSourcesScreen> {
  // Currently known available data sources
  final List<DataSource> _dataSources = [];
  bool _lookingUp = true;

  @override
  initState() {
    super.initState();
    lookUpDataSources().listen((dataSource) {
      dataSource.isAvailable().then<void>((available) {
        if (available) {
          setState(() {
            _dataSources.add(dataSource);
          });
        }
      });
    }, onDone: () {
      setState(() { _lookingUp = false; });
    });
  }

  Widget _buildDataSourceList(BuildContext context) {
    if (_lookingUp) {
      return Center(child:
          Column(children: const [
            CircularProgressIndicator(),
            Text("Finding available data sources...")
          ])
        );
    } else {
      // Otherwise, build the list!
      if (_dataSources.isEmpty) {
        return const Center(child: Text("No data sources."));
      } else {
        return ListView.builder(
          itemBuilder: (context, index) => _DataSourceTile(dataSource: _dataSources[index]),
          itemCount: _dataSources.length
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Connect Data & Services")),
      body: _buildDataSourceList(context)
    );
  }
}