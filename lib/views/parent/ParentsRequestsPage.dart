import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:metroshuttle/views/parent/child_management_screen.dart';

class ParentsRequestPage extends StatelessWidget {
  // Fetch the current user ID using Firebase Authentication
  String getCurrentUserId() {
    final User? user = FirebaseAuth.instance.currentUser;
    return user != null ? user.uid : 'Unknown User';
  }

  // Fetch the children data from Firestore
  Future<List<QueryDocumentSnapshot>> _fetchChildrenRequests(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('children')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs;
  }

  // Fetch the driver's name from Firestore
  Future<String> _fetchDriverName(String? driverId) async {
    if (driverId == null) {
      return 'Unknown Driver';
    }
    DocumentSnapshot driverDoc = await FirebaseFirestore.instance
        .collection('users')  // Assuming driver info is in 'users' collection
        .doc(driverId)
        .get();
    if (driverDoc.exists) {
      var driverData = driverDoc.data() as Map<String, dynamic>;
      return driverData['driverName'] ?? 'Unknown Driver';
    } else {
      return 'Unknown Driver';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userId = getCurrentUserId();

    return Scaffold(
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _fetchChildrenRequests(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No current Requests',
                style: TextStyle(
                  fontSize: 24,
                  color: Color.fromARGB(255, 235, 172, 167),
                ),
              ),
            );
          } else {
            List<QueryDocumentSnapshot> children = snapshot.data!;
            List<Widget> childrenWidgets = [];

            for (var childDoc in children) {
              var childData = childDoc.data() as Map<String, dynamic>;

              // Format dates
              String startDate = childData['startDate'] != null
                  ? DateFormat('dd-MM-yyyy').format(_parseDate(childData['startDate']))
                  : 'Unknown Date';
              String endDate = childData['endDate'] != null
                  ? DateFormat('dd-MM-yyyy').format(_parseDate(childData['endDate']))
                  : 'Unknown Date';

              childrenWidgets.add(Card(
                child: ListTile(
                  title: Text(childData['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Region: ${childData['region']}'),
                      if (childData['request'] == null) Text('Status: Pending'),
                      if (childData['request'] == true) ...[
                        Text('Start Date: $startDate'),
                        Text('End Date: $endDate'),
                        FutureBuilder<String>(
                          future: _fetchDriverName(childData['driver']),
                          builder: (context, driverSnapshot) {
                            if (driverSnapshot.connectionState == ConnectionState.waiting) {
                              return Text('Loading driver info...');
                            } else if (driverSnapshot.hasError) {
                              return Text('Error: ${driverSnapshot.error}');
                            } else {
                              return Text('Driver: ${driverSnapshot.data}');
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ));
            }

            return ListView(
              children: childrenWidgets,
            );
          }
        },
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

  // Helper method to parse date from Firestore data
  DateTime _parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      return DateTime.parse(date);
    } else {
      throw Exception('Invalid date format');
    }
  }
}
