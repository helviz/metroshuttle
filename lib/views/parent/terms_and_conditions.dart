// terms_and_conditions.dart

import 'package:flutter/material.dart';
import 'package:metroshuttle/views/coordinator/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TermsAndConditionsPage extends StatefulWidget {
  @override
  _TermsAndConditionsPageState createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool _termsAndConditionsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'By using this application, you agree to the following terms and conditions:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sit amet nulla auctor, vestibulum magna sed, convallis ex. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            CheckboxListTile(
              title: Text('I agree to the terms and conditions'),
              value: _termsAndConditionsAccepted,
              onChanged: (value) {
                setState(() {
                  _termsAndConditionsAccepted = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _termsAndConditionsAccepted
                  ? () {
                _saveTermsAndConditionsAcceptance(true);
                Navigator.pushReplacementNamed(context, '/');
              }
                  : null,
              child: Text('Accept and Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTermsAndConditionsAcceptance(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('termsAndConditionsAccepted', accepted);
  }
}