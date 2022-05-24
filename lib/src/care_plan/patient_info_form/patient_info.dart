import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rosie/src/care_plan/care_plan_home.dart';
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
  List<String> tobaccoOptions = ['', 'Yes', 'No'];

  String _initialPregnancyStatus = "";
  String _initialTobaccoUsageStatus = "";
  String _initialSexuallyActivityStatus = "";
  //final _heightController = TextEditingController();
  //final _weightController = TextEditingController();
  //final _systolicController = TextEditingController();
  //final _diastolicController = TextEditingController();

  late final Future<List<SmokingStatusObservation>> _smokingStatusFuture;
  late final Future<PatientDemographics?> _patientDemographicsFuture;

  @override
  void initState() {
    final patientData = Provider.of<PatientData>(context, listen: false);

    super.initState();
    _smokingStatusFuture = patientData.smokingStatus.get();
    _patientDemographicsFuture = patientData.patientDemographics.get();
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
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
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

  _selectDOBDate(BuildContext context, DateTime? dobValue) async {
    var initialDateOfBirth =
        (dobValue != null) ? dobValue : DateFormat('MM/dd/yy').parse("");
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDateOfBirth,
        firstDate: DateTime(1930, 8),
        lastDate: DateTime(2100));
    if (picked != null) {
      _dateofBirthController.text =
          "${picked.toLocal().month}/${picked.toLocal().day}/${picked.toLocal().year}";
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

  Widget _builDOBField(DateTime? dobValue) {
    _dateofBirthController.text = (dobValue != null)
        ? "${dobValue.toLocal().month}/${dobValue.toLocal().day}/${dobValue.toLocal().year}"
        : '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 20, 0),
      child: TextFormField(
        style: const TextStyle(color: Colors.black),
        cursorColor: Colors.black,
        controller: _dateofBirthController,
        onTap: () => _selectDOBDate(context, dobValue),
        decoration: const InputDecoration(
          labelText: 'Date of Birth',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your Date of Birth';
          }
          return null;
        },
        onSaved: (value) {
          //Provider.of<PatientData>(context, listen: false).dob = value!;
        },
      ),
    );
  }

  Widget _buildSexAssignedAtBirthField(genderValue) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
      child: DropdownButtonFormField<String>(
          value: genderValue,
          items: sexAtBirthOptions.map((String val) {
            return DropdownMenuItem(
              value: val,
              child: Text(
                val,
              ),
            );
          }).toList(),
          style: const TextStyle(color: Colors.black),
          iconEnabledColor: Colors.black,
          iconDisabledColor: Colors.black,
          dropdownColor: Colors.blueGrey,
          decoration: const InputDecoration(
            labelText: 'Sex at Birth',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your Sex at Birth';
            }
            return null;
          },
          onSaved: (value) {
            //Provider.of<PatientData>(context, listen: false).gender = value!;
          },
          onChanged: (value) {
            //Provider.of<PatientData>(context, listen: false).gender = value!;
          }),
    );
  }

/*
  Widget _buildHeightField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
      child: TextFormField(
        controller: _heightController,
        style: const TextStyle(color: Colors.black),
        cursorColor: Colors.black,
        decoration: const InputDecoration(
          labelText: 'Height',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your Height';
          }
          return null;
        },
        onSaved: (value) {
          //Provider.of<PatientData>(context, listen: false).height = value!;
        },
      ),
    );
  }

  Widget _buildWeightField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
      child: TextFormField(
        controller: _weightController,
        style: const TextStyle(color: Colors.black),
        cursorColor: Colors.black,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        decoration: const InputDecoration(
          labelText: 'Weight (lb)',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your Weight';
          }
          return null;
        },
        onSaved: (value) {
          //Provider.of<PatientData>(context, listen: false).weight = value!;
        },
      ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 20, 0),
      child: TextFormField(
        controller: _systolicController,
        style: const TextStyle(color: Colors.black),
        cursorColor: Colors.black,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        decoration: const InputDecoration(
          labelText: 'Systolic (mmHg)',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a Systolic Blood Pressure Reading';
          }
          return null;
        },
        onSaved: (value) {
          Provider.of<PatientData>(context, listen: false).systolic = value!;
        },
      ),
    );
  }

  Widget _buildDiastolicField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
      child: TextFormField(
        controller: _diastolicController,
        style: const TextStyle(color: Colors.black),
        cursorColor: Colors.black,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        decoration: const InputDecoration(
          labelText: 'Diastolic (mmHg)',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a Diastolic Blood Pressure Reading';
          }
          return null;
        },
        onSaved: (value) {
          Provider.of<PatientData>(context, listen: false).diastolic = value!;
        },
      ),
    );
  }

  Widget _buildBloodPressureDateRecordedField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
      child: TextFormField(
        style: const TextStyle(color: Colors.black),
        cursorColor: Colors.black,
        controller: _dateofBloodPressureRecordedController,
        onTap: () => _selectBloodPressureRecordedDate(context),
        decoration: const InputDecoration(
          labelText: 'Date Recorded',
        ),
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
      ),
    );
  }
*/
  Widget _buildPregnancyField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
      child: DropdownButtonFormField<String>(
          value: _initialPregnancyStatus,
          items: pregnancyOptions.map((String val) {
            return DropdownMenuItem(
              value: val,
              child: Text(
                val,
              ),
            );
          }).toList(),
          style: const TextStyle(color: Colors.black),
          iconEnabledColor: Colors.black,
          iconDisabledColor: Colors.black,
          dropdownColor: Colors.blueGrey,
          decoration: const InputDecoration(
            labelText: 'Pregnancy',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your Pregnancy status';
            }
            return null;
          },
          onSaved: (value) {
            //Provider.of<PatientData>(context, listen: false).pregnancyStatus =
            value!;
          },
          onChanged: (value) {
            //Provider.of<PatientData>(context, listen: false).pregnancyStatus =
            value!;
          }),
    );
  }

  Widget _buildTobaccoUsageField(displayValue) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
      child: DropdownButtonFormField<String>(
          value: displayValue,
          items: tobaccoOptions.map((String val) {
            return DropdownMenuItem(
              value: val,
              child: Text(
                val,
              ),
            );
          }).toList(),
          style: const TextStyle(color: Colors.black),
          iconEnabledColor: Colors.black,
          iconDisabledColor: Colors.black,
          dropdownColor: Colors.blueGrey,
          decoration: const InputDecoration(
            labelText: 'Tobacco Usage',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your Tobacco Usage status';
            }
            return null;
          },
          onSaved: (value) {
            //Provider.of<PatientData>(context, listen: false).tobaccoUsage =
            value!;
          },
          onChanged: (value) {
            //Provider.of<PatientData>(context, listen: false).tobaccoUsage =
            value!;
          }),
    );
  }

  Widget _buildSexuallyActiveField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
      child: DropdownButtonFormField<String>(
          value: _initialSexuallyActivityStatus,
          items: sexualActivityOptions.map((String val) {
            return DropdownMenuItem(
              value: val,
              child: Text(
                val,
              ),
            );
          }).toList(),
          style: const TextStyle(color: Colors.black),
          iconEnabledColor: Colors.black,
          iconDisabledColor: Colors.black,
          dropdownColor: Colors.blueGrey,
          decoration: const InputDecoration(
            labelText: 'Sexually Active',
          ),
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
          }),
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
                      future: _patientDemographicsFuture),
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
                      future: _patientDemographicsFuture),
                  //_buildHeightField(),
                  //_buildWeightField(),
                  //_buildBloodPressureLabel(),
                  //_buildSystolicField(),
                  //_buildDiastolicField(),
                  //_buildBloodPressureDateRecordedField(),
                  _buildPregnancyField(),
                  FutureBuilder<List<SmokingStatusObservation>>(
                      builder: (context, snapshot) {
                        String smokingStatusValue = '';
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
                                    snapshot.data![0].smokingStatus
                                        ? "Yes"
                                        : "No";
                              }
                            }
                        }
                        return _buildTobaccoUsageField(smokingStatusValue);
                      },
                      future: _smokingStatusFuture),
                  _buildSexuallyActiveField(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: ButtonBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            child: const Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                                primary: const Color(0xFF6750A4),
                                shape: const StadiumBorder()),
                            onPressed: () {
                              _formKey.currentState!.save();
                              Navigator.pop(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CarePlanHome(),
                                ),
                              );
                            }),
                      ],
                    ),
                  )
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
