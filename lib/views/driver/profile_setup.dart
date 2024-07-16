import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:metroshuttle/views/driver/driverhome.dart';

class DriverProfileSetup extends StatefulWidget {
  final String userId;

  const DriverProfileSetup({Key? key, required this.userId}) : super(key: key);

  @override
  State<DriverProfileSetup> createState() => _DriverProfileSetupState();
}

class _DriverProfileSetupState extends State<DriverProfileSetup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _vehicleRegistrationController = TextEditingController();
  String _selectedRegion = 'Kawempe';
  final List<String> _regions = ['Central', 'Kawempe', 'Nakawa', 'Lubaga', 'Makindye'];
  final List<TextEditingController> _schoolControllers = [TextEditingController()];

  bool _isSubmitting = false;

  void _addSchoolField() {
    setState(() {
      _schoolControllers.add(TextEditingController());
    });
  }

  void _removeSchoolField(int index) {
    setState(() {
      if (_schoolControllers.length > 1) {
        _schoolControllers.removeAt(index);
      }
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Extract data from form fields
      String driverName = _driverNameController.text;
      String phoneNumber = _phoneNumberController.text;
      String vehicleRegistration = _vehicleRegistrationController.text;
      List<String> schools = _schoolControllers.map((controller) => controller.text).toList();

      // Save data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
        'driverName': driverName,
        'phoneNumber': phoneNumber,
        'vehicleRegistration': vehicleRegistration,
        'region': _selectedRegion,
        'schools': schools,
      });

      // Navigate to DriverHomeScreen
      Get.offAll(() => DriverHomeScreen(userId: widget.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Profile Setup'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    controller: _driverNameController,
                    labelText: 'Driver Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the driver name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneNumberController,
                    labelText: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the phone number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _vehicleRegistrationController,
                    labelText: 'Vehicle Registration Number',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the vehicle registration number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRegion,
                    decoration: InputDecoration(
                      labelText: 'Region of Operation',
                      border: OutlineInputBorder(),
                    ),
                    items: _regions.map((region) {
                      return DropdownMenuItem<String>(
                        value: region,
                        child: Text(region),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRegion = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  ..._schoolControllers.map((controller) {
                    int index = _schoolControllers.indexOf(controller);
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: controller,
                                labelText: 'School of Operation',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the school';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove_circle),
                              color: Colors.red,
                              onPressed: () => _removeSchoolField(index),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                  TextButton.icon(
                    icon: Icon(Icons.add_circle, color: Colors.green),
                    label: Text('Add Another School'),
                    onPressed: _addSchoolField,
                  ),
                  SizedBox(height: 20),
                  AnimatedOpacity(
                    opacity: _isSubmitting ? 0.5 : 1.0,
                    duration: Duration(milliseconds: 500),
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  @override
  void dispose() {
    _driverNameController.dispose();
    _phoneNumberController.dispose();
    _vehicleRegistrationController.dispose();
    for (var controller in _schoolControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
