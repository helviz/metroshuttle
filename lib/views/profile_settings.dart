import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metroshuttle/models/user_parent.dart';
import 'package:metroshuttle/views/parent/parent_homescreen.dart';
import 'package:metroshuttle/widgets/green_intro_widget.dart';

class ProfileSettingScreen extends StatefulWidget {
  @override
  _ProfileSettingScreenState createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  bool _isExistingUser = false;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'No user is logged in!');
        return;
      }
      String userId = currentUser.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        _isExistingUser = true;
        var data = userDoc.data() as Map<String, dynamic>;

        _nameController.text = data['name'] ?? '';
        _phoneNumberController.text = data['phoneNumber'] ?? '';
        
        if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty) {
          // If there’s an image URL, don’t set _imageFile as we’re not loading the image here
        }
      }

      setState(() {
        _isDataLoaded = true; // Mark the data as loaded
      });
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
    if (_nameController.text.isEmpty || _phoneNumberController.text.isEmpty) {
      Get.snackbar('Error', 'All fields are required!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'No user is logged in!');
        return;
      }
      String userId = currentUser.uid;

      String? imageUrl;

      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(_imageFile!);
        imageUrl = await storageRef.getDownloadURL();
      }

      final parent = UserParent(
        name: _nameController.text,
        phoneNumber: _phoneNumberController.text,
        imageUrl: imageUrl ?? '', // Save new or existing image URL
        userType: 'user',
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(parent.toMap(), SetOptions(merge: true)); // Merge data to avoid overwriting fields

      Get.snackbar(
          'Success',
          _isExistingUser
              ? 'Profile updated successfully!'
              : 'Profile created successfully!');

      Get.offAll(() => ParentHomeScreen(userId: userId));
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
            greenIntroWidgetWithoutLogos(title: 'PROFILE SETUP', subtitle: 'Fill In Your Details'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isDataLoaded
                  ? Column(
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
                          controller: _phoneNumberController,
                          decoration: InputDecoration(labelText: 'Phone Number'),
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 20),
                        _isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _uploadProfile,
                                child: Text('Submit'),
                              ),
                      ],
                    )
                  : Center(child: CircularProgressIndicator()), // Show a loading indicator while data is loading
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
    super.dispose();
  }
}

Widget greenIntroWidgetWithoutLogos({String title = "Profile Settings", String? subtitle}) {
  return Container(
    width: Get.width,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/mask.png'),
        fit: BoxFit.fill,
      ),
    ),
    height: Get.height * 0.3,
    child: Container(
      height: Get.height * 0.1,
      width: Get.width,
      margin: EdgeInsets.only(bottom: Get.height * 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
        ],
      ),
    ),
  );
}
