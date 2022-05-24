import 'dart:developer';
import 'package:fhir/r4.dart' show Observation;
import 'open_health_manager.dart';
import 'util.dart';

/// An observation of a Smoking Status.
class SmokingStatusObservation {
  final bool smokingStatus;

  const SmokingStatusObservation(this.smokingStatus);

  /// Attempts to parse a Smoking Status observation from a given FHIR observation.
  ///
  /// The coding in the observation itself is **ignored**. This will assume it's a valid coding, and will look for the
  /// smoking status value
  factory SmokingStatusObservation.fromObservation(Observation observation) {
    final valueCodes = observation.valueCodeableConcept?.coding;
    if (valueCodes == null || valueCodes.isEmpty) {
      throw const InvalidResourceException(
          "No valueCodes in smoking status observation.");
    }
    bool? smokingStatus;
    for (final aValueCode in valueCodes) {
      final theCode = aValueCode.code?.value;
      if (theCode == "266919005") {
        // Never smoked tobacco (finding)
        smokingStatus = false;
      } else if (theCode == "266927001") {
        // Tobacco smoking consumption unknown (finding)
        smokingStatus = false;
      } else if (theCode == "428041000124106") {
        // Occasional tobacco smoker (finding)
        smokingStatus = true;
      } else if (theCode == "428061000124105") {
        // Light tobacco smoker (finding)
        smokingStatus = true;
      } else if (theCode == "428071000124103") {
        // Heavy tobacco smoker (finding)
        smokingStatus = true;
      } else if (theCode == "449868002") {
        // Smokes tobacco daily (finding)
        smokingStatus = true;
      } else if (theCode == "77176002") {
        // Smoker (finding)
        smokingStatus = true;
      } else if (theCode == "8517006") {
        // Ex-smoker (finding)
        smokingStatus = false;
      }
    }
    if (smokingStatus != null) {
      return SmokingStatusObservation(smokingStatus);
    } else {
      throw const InvalidResourceException(
          "Could not locate a valid Smoking Status within given Observation");
    }
  }
}

extension SmokingStatusQuerying on OpenHealthManager {
  /// Loads a list of Smoking observations.
  ///
  /// Any exceptions during loading are thrown, and any exceptions during parsing are logged to the FINE (500) log level
  /// but otherwise eaten and simply left out of the result.
  Future<List<SmokingStatusObservation>> querySmokingStatus() async {
    final bundle = await queryResource(
        "Observation", {"code": "http://loinc.org|72166-2"});
    final results = <SmokingStatusObservation>[];
    final entries = bundle.entry;
    if (entries == null) {
      return results;
    }
    for (final entry in entries) {
      final resource = entry.resource;
      if (resource != null && resource is Observation) {
        try {
          results.add(SmokingStatusObservation.fromObservation(resource));
        } on InvalidResourceException catch (error) {
          log('Unable to parse Observation for a Smoking Status',
              level: 500, error: error);
        }
      }
    }
    return results;
  }
}
