// child_profile_screen.dart

import 'package:flutter/material.dart';

class ChildProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Child Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Name: John Doe'),
            Text('Age: 10'),
            Text('Grade: 5th'),
            Text('Contact Information: 123-456-7890'),
          ],
        ),
      ),
    );
  }
}