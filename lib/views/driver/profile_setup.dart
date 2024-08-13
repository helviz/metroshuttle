import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

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
  
  File? _imageFile;
  bool _isSubmitting = false;
  bool _isEditMode = false; // Flag to check if we are in edit mode

  @override
  void initState() {
    super.initState();
    _checkIfProfileExists();
  }

  Future<void> _checkIfProfileExists() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    if (userDoc.exists) {
      setState(() {
        _isEditMode = true;
        _driverNameController.text = userDoc['driverName'] ?? '';
        _phoneNumberController.text = userDoc['phoneNumber'] ?? '';
        _vehicleRegistrationController.text = userDoc['vehicleRegistration'] ?? '';
        _selectedRegion = userDoc['region'] ?? 'Kawempe';
        List<String> schools = List<String>.from(userDoc['schools'] ?? []);
        
        if (schools.isNotEmpty) {
          _schoolControllers.clear();
          for (var school in schools) {
            _schoolControllers.add(TextEditingController(text: school));
          }
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

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

      try {
        // Upload image to Firebase Storage if it exists
        String? imageUrl;
        if (_imageFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_pictures')
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
          await storageRef.putFile(_imageFile!);
          imageUrl = await storageRef.getDownloadURL();
        }

        // Extract data from form fields
        String driverName = _driverNameController.text;
        String phoneNumber = _phoneNumberController.text;
        String vehicleRegistration = _vehicleRegistrationController.text;
        List<String> schools =
            _schoolControllers.map((controller) => controller.text).toList();

        // Save or update data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .set({
          'driverName': driverName,
          'phoneNumber': phoneNumber,
          'vehicleRegistration': vehicleRegistration,
          'region': _selectedRegion,
          'schools': schools,
          if (imageUrl != null)
            'imageUrl': imageUrl, // Only save imageUrl if it exists
          'userType': 'driver'
        }, SetOptions(merge: true)); // Merge data if updating

        // Navigate to DriverHomeScreen
        Get.offAll(() => DriverHomeScreen(userId: widget.userId));
      } catch (e) {
        Get.snackbar('Error', 'Failed to save profile!');
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    } else {
      Get.snackbar('Error', 'All fields are required!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Driver Profile' : 'Driver Profile Setup'),
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
                  Center(
                    child: _imageFile != null
                        ? CircleAvatar(
                            radius: 50,
                            backgroundImage: FileImage(_imageFile!),
                          )
                        : CircleAvatar(
                            radius: 50,
                            child: Icon(Icons.person, size: 50),
                          ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Upload Profile Picture'),
                  ),
                  SizedBox(height: 20),
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
                  SizedBox(height: 16),
                  AnimatedOpacity(
                    opacity: _isSubmitting ? 0.5 : 1.0,
                    duration: Duration(milliseconds: 500),
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(_isEditMode ? 'Update Profile' : 'Submit'),
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
