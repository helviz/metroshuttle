import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metroshuttle/views/parent/child_management_screen.dart';

class ParentsRequestPage extends StatelessWidget {
  // Fetch the current user ID using Firebase Authentication
  String getCurrentUserId() {
    final User? user = FirebaseAuth.instance.currentUser;
    return user != null ? user.uid : 'Unknown User';
  }

  @override
  Widget build(BuildContext context) {
    final String userId = getCurrentUserId();

    return Scaffold(
      appBar: AppBar(
        title: Text('Requests - $userId'),
      ),
      body: Center(
        child: Text('Requests for user $userId'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to ChildManagementScreen
          Get.to(() => ChildManagementScreen());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
