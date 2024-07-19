import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:metroshuttle/models/driverRoute_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> copySchoolToDriverRoutes(String documentId) async {
    try {
      // Fetch the document from the 'schools' collection
      DocumentSnapshot schoolDoc = await _firestore.collection('children').doc(documentId).get();

      if (schoolDoc.exists) {
        Map<String, dynamic> schoolData = schoolDoc.data() as Map<String, dynamic>;

        // Create a new DriverRoutes instance with the fetched data
        DriverRoutes driverRoute = DriverRoutes(
          driverId: schoolData['driverId'] ?? '',
          childsName: schoolData['name'] ?? '',
          pickupLocation: schoolData['pickupLocation'] ?? '',
          destination: schoolData['destinationLocation'] ?? '',
          startDate: DateTime.parse(schoolData['startDate'] ?? DateTime.now().toIso8601String()),
          endDate: DateTime.parse(schoolData['endDate'] ?? DateTime.now().toIso8601String()),
          parentsName: null, // Leave as null
          phoneNumber: null, // Leave as null
        );

        // Convert the instance to JSON
        Map<String, dynamic> jsonData = driverRoute.toJson();
        
        // Print the data being saved for debugging
        print('Saving the following data to Firestore: $jsonData');

        // Save the new document in the 'driverRoutes' collection
        await _firestore.collection('driverRoutes').add(jsonData);

        print('Document copied successfully');
      } else {
        print('No such document in the schools collection');
      }
    } catch (e) {
      print('Error copying document: $e');
    }
  }
}
