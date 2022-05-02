import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../rosie_text_balloon.dart';
import '../../rosie_theme.dart';
import '../../open_health_manager/patient_data.dart';

class BloodPressureScale {
  const BloodPressureScale(this.systolicRange, this.diastolicRange);

  static const ages18To59 = BloodPressureScale([90, 140, 180, 230], [60, 90, 110, 140]);
  static const ages60Up = BloodPressureScale([90, 150, 180, 230], [60, 90, 110, 140]);

  factory BloodPressureScale.forAge(int age) {
    if (age < 60) {
      return ages18To59;
    } else {
      return ages60Up;
    }
  }

  final List<int> systolicRange;
  final List<int> diastolicRange;

  List<double> get systolicPercentStops {
    final max = systolicRange.last.toDouble();
    return List.from(systolicRange.map<double>((e) => e.toDouble() / max));
  }

  List<double> get diastolicPercentStops {
    final max = diastolicRange.last.toDouble();
    return List.from(diastolicRange.map<double>((e) => e.toDouble() / max));
  }

  // Determines which slice of the scale the given BP value falls in.
  int activeSlice(double systolic, double diastolic) {
    // Range are maxmium values for each slice, so find the first one they fit in
    int systolicSlice = systolicRange.indexWhere((element) => systolic < element);
    int diastolicSlice = diastolicRange.indexWhere((element) => diastolic < element);
    // Return whichever slice is greatest, capping to whatever the ranges are
    return math.min(math.max(systolicSlice, diastolicSlice), systolicRange.length - 1);
  }
}

// Class representing the urgency of the BP reading. For now this is basically
// just an index from 0-3 indicating where in the table it falls.
class _BPUrgency {
  const _BPUrgency(this.index, {required this.outdated});
  final int index;
  final bool outdated;
}

// This shows the blood pressure visualization screen
class BloodPressureVisualizationScreen extends StatelessWidget {
  const BloodPressureVisualizationScreen({Key? key, this.scale = BloodPressureScale.ages18To59}) : super(key: key);

  final BloodPressureScale scale;

  @override
  Widget build(BuildContext context) {
    // Grab the current blood pressure from the patient data store
    final bloodPressure = context.watch<PatientData>().bloodPressure;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(children: [
          Expanded(child:
            SafeArea(child:
              Padding(
                padding: const EdgeInsets.all(8),
                child: _BloodPressureChart(
                  bloodPressure: bloodPressure,
                  typeLabelStyle: RosieTheme.comicFont(color: Colors.white, fontSize: 16),
                  numericLabelStyle: RosieTheme.comicFont(color: Colors.white, fontSize: 20, height: 1.0),
                  scale: scale
                )
              )
            )
          ),
          const SizedBox(height: 2),
          RosieTextBalloon.text("Make sure to get your blood pressure checked, then update it here.")
        ]
      )
    );
  }
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
  const _ScalePosition(this.systolic, this.diastolic, { this.rightAlign = false, this.baselineAlign = true });

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

  _BloodPressureScaleLayout(this.padding, this.systolicTicks, this.diastolicTicks);

  // Padding simply specifies the amount to push the text off their anchor point. It is currently always implemented
  // symetrically.
  final EdgeInsets padding;
  final List<double> systolicTicks;
  final List<double> diastolicTicks;

  @override
  void performLayout(Size size) {
    // Create the "padded size" for this
    size = Size(size.width - padding.left - padding.right, size.height - padding.top - padding.bottom);
    for (_ScaleId id in _ScaleId.values) {
      if (hasChild(id)) {
        final childSize = layoutChild(id, BoxConstraints.loose(size));
        // Grab the corresponding layout info
        final position = positionsById[id.index];
        // Find the anchor point
        double x = size.width * (position.diastolic >= 0 ? diastolicTicks[position.diastolic] : 0.0);
        // Systolic scale is inverted so 1.0 - value
        double y = size.height * (position.systolic >= 0 ? (1.0 - systolicTicks[position.systolic]) : 1.0);
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
    return oldDelegate is _BloodPressureScaleLayout && padding != oldDelegate.padding;
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
    required this.diastolicPositions
  }) : super(key: key);

  final TextStyle textStyle;
  final List<int> systolicValues;
  final List<int> diastolicValues;
  final List<double> systolicPositions;
  final List<double> diastolicPositions;

  @override
  Widget build(BuildContext context) {
    // This has to be a CustomMultiChildLayout
    return CustomMultiChildLayout(delegate: _BloodPressureScaleLayout(const EdgeInsets.symmetric(horizontal: 2.0), systolicPositions, diastolicPositions),
      children: <Widget>[
        LayoutId(id: _ScaleId.scale0, child: Text("0", style: textStyle)),
        LayoutId(id: _ScaleId.scaleSystolicTick1, child: Text("90", style: textStyle)),
        LayoutId(id: _ScaleId.scaleSystolicTick2, child: Text("140", style: textStyle)),
        LayoutId(id: _ScaleId.scaleSystolicTick3, child: Text("180", style: textStyle)),
        LayoutId(id: _ScaleId.scaleDiastolicTick1, child: Text(diastolicValues[0].toString(), style: textStyle)),
        LayoutId(id: _ScaleId.scaleDiastolicTick2, child: Text(diastolicValues[1].toString(), style: textStyle)),
        LayoutId(id: _ScaleId.scaleDiastolicTick3, child: Text(diastolicValues[2].toString(), style: textStyle)),
      ]
    );
  }
}

// Just the blood pressure chart.
class _BloodPressureChart extends StatelessWidget {
  const _BloodPressureChart({
    Key? key,
    required this.bloodPressure,
    required this.typeLabelStyle,
    required this.numericLabelStyle,
    required this.scale
  }) : super(key: key);

  final BloodPressureSample? bloodPressure;
  final TextStyle typeLabelStyle;
  final TextStyle numericLabelStyle;
  final BloodPressureScale scale;

  @override
  Widget build(BuildContext context) {
    final systolicPositions = scale.systolicPercentStops;
    final diastolicPositions = scale.diastolicPercentStops;
    // Make local so compiler believes it won't be null
    final bp = bloodPressure;
    final activeSlice = bp == null ? -1 : scale.activeSlice(bp.systolic, bp.diastolic);
    var children = <Widget>[
      // Base box fills the entire thing
      Container(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(128, 0, 0, 0),
              offset: Offset(4, 4),
              blurRadius: 4.0
            )
          ],
          borderRadius: BorderRadius.circular(5),
          color: activeSlice == 3 ? RosieTheme.urgent : RosieTheme.inactiveUrgent,
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
            color: activeSlice == 2 ? RosieTheme.concern : RosieTheme.inactiveConcern,
          )
        )
      ),
      // Optimal box
      FractionallySizedBox(
        alignment: AlignmentDirectional.bottomStart,
        widthFactor: diastolicPositions[1],
        heightFactor: systolicPositions[1],
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: activeSlice == 1 ? RosieTheme.optimal : RosieTheme.inactiveOptimal,
          )
        )
      ),
      // Low box? I guess
      FractionallySizedBox(
        alignment: AlignmentDirectional.bottomStart,
        widthFactor: diastolicPositions[0],
        heightFactor: systolicPositions[0],
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: activeSlice == 0 ? RosieTheme.belowOptimal : RosieTheme.inactiveBelowOptimal,
          )
        )
      ),
      // Type labels
      Positioned(left: 3, top: 2, child: Text("Systolic", style: typeLabelStyle)),
      Positioned(right: 2, bottom: 2, child: Text("Diastolic", style: typeLabelStyle)),
      // Numeric scales are handled in their own widget
      _BloodPressureScales(
        textStyle: numericLabelStyle,
        systolicValues: scale.systolicRange,
        diastolicValues: scale.diastolicRange,
        systolicPositions: systolicPositions,
        diastolicPositions: diastolicPositions,
      )
    ];
    if (bp != null) {
      // If bp exists, add it
      children.add(_BloodPressureValue(
        bloodPressure: bp,
        urgency: _BPUrgency(activeSlice, outdated: bp.isOutdated()),
        maxSystolic: scale.systolicRange.last,
        maxDiastolic: scale.diastolicRange.last,
        highlightColor: RosieTheme.urgencyPalette[activeSlice],
      ));
    }
    return Stack(alignment: AlignmentDirectional.bottomStart,
      children: children
    );
  }
}

class _BloodPressureCalloutLayout extends SingleChildLayoutDelegate {
  const _BloodPressureCalloutLayout(this.x, this.y);

  final double x;
  final double y;

  @override Offset getPositionForChild(Size size, Size childSize) {
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
    required this.highlightColor
  }) : super(key: key);

  final BloodPressureSample bloodPressure;
  final _BPUrgency urgency;
  final int maxSystolic;
  final int maxDiastolic;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    // This handles positioning the actual callout box
    final x = math.min(bloodPressure.diastolic / maxDiastolic.toDouble(), 1.0);
    final y = math.min(bloodPressure.systolic / maxSystolic.toDouble(), 1.0);
    return CustomSingleChildLayout(
      delegate: _BloodPressureCalloutLayout(x, y),
      child: _BloodPressureCallout(
        bloodPressure: bloodPressure,
        urgency: urgency,
        highlightColor: highlightColor,
      )
    );
  }
}

class _BloodPressureCallout extends StatelessWidget {
  const _BloodPressureCallout({
    Key? key,
    required this.bloodPressure,
    required this.urgency,
    required this.highlightColor
  }) : super(key: key);

  final BloodPressureSample bloodPressure;
  final _BPUrgency urgency;
  final Color highlightColor;

  Widget _buildText(BuildContext context) {
    final highlightStyle = RosieTheme.font(color: highlightColor, fontSize: 30);
    final formattedBP = TextSpan(
      text: "${bloodPressure.systolic.round()}/${bloodPressure.diastolic.round()}",
      style: highlightStyle
    );
    List<TextSpan> text = [];
    if (urgency.index >= 3) {
      text.add(const TextSpan(text: "At "));
      text.add(formattedBP);
      text.add(const TextSpan(text: " your blood pressure is\n"));
      text.add(TextSpan(text: "an emergency", style: highlightStyle));
      text.add(const TextSpan(text: "\nfor your immediate health!"));
    } else {
      // For now, always use the same text, I guess
      text.add(formattedBP);
      text.add(const TextSpan(text: "\nYour blood pressure was\n"));
      if (urgency.outdated) {
        text.add(TextSpan(text: "good, but", style: highlightStyle));
        text.add(const TextSpan(text: "\nnow it\u2019s out of date. You should check it every year."));
      } else {
        text.add(TextSpan(text: "good", style: highlightStyle));
        text.add(const TextSpan(text: "."));
      }
    }
    return Text.rich(TextSpan(children: text), style: RosieTheme.comicFont(), softWrap: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 226, 235, 244),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color.fromARGB(128, 0, 0, 0),
            offset: Offset(4, 4),
            blurRadius: 4,
          )
        ]
      ),
      child: _buildText(context)
    );
  }
}