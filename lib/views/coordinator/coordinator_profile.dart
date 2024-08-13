import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metroshuttle/models/coordinator_model.dart';
import 'package:metroshuttle/views/coordinator/coordinator_homescreen.dart';
import 'package:metroshuttle/widgets/green_intro_widget.dart';

class CoordinatorProfile extends StatefulWidget {
  final String userId;

  const CoordinatorProfile({Key? key, required this.userId}) : super(key: key);

  @override
  _CoordinatorProfileState createState() => _CoordinatorProfileState();
}

class _CoordinatorProfileState extends State<CoordinatorProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  bool _isExistingUser = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        _isExistingUser = true;
        var data = userDoc.data() as Map<String, dynamic>;

        setState(() {
          _nameController.text = data['name'] ?? '';
          _phoneNumberController.text = data['telephoneNumber'] ?? '';
          _emailController.text = data['email'] ?? '';
          _schoolNameController.text = data['schoolName'] ?? '';
          // Load image from URL if available
          if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty) {
            _imageFile = null; // Clear the local image file if loading from URL
          }
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile data!');
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

  Future<void> _uploadProfile() async {
    if (_nameController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _schoolNameController.text.isEmpty) {
      Get.snackbar('Error', 'All fields are required!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String userId = widget.userId;
      String? imageUrl;

      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(_imageFile!);
        imageUrl = await storageRef.getDownloadURL();
      }

      final coordinator = COORDINATOR(
        name: _nameController.text,
        email: _emailController.text,
        telephoneNumber: _phoneNumberController.text,
        schoolName: _schoolNameController.text,
        imageUrl: imageUrl ?? '', // Save new or existing image URL
        userType: 'coordinator',
      );

      await FirebaseFirestore.instance.collection('users').doc(userId).set(
            coordinator.toMap(),
            SetOptions(merge: true), // Merge data to avoid overwriting fields
          );

      Get.snackbar(
          'Success',
          _isExistingUser
              ? 'Profile updated successfully!'
              : 'Profile created successfully!');

      Get.offAll(() => CoordinatorHomeScreen(userId: userId));
    } catch (e) {
      Get.snackbar('Error', 'Failed to save profile!');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            greenIntroWidgetWithoutLogos(
                title: 'PROFILE SETUP', subtitle: 'Fill In Your Details'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_imageFile != null)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(_imageFile!),
                    )
                  else
                    CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 50),
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Upload Profile Picture'),
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                  ),
                  TextField(
                    controller: _schoolNameController,
                    decoration: InputDecoration(labelText: 'School Name'),
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _uploadProfile,
                          child: Text('Submit'),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _schoolNameController.dispose();
    super.dispose();
  }
}
