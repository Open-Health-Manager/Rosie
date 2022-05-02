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
import 'rosie_theme.dart';

class RosieExpression {
  const RosieExpression(this.assetPath);

  final String assetPath;

  // Neutral expression. (Currently the only one technically supported.)
  static const neutral = RosieExpression("assets/rosie/neutral.png");

  Widget build() {
    return Image(image: AssetImage(assetPath));
  }
}

// This widget shows Rosie with a little speech dialog.
class RosieTextBalloon extends StatelessWidget {
  const RosieTextBalloon({Key? key, required this.body, required this.rosieImage}) : super(key: key);

  static final defaultTextStyle = RosieTheme.comicFont(color: Colors.black);

  // The actual message Rosie is saying. This can be any widget but usually the
  // build factories are used to create text.
  final Widget body;
  // The widget to use for Rosie
  final Widget rosieImage;

  static Widget _createBody(Widget message, Widget? action) {
    if (action == null) {
      return message;
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        message,
        Align(alignment: AlignmentDirectional.bottomEnd, child: action)
      ]
    );
  }

  // Creates a Rosie text balloon with the default Rosie text balloon styled text.
  factory RosieTextBalloon.text(String message, {
    Key? key,
    Widget? action,
    RosieExpression expression = RosieExpression.neutral
  }) {
    return RosieTextBalloon(
      key: key,
      body: _createBody(Text(message, style: defaultTextStyle, softWrap: true), action),
      rosieImage: expression.build()
    );
  }

  // Creates a Rosie text ballon with rich text.
  factory RosieTextBalloon.rich(InlineSpan message, {
    Key? key,
    Widget? action,
    RosieExpression expression = RosieExpression.neutral
  }) {
    return RosieTextBalloon(
      key: key,
      body: _createBody(Text.rich(message, style: defaultTextStyle), action),
      rosieImage: expression.build()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topStart,
      children: [
        // This is the "balloon"
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0xE1, 0xE3, 0xE9),
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color.fromARGB(64, 0, 0, 0),
                offset: Offset(0, 4),
                blurRadius: 4
              )
            ]
          ),
          margin: const EdgeInsets.fromLTRB(25, 25, 0, 0),
          padding: const EdgeInsets.fromLTRB(21, 20, 21, 10),
          child: body,
        ),
        rosieImage
      ]
    );
  }
}