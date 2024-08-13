import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metroshuttle/models/child_model.dart';
import 'package:metroshuttle/views/parent/DriverSelectionScreen.dart';
import 'package:metroshuttle/views/parent/LocationPickerScreen.dart';

class ChildManagementScreen extends StatefulWidget {
  @override
  _ChildManagementScreenState createState() => _ChildManagementScreenState();
}

class _ChildManagementScreenState extends State<ChildManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _homeAddressController = TextEditingController();
  final _schoolAddressController = TextEditingController();
  LatLng? _pickupLocation;
  LatLng? _destinationLocation;
  String? _selectedRegion;
  String? _selectedSchoolAddress;
  final List<String> _regions = ['Central', 'Kawempe', 'Nakawa', 'Lubaga', 'Makindye'];
  List<String> _schoolAddresses = [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  bool _isPickupPinned = false;
  bool _isDestinationPinned = false;

  @override
  void initState() {
    super.initState();
    _fetchSchoolAddresses();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _homeAddressController.dispose();
    _schoolAddressController.dispose();
    super.dispose();
  }

  Future<void> _fetchSchoolAddresses() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userType', isEqualTo: 'coordinator')
        .get();

    setState(() {
      _schoolAddresses = querySnapshot.docs.map((doc) => doc['schoolName'] as String).toList();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime initialDate = DateTime.now().add(Duration(days: 1));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _pickupLocation != null &&
        _destinationLocation != null) {
      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in!')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final userId = user.uid;

      // Use the selected school address if available, otherwise use the entered address
      final schoolAddress = _selectedSchoolAddress ?? _schoolAddressController.text;

      final child = Child(
        userId: userId,
        name: _nameController.text,
        pickupLocation: '${_pickupLocation?.latitude},${_pickupLocation?.longitude}',
        destinationLocation: '${_destinationLocation?.latitude},${_destinationLocation?.longitude}',
        region: _selectedRegion!,
        startDate: _startDate!,
        endDate: _endDate!,
        homeAddress: _homeAddressController.text,
        schoolAddress: schoolAddress,
      );

      // Save child to Firestore and retrieve document ID
      final docRef = await FirebaseFirestore.instance
          .collection('children')
          .add(child.toMap());
      final docId = docRef.id;

      _resetForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Almost Done, Please Select Driver')),
      );

      // Navigate to DriverSelectionScreen with document ID
      Get.to(() => DriverSelectionScreen(docId: docId, userId: userId));

      setState(() {
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields and select locations.')),
      );
    }
  }

  void _resetForm() {
    _nameController.clear();
    _homeAddressController.clear();
    _schoolAddressController.clear();
    setState(() {
      _pickupLocation = null;
      _destinationLocation = null;
      _selectedRegion = null;
      _selectedSchoolAddress = null;
      _startDate = null;
      _endDate = null;
      _isPickupPinned = false;
      _isDestinationPinned = false;
    });
  }

  void _navigateToLocationPicker(bool isPickup) async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(isPickup: isPickup),
      ),
    );
    if (result != null) {
      setState(() {
        if (isPickup) {
          _pickupLocation = result;
          _isPickupPinned = true;
        } else {
          _destinationLocation = result;
          _isDestinationPinned = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('REQUESTS MANAGEMENT')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Enter the following Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildTextField(_nameController, 'Child\'s Name'),
                _buildTextField(_homeAddressController, 'Home Address'),
                _buildLocationPicker('HOME', true, _isPickupPinned),
                _buildSchoolAddressField(),
                _buildLocationPicker('SCHOOl', false, _isDestinationPinned),
                _buildDropdownField(),
                _buildDateField('Start Date', _startDate, true),
                _buildDateField('End Date', _endDate, false),
                
                SizedBox(height: 20),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _submitForm,
                            child: Text('Get Driver'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLocationPicker(String labelText, bool isPickup, bool isPinned) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(labelText, style: TextStyle(fontSize: 16)),
          ElevatedButton(
            onPressed: () => _navigateToLocationPicker(isPickup),
            child: Text(isPinned ? 'PINNED' : 'PIN LOCATION'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Region',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        value: _selectedRegion,
        onChanged: (String? newValue) {
          setState(() {
            _selectedRegion = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a region';
          }
          return null;
        },
        items: _regions.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSchoolAddressField() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Select School Address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          value: _selectedSchoolAddress,
          onChanged: (String? newValue) {
            setState(() {
              _selectedSchoolAddress = newValue;
            });
          },
          items: _schoolAddresses.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        Text('OR'),
        TextField(
          controller: _schoolAddressController,
          decoration: InputDecoration(
            labelText: 'Enter School Address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildDateField(String labelText, DateTime? date, bool isStartDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () => _selectDate(context, isStartDate),
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: labelText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            controller: TextEditingController(
              text: date != null ? DateFormat('yyyy-MM-dd').format(date) : '',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select $labelText';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}
