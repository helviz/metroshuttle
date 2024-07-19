import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get current user
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user != null ? user.uid : 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'User ID:',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              userId,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'List of tasks goes here...',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
