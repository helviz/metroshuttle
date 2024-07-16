import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolBusDriver {
  final String name;
  final String phone;
  final String carRegistrationNumber;
  final String regionOfOperation;
  final String division;
  final List<String> schools;
  final String userId; // Add userId field

  SchoolBusDriver({
    required this.name,
    required this.phone,
    required this.carRegistrationNumber,
    required this.regionOfOperation,
    required this.division,
    required this.schools,
    required this.userId, // Include userId in constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'carRegistrationNumber': carRegistrationNumber,
      'regionOfOperation': regionOfOperation,
      'division': division,
      'schools': schools,
      'userId': userId, // Add userId to the map
    };
  }

  factory SchoolBusDriver.fromMap(Map<String, dynamic> map) {
    return SchoolBusDriver(
      name: map['name'],
      phone: map['phone'],
      carRegistrationNumber: map['carRegistrationNumber'],
      regionOfOperation: map['regionOfOperation'],
      division: map['division'],
      schools: List<String>.from(map['schools']),
      userId: map['userId'], // Assign userId from the map
    );
  }

  Future<void> saveToFirestore() async {
    await FirebaseFirestore.instance.collection('schoolBusDrivers').add(toMap());
  }
}
