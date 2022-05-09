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
import 'rosie_text_balloon.dart';
import 'rosie_theme.dart';

/// This provides a Rosie dialog - this is almost identical to a SimpleDialog but with a few style changes.
class RosieDialog extends StatelessWidget {
  const RosieDialog({Key? key, this.title, this.children, this.expression, this.rosieImage}) :
    assert(expression == null || rosieImage == null),
    super(key: key);

  final RosieExpression? expression;
  final Widget? rosieImage;
  final String? title;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    final Widget rosie = expression?.build() ?? (rosieImage ?? RosieExpression.neutral.build());
    // Children are placed in a column
    final List<Widget> content = [
      if (title != null) Text(title!, style: RosieTheme.font(fontSize: 24)),
      if (children != null) Flexible(
        child: SingleChildScrollView(
          child: ListBody(children: children!)
        )
      )
    ];
    final Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: content);
    return Dialog(
      alignment: Alignment.center,
      backgroundColor: Colors.transparent,
      child: RosieTextBalloon(body: body, rosieImage: rosie)
    );
  }
}