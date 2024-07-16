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
  LatLng? _pickupLocation;
  LatLng? _destinationLocation;
  String? _selectedRegion;
  final List<String> _regions = ['Central', 'Kawempe', 'Nakawa', 'Lubaga', 'Makindye'];
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
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
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in!')),
        );
        return;
      }
      final userId = user.uid;

      final child = Child(
        userId: userId,
        name: _nameController.text,
        pickupLocation: '${_pickupLocation?.latitude},${_pickupLocation?.longitude}',
        destinationLocation: '${_destinationLocation?.latitude},${_destinationLocation?.longitude}',
        region: _selectedRegion!,
        startDate: _startDate!,
        endDate: _endDate!,
      );

      // Save child to Firestore and retrieve document ID
      final docRef = await FirebaseFirestore.instance.collection('children').add(child.toMap());
      final docId = docRef.id;

      _nameController.clear();
      setState(() {
        _pickupLocation = null;
        _destinationLocation = null;
        _selectedRegion = null;
        _startDate = null;
        _endDate = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Child information saved successfully!')),
      );

      // Navigate to DriverSelectionScreen with document ID
      Get.to(() => DriverSelectionScreen(docId: docId));
    }
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
        } else {
          _destinationLocation = result;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Child Management'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Add Child Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildTextField(_nameController, 'Child\'s Name'),
                _buildLocationPicker('Pick-up Location', true),
                _buildLocationPicker('Destination Location', false),
                _buildDropdownField(),
                _buildDateField('Start Date', _startDate, true),
                _buildDateField('End Date', _endDate, false),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  Widget _buildLocationPicker(String labelText, bool isPickup) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(labelText, style: TextStyle(fontSize: 16)),
          ElevatedButton(
            onPressed: () => _navigateToLocationPicker(isPickup),
            child: Text('Select Location'),
          ),
          if (isPickup && _pickupLocation != null)
            Text('Selected Location: $_pickupLocation'),
          if (!isPickup && _destinationLocation != null)
            Text('Selected Location: $_destinationLocation'),
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

  Widget _buildDateField(String label, DateTime? date, bool isStartDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          TextButton(
            onPressed: () => _selectDate(context, isStartDate),
            child: Text(date != null ? DateFormat('yyyy-MM-dd').format(date) : 'Select Date'),
          ),
        ],
      ),
    );
  }
}
