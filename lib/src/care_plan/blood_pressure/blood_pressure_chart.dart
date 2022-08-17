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

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../rosie_dialog.dart';
import '../../rosie_theme.dart';
import '../../open_health_manager/blood_pressure.dart';
import 'blood_pressure_help.dart';
import 'blood_pressure_vis_screen.dart';

/// The urgency of the BP reading. For now this is basically just an index from
/// 0-3 indicating where in the table it falls.
class BPChartUrgency {
  const BPChartUrgency(this.index, {required this.outdated});
  final int index;
  final bool outdated;

  /// Determines if this is considered an "emergency" and causes extra UI elements to display
  bool get emergency => index >= 3;
}

enum _ScaleId {
  scale0,
  scaleSystolicTick1,
  scaleSystolicTick2,
  scaleSystolicTick3,
  scaleDiastolicTick1,
  scaleDiastolicTick2,
  scaleDiastolicTick3
}

class _ScalePosition {
  const _ScalePosition(this.systolic, this.diastolic,
      {this.rightAlign = false, this.baselineAlign = true});

  // Either an index into the systolic ticks or < 0 to indicate 0
  final int systolic;
  // Either an index into the diastolic ticks or < 0 to indicate 0
  final int diastolic;
  final bool rightAlign;
  final bool baselineAlign;
}

// The layout delegate.
class _BloodPressureScaleLayout extends MultiChildLayoutDelegate {
  static const positionsById = [
    _ScalePosition(-1, -1),
    _ScalePosition(0, -1),
    _ScalePosition(1, -1),
    _ScalePosition(2, -1),
    _ScalePosition(-1, 0, rightAlign: true),
    _ScalePosition(-1, 1, rightAlign: true),
    _ScalePosition(-1, 2, rightAlign: true)
  ];

  _BloodPressureScaleLayout(
      this.padding, this.systolicTicks, this.diastolicTicks);

  // Padding simply specifies the amount to push the text off their anchor point. It is currently always implemented
  // symetrically.
  final EdgeInsets padding;
  final List<double> systolicTicks;
  final List<double> diastolicTicks;

  @override
  void performLayout(Size size) {
    // Create the "padded size" for this
    size = Size(size.width - padding.left - padding.right,
        size.height - padding.top - padding.bottom);
    for (_ScaleId id in _ScaleId.values) {
      if (hasChild(id)) {
        final childSize = layoutChild(id, BoxConstraints.loose(size));
        // Grab the corresponding layout info
        final position = positionsById[id.index];
        // Find the anchor point
        double x = size.width *
            (position.diastolic >= 0
                ? diastolicTicks[position.diastolic]
                : 0.0);
        // Systolic scale is inverted so 1.0 - value
        double y = size.height *
            (position.systolic >= 0
                ? (1.0 - systolicTicks[position.systolic])
                : 1.0);
        if (position.rightAlign) {
          x -= childSize.width + padding.right;
        } else {
          x += padding.left;
        }
        if (position.baselineAlign) {
          y -= childSize.height + padding.right;
        } else {
          y += padding.left;
        }
        positionChild(id, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return oldDelegate is _BloodPressureScaleLayout &&
        padding != oldDelegate.padding;
  }
}

// Just the numeric scales.
class _BloodPressureScales extends StatelessWidget {
  const _BloodPressureScales({
    Key? key,
    required this.textStyle,
    required this.systolicValues,
    required this.diastolicValues,
    required this.systolicPositions,
    required this.diastolicPositions,
  }) : super(key: key);

  final TextStyle textStyle;
  final List<int> systolicValues;
  final List<int> diastolicValues;
  final List<double> systolicPositions;
  final List<double> diastolicPositions;

  @override
  Widget build(BuildContext context) {
    // This has to be a CustomMultiChildLayout
    return CustomMultiChildLayout(
      delegate: _BloodPressureScaleLayout(
        const EdgeInsets.symmetric(horizontal: 2.0),
        systolicPositions,
        diastolicPositions,
      ),
      children: <Widget>[
        LayoutId(id: _ScaleId.scale0, child: Text("0", style: textStyle)),
        LayoutId(
          id: _ScaleId.scaleSystolicTick1,
          child: Text("90", style: textStyle),
        ),
        LayoutId(
          id: _ScaleId.scaleSystolicTick2,
          child: Text("140", style: textStyle),
        ),
        LayoutId(
          id: _ScaleId.scaleSystolicTick3,
          child: Text("180", style: textStyle),
        ),
        LayoutId(
          id: _ScaleId.scaleDiastolicTick1,
          child: Text(diastolicValues[0].toString(), style: textStyle),
        ),
        LayoutId(
          id: _ScaleId.scaleDiastolicTick2,
          child: Text(diastolicValues[1].toString(), style: textStyle),
        ),
        LayoutId(
          id: _ScaleId.scaleDiastolicTick3,
          child: Text(diastolicValues[2].toString(), style: textStyle),
        ),
      ],
    );
  }
}

/// The chart for the blood pressure display.
class BloodPressureChart extends StatelessWidget {
  const BloodPressureChart({
    Key? key,
    required this.bloodPressure,
    required this.typeLabelStyle,
    required this.numericLabelStyle,
    required this.urgency,
    required this.scale,
  }) : super(key: key);

  final BloodPressureObservation? bloodPressure;
  final TextStyle typeLabelStyle;
  final TextStyle numericLabelStyle;
  final BloodPressureScale scale;
  final BPChartUrgency urgency;

  @override
  Widget build(BuildContext context) {
    final systolicPositions = scale.systolicPercentStops;
    final diastolicPositions = scale.diastolicPercentStops;
    // Make local so compiler believes it won't be null
    final bp = bloodPressure;
    final activeSlice = urgency.index;
    var children = <Widget>[
      // Base box fills the entire thing
      Container(
        decoration: BoxDecoration(
          /* boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(128, 0, 0, 0),
              offset: Offset(4, 4),
              blurRadius: 4.0,
            )
          ],
          borderRadius: BorderRadius.circular(5), */
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(5),
              bottomRight: Radius.circular(5),
              topLeft: Radius.circular(5),
              bottomLeft: Radius.circular(5)),
          color:
              activeSlice == 3 ? RosieTheme.urgent : RosieTheme.inactiveUrgent,
        ),
      ),
      // Concern box
      FractionallySizedBox(
        alignment: AlignmentDirectional.bottomStart,
        widthFactor: diastolicPositions[2],
        heightFactor: systolicPositions[2],
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: activeSlice == 2
                ? RosieTheme.concern
                : RosieTheme.inactiveConcern,
            border: const Border(
                top: BorderSide(width: 1.0, color: Colors.white),
                bottom: BorderSide(width: 1.0, color: Colors.white),
                left: BorderSide(width: 1.0, color: Colors.white),
                right: BorderSide(width: 1.0, color: Colors.white)),
          ),
        ),
      ),
      // Optimal box
      FractionallySizedBox(
        alignment: AlignmentDirectional.bottomStart,
        widthFactor: diastolicPositions[1],
        heightFactor: systolicPositions[1],
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: activeSlice == 1
                ? RosieTheme.optimal
                : RosieTheme.inactiveOptimal,
            border: const Border(
                top: BorderSide(width: 1.0, color: Colors.white),
                bottom: BorderSide(width: 1.0, color: Colors.white),
                left: BorderSide(width: 1.0, color: Colors.white),
                right: BorderSide(width: 1.0, color: Colors.white)),
          ),
        ),
      ),
      // Low box? I guess
      FractionallySizedBox(
        alignment: AlignmentDirectional.bottomStart,
        widthFactor: diastolicPositions[0],
        heightFactor: systolicPositions[0],
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: activeSlice == 0
                ? RosieTheme.belowOptimal
                : RosieTheme.inactiveBelowOptimal,
            border: const Border(
                top: BorderSide(width: 1.0, color: Colors.white),
                bottom: BorderSide(width: 1.0, color: Colors.white),
                left: BorderSide(width: 1.0, color: Colors.white),
                right: BorderSide(width: 1.0, color: Colors.white)),
          ),
        ),
      ),
      // Type labels
      Positioned(
        left: 3,
        top: 2,
        child: Text("Systolic", style: typeLabelStyle),
      ),
      Positioned(
        right: 2,
        bottom: 2,
        child: Text("Diastolic", style: typeLabelStyle),
      ),
      // Numeric scales are handled in their own widget
      _BloodPressureScales(
        textStyle: numericLabelStyle,
        systolicValues: scale.systolicRange,
        diastolicValues: scale.diastolicRange,
        systolicPositions: systolicPositions,
        diastolicPositions: diastolicPositions,
      ),
    ];
    if (bp != null) {
      // If bp exists, add it
      children.add(_BloodPressureValue(
        bloodPressure: bp,
        urgency: urgency,
        maxSystolic: scale.systolicRange.last,
        maxDiastolic: scale.diastolicRange.last,
        highlightColor: RosieTheme.urgencyPalette[activeSlice],
      ));
    }
    return Stack(
      alignment: AlignmentDirectional.bottomStart,
      children: children,
    );
  }
}

class _BloodPressureCalloutLayout extends SingleChildLayoutDelegate {
  const _BloodPressureCalloutLayout(this.x, this.y);

  final double x;
  final double y;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // TODO: Position properly within the chart
    // This is technically wrong for now because the actual position depends
    // on where the point is in the child.
    final cX = (size.width - childSize.width) * x;
    final cY = (size.height - childSize.height) * y;
    return Offset(cX, cY);
  }

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) {
    if (oldDelegate is _BloodPressureCalloutLayout) {
      return oldDelegate.x != x && oldDelegate.y != y;
    } else {
      return true;
    }
  }
}

// The value
class _BloodPressureValue extends StatelessWidget {
  const _BloodPressureValue({
    Key? key,
    required this.bloodPressure,
    required this.urgency,
    required this.maxSystolic,
    required this.maxDiastolic,
    required this.highlightColor,
  }) : super(key: key);

  final BloodPressureObservation bloodPressure;
  final BPChartUrgency urgency;
  final int maxSystolic;
  final int maxDiastolic;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    // This handles positioning the actual callout box
    final x = math.min(bloodPressure.diastolic / maxDiastolic.toDouble(), 1.0);
    final y =
        1.0 - math.min(bloodPressure.systolic / maxSystolic.toDouble(), 1.0);
    return CustomSingleChildLayout(
      delegate: _BloodPressureCalloutLayout(x, y),
      child: _BloodPressureCallout(
        bloodPressure: bloodPressure,
        urgency: urgency,
        highlightColor: highlightColor,
      ),
    );
  }
}

class _BloodPressureCallout extends StatelessWidget {
  const _BloodPressureCallout(
      {Key? key,
      required this.bloodPressure,
      required this.urgency,
      required this.highlightColor})
      : super(key: key);

  final BloodPressureObservation bloodPressure;
  final BPChartUrgency urgency;
  final Color highlightColor;

  Widget _buildText(BuildContext context) {
    final highlightStyle = RosieTheme.font(color: highlightColor, fontSize: 18);
    final highlightGoodStyle = RosieTheme.font(
        color: const Color.fromARGB(255, 54, 127, 56),
        fontSize: 18,
        fontWeight: FontWeight.bold);
    final highlightEmergencyStyle = RosieTheme.font(
        color: const Color.fromARGB(255, 185, 47, 37),
        fontSize: 18,
        fontWeight: FontWeight.bold);
    final dateStyle = RosieTheme.font(color: Colors.grey, fontSize: 14);
    DateTime? timeTaken = bloodPressure.taken;
    String formattedTimeTaken =
        "${timeTaken?.month}-${timeTaken?.day}-${timeTaken?.year}";

    List<TextSpan> text = [];
    if (urgency.index >= 3) {
      text.add(TextSpan(
          text:
              "${bloodPressure.systolic.round()}/${bloodPressure.diastolic.round()} high\n",
          style: highlightEmergencyStyle));
      text.add(TextSpan(text: formattedTimeTaken, style: dateStyle));
    } else {
      // For now, always use the same text, I guess
      if (urgency.outdated) {
        text.add(TextSpan(text: "good, but", style: highlightStyle));
        text.add(const TextSpan(
          text: "\nnow it\u2019s out of date. You should check it every year.",
        ));
      } else {
        text.add(TextSpan(
            text:
                "${bloodPressure.systolic.round()}/${bloodPressure.diastolic.round()} good\n",
            style: highlightGoodStyle));
        text.add(TextSpan(text: formattedTimeTaken, style: dateStyle));
      }
    }
    final textWidget = Text.rich(TextSpan(children: text),
        style: RosieTheme.comicFont(), softWrap: true);
    if (urgency.emergency) {
      //return textWidget;
      // Slightly different
      return SizedBox(
          height: 75,
          child: Column(
            children: <Widget>[
              textWidget,
              const SizedBox(height: 10),
              ElevatedButton(
                child: const Text("Get Help!"),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const RosieDialog(
                          children: [BloodPressureHelp(emergency: true)]);
                    },
                  );
                },
              ),
            ],
          ));
    } else {
      return textWidget;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        //color: Color.fromARGB(255, 226, 235, 244),
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color.fromARGB(128, 0, 0, 0),
            //offset: Offset(4, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: _buildText(context),
    );
  }
}
