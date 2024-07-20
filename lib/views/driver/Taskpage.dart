import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TasksPage extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _getDriverRoutes(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('driverRoutes')
        .where('driverId', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get current user
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user != null ? user.uid : 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: userId == 'Unknown'
          ? Center(child: Text('User not logged in'))
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _getDriverRoutes(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No tasks found'));
                } else {
                  List<Map<String, dynamic>> routes = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Expanded(
                      child: DataTable(
                        columnSpacing: 20.0,
                        columns: [
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Child\'s Name',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Parent\'s Name',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Phone Number',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                        rows: routes.map((route) {
                          return DataRow(cells: [
                            DataCell(
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 120),
                                child: Text(route['childsName'] ?? ''),
                              ),
                            ),
                            DataCell(
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 120),
                                child: Text(route['parentsName'] ?? ''),
                              ),
                            ),
                            DataCell(
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 120),
                                child: Text(route['phoneNumber'] ?? ''),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }
}
