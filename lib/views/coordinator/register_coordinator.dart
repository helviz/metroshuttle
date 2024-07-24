import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:metroshuttle/views/coordinator/coordinator_homescreen.dart';

class CoordinatorForm extends StatefulWidget {
  @override
  _CoordinatorFormState createState() => _CoordinatorFormState();
}

class _CoordinatorFormState extends State<CoordinatorForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneNumberController = TextEditingController();
  final _schoolNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coordinator Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _telephoneNumberController,
                decoration: InputDecoration(labelText: 'Telephone Number'),
                validator: (value) {
                  if (value!.isEmpty || value.length < 10) {
                    return 'Please enter a valid telephone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _schoolNameController,
                decoration: InputDecoration(labelText: 'School Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the school name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final coordinator = Coordinator(
                      name: _nameController.text,
                      email: _emailController.text,
                      telephoneNumber: _telephoneNumberController.text,
                      schoolName: _schoolNameController.text,
                    );

                    await FirebaseFirestore.instance
                        .collection('coordinators')
                        .add(coordinator.toMap())
                        .then((value) {
                      print('Coordinator added with ID: ${value.id}');
                      Get.offAll(() => CoordinatorHomeScreen(userId: value.id));
                    }).catchError((error) {
                      print('Error adding coordinator: $error');
                    });

                    _nameController.clear();
                    _emailController.clear();
                    _telephoneNumberController.clear();
                    _schoolNameController.clear();
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Coordinator {
  final String name;
  final String email;
  final String telephoneNumber;
  final String schoolName;

  Coordinator({
    required this.name,
    required this.email,
    required this.telephoneNumber,
    required this.schoolName,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'telephoneNumber': telephoneNumber,
      'schoolName': schoolName,
    };
  }
}
