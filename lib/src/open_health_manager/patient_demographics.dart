import 'dart:developer';
import 'package:fhir/r4.dart' show Patient, PatientGender;
import 'open_health_manager.dart';

/// An observation of a Smoking Status.
class PatientDemographics {
  final DateTime? dateOfBirth;
  final String? gender;

  const PatientDemographics(this.dateOfBirth, this.gender);

  /// Attempts to parse a Smoking Status observation from a given FHIR observation.
  ///
  /// The coding in the observation itself is **ignored**. This will assume it's a valid coding, and will look for the
  /// smoking status value
  factory PatientDemographics.fromPatient(Patient patient) {
    final ptBirthDate = patient.birthDate?.valueDateTime;
    String? ptGender;
    if (patient.gender == PatientGender.male) {
      ptGender = "Male";
    } else if (patient.gender == PatientGender.female) {
      ptGender = "Female";
    } else if (patient.gender == PatientGender.other) {
      ptGender = "Other";
    } else if (patient.gender == PatientGender.unknown) {
      ptGender = "Unknown";
    }

    return PatientDemographics(ptBirthDate, ptGender);
  }
}

extension PatientDemographicsQuerying on OpenHealthManager {
  /// Loads patient demographics
  ///
  /// Any exceptions during loading are thrown, and any exceptions during parsing are logged to the FINE (500) log level
  /// but otherwise eaten and simply left out of the result.
  Future<PatientDemographics?> queryPatientDemographics() async {
    final patient = await queryPatient();
    try {
      return PatientDemographics.fromPatient(patient);
    } on InvalidResourceException catch (error) {
      log('Unable to parse Patient to get patient demographics',
          level: 500, error: error);
      return null;
    }
  }
}
