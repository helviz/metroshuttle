import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metroshuttle/models/user_parent.dart';
import 'dart:io';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _parentnameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

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
    if (_parentnameController.text.isEmpty || _phoneNumberController.text.isEmpty || _imageFile == null) {
      Get.snackbar('Error', 'All fields are required!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(_imageFile!);
      final imageUrl = await storageRef.getDownloadURL();

      // Save user data to Firestore
      final parent = Parent(
        name: _parentnameController.text,
        phoneNumber: _phoneNumberController.text,
        imageUrl: imageUrl,
      );

      await FirebaseFirestore.instance.collection('users').add(parent.toMap());

      Get.snackbar('Success', 'Profile created successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create profile!');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile Setup')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            greenIntroWidgetWithoutLogos(title: 'Profile Setup', subtitle: 'Fill in your details'),
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
                    controller: _parentnameController,
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
                          child: Text('Create Profile'),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
