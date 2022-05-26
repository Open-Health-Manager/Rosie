import 'dart:developer';
import 'package:fhir/r4.dart'
    show Date, FhirDateTime, Patient, PatientGender, Resource;
import 'open_health_manager.dart';

/// internal representation of FHIR Patient Resource
class PatientDemographics {
  Patient? _rawFHIR;
  DateTime? dateOfBirth;
  String? gender;

  PatientDemographics(this.dateOfBirth, this.gender, this._rawFHIR);

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
    Patient cleanFHIR = patient.copyWith(text: null, meta: null);

    return PatientDemographics(ptBirthDate, ptGender, cleanFHIR);
  }

  Patient? getFHIRRepresentation() {
    return _rawFHIR;
  }

  void updateDateOfBirth(DateTime? ptBirthDate) {
    dateOfBirth = ptBirthDate;
    if (_rawFHIR != null) {
      _rawFHIR = _rawFHIR!.copyWith(
          birthDate:
              (ptBirthDate == null) ? null : Date.fromDateTime(ptBirthDate));
    }
  }

  void updateGender(String? ptGender) {
    gender = ptGender;
    PatientGender? genderEnumValue;
    if (ptGender == "Male") {
      genderEnumValue = PatientGender.male;
    } else if (ptGender == "Female") {
      genderEnumValue = PatientGender.female;
    } else if (ptGender == "Other") {
      genderEnumValue = PatientGender.other;
    } else if (ptGender == "Unknown") {
      genderEnumValue = PatientGender.unknown;
    } else {
      genderEnumValue = null;
    }
    if (_rawFHIR != null) {
      _rawFHIR = _rawFHIR!.copyWith(gender: genderEnumValue);
    }
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

  /// Attempts to put the current FHIR rep of the patient demographics to the backend
  Future<void> putPatientDemographics(PatientDemographics patient,
      {bool addToBatch = false}) async {
    Resource? theResource = patient.getFHIRRepresentation();
    if (theResource != null) {
      if (addToBatch) {
        transactionManager.addEntryToUpdateBatch(theResource);
      } else {
        postResource(theResource);
      }
    }
  }
}
