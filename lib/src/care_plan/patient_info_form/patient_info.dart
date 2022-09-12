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
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../open_health_manager/patient_data.dart';
import '../../open_health_manager/smoking_status.dart';
import '../../open_health_manager/patient_demographics.dart';

import '../../rosie_theme.dart';

class PatientInfo extends StatefulWidget {
  const PatientInfo({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PatientInfoState();
  }
}

extension ToFromPatientInfoString on SmokingStatus {
  static fromPatientInfoString(String input) {
    switch (input) {
      case '':
        return SmokingStatus.unknown;
      case 'Never Smoked':
        return SmokingStatus.neverSmoked;
      case 'Former Smoker':
        return SmokingStatus.formerSmoker;
      case 'Current Smoker':
        return SmokingStatus.currentSmoker;
    }
  }

  String toPatientInfoString() {
    switch (this) {
      case SmokingStatus.unknown:
        return '';
      case SmokingStatus.neverSmoked:
        return 'Never Smoked';
      case SmokingStatus.formerSmoker:
        return 'Former Smoker';
      case SmokingStatus.currentSmoker:
        return 'Current Smoker';
    }
  }
}

class PatientInfoState extends State<PatientInfo> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dateofBirthController = TextEditingController();
  //final TextEditingController _dateofBloodPressureRecordedController =
  //    TextEditingController();

  //DateTime selectedDateOfBirthField = DateTime.now();
  //DateTime selectedDateOfBloodPressureRecorded = DateTime.now();

  List<String> sexAtBirthOptions = ['', 'Male', 'Female', 'Other', 'Unknown'];
  List<String> pregnancyOptions = ['', 'Yes', 'No'];
  List<String> sexualActivityOptions = ['', 'Yes', 'No'];
  List<String> tobaccoOptions = [
    '',
    'Current Smoker',
    'Former Smoker',
    'Never Smoked'
  ];
  //final _heightController = TextEditingController();
  //final _weightController = TextEditingController();
  //final _systolicController = TextEditingController();
  //final _diastolicController = TextEditingController();

  bool _dateOfBirthDirty = false;
  bool _genderDirty = false;
  bool _smokingStatusDirty = false;
  bool _formIsdirty() {
    return _dateOfBirthDirty || _genderDirty || _smokingStatusDirty;
  }

  late final Future<List<SmokingStatusObservation>> _smokingStatusFuture;
  late final Future<PatientDemographics?> _patientDemographicsFuture;

  @override
  void initState() {
    final patientData = Provider.of<PatientData>(context, listen: false);

    super.initState();
    _smokingStatusFuture = patientData.smokingStatus.get();
    _patientDemographicsFuture = patientData.patientDemographics.get();
    _patientDemographicsFuture.then((theDemographics) {
      DateTime? dobValue = theDemographics?.dateOfBirth;
      _dateofBirthController.text = (dobValue != null)
          ? "${dobValue.toLocal().month}/${dobValue.toLocal().day}/${dobValue.toLocal().year}"
          : '';
    });
    /*_heightController.text = patientData.height;
    _dateofBirthController.text = patientData.dob;
    _initialGender = patientData.gender;
    _weightController.text = patientData.weight;
    _systolicController.text = patientData.systolic;
    _diastolicController.text = patientData.diastolic;
    _dateofBloodPressureRecordedController.text =
        patientData.bloodPressureRecorded;
    _initialPregnancyStatus = patientData.pregnancyStatus;
    _initialTobaccoUsageStatus = patientData.tobaccoUsage;
    _initialSexuallyActivityStatus = patientData.sexualActivityStatus;*/
  }

  @override
  void dispose() {
    //_heightController.dispose();
    _dateofBirthController.dispose();
    //_weightController.dispose();
    //_systolicController.dispose();
    //_diastolicController.dispose();
    //_dateofBloodPressureRecordedController.dispose();
    super.dispose();
  }

  Widget _buildHeaderForm() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(3, 20, 20, 20),
      child: Text(
        'Preventative Health Check',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
      ),
    );
  }

  Widget _buildHeaderSubTextForm() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(3, 10, 20, 20),
      child: Text(
        'The information below is needed to get the most personalized list of recommendations from the US Preventative Services Task Force.',
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }

  Widget _buildOptionalTextForm() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(3, 10, 20, 20),
      child: Text(
        'All fields are optional.',
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }

  void _selectDOBDate(BuildContext context, DateTime? dobValue) async {
    var initialDateOfBirth = (dobValue != null) ? dobValue : DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDateOfBirth,
      firstDate: DateTime(1930, 8),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      String dateText =
          "${picked.toLocal().month}/${picked.toLocal().day}/${picked.toLocal().year}";
      if (dateText != _dateofBirthController.text) {
        _dateofBirthController.text = dateText;
        _dateOfBirthDirty = true;
      }
    }
  }

/*
  _selectBloodPressureRecordedDate(BuildContext context) async {
    var initialBloodPressureRecordedDate = DateFormat('MM/dd/yy')
        .parse(_dateofBloodPressureRecordedController.text);
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialBloodPressureRecordedDate,
        firstDate: DateTime(1930, 8),
        lastDate: DateTime(2100));
    if (picked != null && picked != selectedDateOfBloodPressureRecorded) {
      setState(() {
        selectedDateOfBloodPressureRecorded = picked;
        var date =
            "${picked.toLocal().month}/${picked.toLocal().day}/${picked.toLocal().year}";
        _dateofBloodPressureRecordedController.text = date;
      });
    }
  }
  */

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String?)? onSaved,
    void Function()? onTap,
    double? paddingTop,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, paddingTop ?? 20, 20, 0),
      child: TextFormField(
        style: const TextStyle(color: Colors.black),
        cursorColor: Colors.black,
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
        ),
        validator: validator,
        onSaved: onSaved,
        onChanged: onChanged,
      ),
    );
  }

  Widget _builDOBField(DateTime? dobValue) {
    return _buildTextField(
      label: 'Date of Birth',
      paddingTop: 10,
      controller: _dateofBirthController,
      onTap: () => _selectDOBDate(context, dobValue),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your Date of Birth';
        }
        return null;
      },
      onSaved: (value) {
        //Provider.of<PatientData>(context, listen: false).dob = value!;
        if (_dateOfBirthDirty) {
          Provider.of<PatientData>(context, listen: false)
              .patientDemographics
              .value
              ?.updateDateOfBirth(
                  (value == null) ? null : DateFormat('MM/dd/yy').parse(value));
        }
      },
      onChanged: (value) {
        _dateOfBirthDirty = true;
      },
    );
  }

  Widget _buildDropdown(
      {String? value,
      List<DropdownMenuItem<String>>? items,
      String? label,
      String? Function(String?)? validator,
      void Function(String?)? onSaved,
      void Function(String?)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        /*style: const TextStyle(color: Colors.black),
          iconEnabledColor: Colors.black,
          iconDisabledColor: Colors.black,
          dropdownColor: Colors.blueGrey, */
        decoration: InputDecoration(
          labelText: label,
        ),
        validator: validator,
        onSaved: onSaved,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSexAssignedAtBirthField(genderValue) {
    return _buildDropdown(
      value: genderValue,
      items: sexAtBirthOptions.map((String val) {
        return DropdownMenuItem(
          value: val,
          child: Text(
            val,
          ),
        );
      }).toList(),
      label: 'Sex at Birth',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your Sex at Birth';
        }
        return null;
      },
      onSaved: (value) {
        //Provider.of<PatientData>(context, listen: false).gender = value!;
        if (_genderDirty) {
          Provider.of<PatientData>(context, listen: false)
              .patientDemographics
              .value
              ?.updateGender(value);
        }
      },
      onChanged: (value) {
        //Provider.of<PatientData>(context, listen: false).gender = value!;
        _genderDirty = true;
      },
    );
  }

  /*
  Widget _buildHeightField() {
    return _buildTextField(
      controller: _heightController,
      label: 'Height',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your Height';
        }
        return null;
      },
      onSaved: (value) {
        //Provider.of<PatientData>(context, listen: false).height = value!;
      },
    );
  }

  Widget _buildWeightField() {
    return _buildTextField(
      controller: _weightController,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      label: 'Weight (lb)',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your Weight';
        }
        return null;
      },
      onSaved: (value) {
        //Provider.of<PatientData>(context, listen: false).weight = value!;
      },
    );
  }*/
  /*
  Widget _buildBloodPressureLabel() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 20, 10),
      child: Text(
        'Blood Pressure',
        style: TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSystolicField() {
    return _buildTextField(
      paddingTop: 10,
      controller: _systolicController,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      label: 'Systolic (mmHg)',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a Systolic Blood Pressure Reading';
        }
        return null;
      },
      onSaved: (value) {
        Provider.of<PatientData>(context, listen: false).systolic = value!;
      },
    );
  }

  Widget _buildDiastolicField() {
    return _buildTextField(
      controller: _diastolicController,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      label: 'Diastolic (mmHg)',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a Diastolic Blood Pressure Reading';
        }
        return null;
      },
      onSaved: (value) {
        Provider.of<PatientData>(context, listen: false).diastolic = value!;
      },
    );
  }

  Widget _buildBloodPressureDateRecordedField() {
    return _buildTextField(
      controller: _dateofBloodPressureRecordedController,
      onTap: () => _selectBloodPressureRecordedDate(context),
      label: 'Date Recorded',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the Date of Blood Pressure Recording';
        }
        return null;
      },
      onSaved: (value) {
        Provider.of<PatientData>(context, listen: false)
            .bloodPressureRecorded = value!;
      },
    );
  }
*/
  Widget _buildPregnancyField() {
    return _buildDropdown(
      value: '',
      items: pregnancyOptions.map((String val) {
        return DropdownMenuItem(
          value: val,
          child: Text(
            val,
          ),
        );
      }).toList(),
      label: 'Pregnancy',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your Pregnancy status';
        }
        return null;
      },
      onSaved: (value) {
        //Provider.of<PatientData>(context, listen: false).pregnancyStatus =
        //value!;
      },
      onChanged: (value) {
        //Provider.of<PatientData>(context, listen: false).pregnancyStatus =
        //value!;
      },
    );
  }

  Widget _buildTobaccoUsageField(SmokingStatus displayValue) {
    return _buildDropdown(
      value: displayValue.toPatientInfoString(),
      items: tobaccoOptions.map((String val) {
        return DropdownMenuItem(
          value: val,
          child: Text(
            val,
          ),
        );
      }).toList(),
      label: 'Tobacco Usage',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your Tobacco Usage status';
        }
        return null;
      },
      onSaved: (value) {
        if (_smokingStatusDirty) {
          SmokingStatus theStatus = SmokingStatus.unknown;
          switch (value) {
            case '':
              theStatus = SmokingStatus.unknown;
              break;
            case 'Never Smoked':
              theStatus = SmokingStatus.neverSmoked;
              break;
            case 'Former Smoker':
              theStatus = SmokingStatus.formerSmoker;
              break;
            case 'Current Smoker':
              theStatus = SmokingStatus.currentSmoker;
              break;
          }

          final obs = SmokingStatusObservation(theStatus);

          Provider.of<PatientData>(context, listen: false)
              .addSmokingStatusObservation(obs, inBatch: true);
        }
      },
      onChanged: (value) {
        _smokingStatusDirty = true;
      },
    );
  }

  Widget _buildSexuallyActiveField() {
    return _buildDropdown(
      value: '',
      items: sexualActivityOptions.map((String val) {
        return DropdownMenuItem(
          value: val,
          child: Text(
            val,
          ),
        );
      }).toList(),
      label: 'Sexually Active',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your Sexually Active status';
        }
        return null;
      },
      onSaved: (value) {
        //Provider.of<PatientData>(context, listen: false)
        // .sexualActivityStatus = value!;
      },
      onChanged: (value) {
        //Provider.of<PatientData>(context, listen: false)
        // .sexualActivityStatus = value!;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: createRosieScreenBoxDecoration(),
        constraints: const BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderForm(),
                  _buildHeaderSubTextForm(),
                  _buildOptionalTextForm(),
                  FutureBuilder<PatientDemographics?>(
                    builder: (context, snapshot) {
                      DateTime? dobValue;
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          break;
                        case ConnectionState.waiting:
                          break;
                        case ConnectionState.active:
                        case ConnectionState.done:
                          if (snapshot.data != null) {
                            if (snapshot.data!.dateOfBirth != null) {
                              dobValue = snapshot.data!.dateOfBirth;
                            }
                          }
                      }
                      return _builDOBField(dobValue);
                    },
                    future: _patientDemographicsFuture,
                  ),
                  FutureBuilder<PatientDemographics?>(
                    builder: (context, snapshot) {
                      String genderValue = '';
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          break;
                        case ConnectionState.waiting:
                          break;
                        case ConnectionState.active:
                        case ConnectionState.done:
                          if (snapshot.data != null) {
                            if (snapshot.data!.gender != null) {
                              genderValue = (snapshot.data!.gender as String);
                            }
                          }
                      }
                      return _buildSexAssignedAtBirthField(genderValue);
                    },
                    future: _patientDemographicsFuture,
                  ),
                  //_buildHeightField(),
                  //_buildWeightField(),
                  //_buildBloodPressureLabel(),
                  //_buildSystolicField(),
                  //_buildDiastolicField(),
                  //_buildBloodPressureDateRecordedField(),
                  _buildPregnancyField(),
                  FutureBuilder<List<SmokingStatusObservation>>(
                    builder: (context, snapshot) {
                      SmokingStatus smokingStatusValue = SmokingStatus.unknown;
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          break;
                        case ConnectionState.waiting:
                          break;
                        case ConnectionState.active:
                        case ConnectionState.done:
                          if (snapshot.data != null) {
                            if (snapshot.data!.isNotEmpty) {
                              smokingStatusValue =
                                  snapshot.data!.last.smokingStatus;
                            }
                          }
                      }
                      return _buildTobaccoUsageField(smokingStatusValue);
                    },
                    future: _smokingStatusFuture,
                  ),
                  _buildSexuallyActiveField(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: ButtonBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _formKey.currentState!.save();
                            PatientData ptData = Provider.of<PatientData>(
                                context,
                                listen: false);
                            if (_dateOfBirthDirty || _genderDirty) {
                              ptData.updatePatientDemographics(inBatch: true);
                            }
                            if (_formIsdirty()) {
                              ptData.postCurrentTransaction();
                            }
                            Navigator.pop(context);
                          },
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(),
    );
  }
}
