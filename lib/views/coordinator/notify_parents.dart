import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CoordinatorScreen extends StatefulWidget {
  @override
  _CoordinatorScreenState createState() => _CoordinatorScreenState();
}

class _CoordinatorScreenState extends State<CoordinatorScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.getToken().then((token) {
      print('Token: $token');
    });
  }

  void _sendNotification(String childId, String parentId, String message) async {
    final parentToken = await _firestore.collection('parents').doc(parentId).get().then((doc) => doc['token']);
    await _firebaseMessaging.sendToToken(parentToken, message);
  }

  void _checkInChild(String childId) async {
    await _firestore.collection('children').doc(childId).update({'arrived': true});
    final parentId = await _firestore.collection('children').doc(childId).get().then((doc) => doc['parentId']);
    _sendNotification(childId, parentId, 'Your child has arrived!');
  }

  void _checkOutChild(String childId) async {
    await _firestore.collection('children').doc(childId).update({'departed': true});
    final parentId = await _firestore.collection('children').doc(childId).get().then((doc) => doc['parentId']);
    _sendNotification(childId, parentId, 'Your child has departed!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coordinator Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                _checkInChild('child-1');
              },
              child: Text('Check in Child 1'),
            ),
            ElevatedButton(
              onPressed: () {
                _checkOutChild('child-1');
              },
              child: Text('Check out Child 1'),
            ),
          ],
        ),
      ),
    );
  }
}