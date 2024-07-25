import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:metroshuttle/models/driverRoute_model.dart';
import 'package:uuid/uuid.dart';
import 'package:metroshuttle/models/notification_model.dart' as MyNotification;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> fetchParentsName(String docId) async {
    // Get the document from the 'children' collection using docId
    DocumentSnapshot childrenDoc = await _firestore.collection('children').doc(docId).get();

    if (childrenDoc.exists) {
      // Extract the userId from the retrieved document
      String userId = childrenDoc.get('userId');

      // Use the userId to get the name from the 'users' collection
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        // Return the parent's name
        return userDoc.get('name');
      } else {
        print('No user found with userId: $userId');
        return null;
      }
    } else {
      print('No document found with docId: $docId');
      return null;
    }
  }

  Future<String?> fetchPhoneNumber(String docId) async {
    // Get the document from the 'children' collection using docId
    DocumentSnapshot childrenDoc = await _firestore.collection('children').doc(docId).get();

    if (childrenDoc.exists) {
      // Extract the userId from the retrieved document
      String userId = childrenDoc.get('userId');

      // Use the userId to get the phoneNumber from the 'users' collection
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        // Return the phone number
        return userDoc.get('phoneNumber');
      } else {
        print('No user found with userId: $userId');
        return null;
      }
    } else {
      print('No document found with docId: $docId');
      return null;
    }
  }

  Future<void> copySchoolToDriverRoutes(String documentId) async {
    try {
      // Get the currently logged-in user
      User? user = _auth.currentUser;

      if (user == null) {
        print('No user is logged in');
        return;
      }

      String userId = user.uid;

      // Fetch the document from the 'children' collection
      DocumentSnapshot schoolDoc = await _firestore.collection('children').doc(documentId).get();

      if (schoolDoc.exists) {
        Map<String, dynamic> schoolData = schoolDoc.data() as Map<String, dynamic>;

        // Fetch parent's name and phone number
        String? parentsName = await fetchParentsName(documentId);
        String? phoneNumber = await fetchPhoneNumber(documentId);

        // Create a new DriverRoutes instance with the fetched data and the current user's ID
        DriverRoutes driverRoute = DriverRoutes(
          driverId: userId,
          childsName: schoolData['name'] ?? '',
          pickupLocation: schoolData['pickupLocation'] ?? '',
          destination: schoolData['destinationLocation'] ?? '',
          startDate: DateTime.parse(schoolData['startDate'] ?? DateTime.now().toIso8601String()),
          endDate: DateTime.parse(schoolData['endDate'] ?? DateTime.now().toIso8601String()),
          parentsName: parentsName, // Fetch parent's name
          phoneNumber: phoneNumber,// Fetch phone number
          homeAddress:schoolData['homeAddress'] ?? '',
          schoolAddress: schoolData['schoolAddress'] ?? '', 
          
        );

        // Convert the instance to JSON
        Map<String, dynamic> jsonData = driverRoute.toJson();

        // Print the data being saved for debugging
        print('Saving the following data to Firestore: $jsonData');

        // Save the new document in the 'driverRoutes' collection
        await _firestore.collection('driverRoutes').add(jsonData);

        print('Document copied successfully');
      } else {
        print('No such document in the children collection');
      }
    } catch (e) {
      print('Error copying document: $e');
    }
  }
}


Future<void> sendNotification(String userId, String title, String body) async {
  final String notificationId = Uuid().v4(); // Generate unique ID

  // Create the notification object using the prefixed name
  final MyNotification.Notification notification = MyNotification.Notification(
    id: notificationId,
    title: title,
    body: body,
  );

  try {
    // Push notification data to user collection
    await FirebaseFirestore.instance
      .collection('notifications')
      .doc(userId)
      .collection('user_notifications')
      .doc(notificationId)
      .set(notification.toJson());
    print("Notification sent to user: $userId");
  } catch (error) {
    print("Error sending notification: $error");
  }
}