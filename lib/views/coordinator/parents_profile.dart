// parent_profile_screen.dart

import 'package:flutter/material.dart';

class ParentProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parent Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Name: Jane Doe'),
            Text('Contact Information: 987-654-3210'),
            Text('Emergency Contact: Bob Smith, 555-123-4567'),
          ],
        ),
      ),
    );
  }
}