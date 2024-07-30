import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:metroshuttle/controller/service.dart';

class TasksPage extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _getDriverRoutes(String userId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('driverRoutes')
          .where('driverId', isEqualTo: userId)
          .where('active', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Failed to fetch driver routes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user?.uid ?? 'Unknown';

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
                  return SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20.0,
                        columns: [
                          DataColumn(
                            label: Text(
                              'Child\'s Name',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Parent\'s Name',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Phone Number',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Home Address',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'School',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Dropoff',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                            DataCell(
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 120),
                                child: Text(route['homeAddress'] ?? ''),
                              ),
                            ),
                            DataCell(
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 120),
                                child: Text(route['schoolAddress'] ?? ''),
                              ),
                            ),
                            DataCell(DropoffCheckbox(
                              parentID: route['parentID'] ?? 'Unknown',
                              childName: route['childsName'] ?? 'Unknown',
                            )),
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

class DropoffCheckbox extends StatefulWidget {
  final String parentID;
  final String childName;
  DropoffCheckbox({required this.parentID, required this.childName});

  @override
  _DropoffCheckboxState createState() => _DropoffCheckboxState();
}

class _DropoffCheckboxState extends State<DropoffCheckbox> {
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    _fetchCheckedState();
  }

  Future<void> _fetchCheckedState() async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('checkboxStates')
          .doc('${widget.parentID}_${widget.childName}_dropoff_$currentDate')
          .get();

      if (snapshot.exists && snapshot['isChecked'] != null) {
        setState(() {
          isChecked = snapshot['isChecked'];
        });

        DateTime storedDate = (snapshot['date'] as Timestamp).toDate();
        Duration difference = DateTime.now().difference(storedDate);
        if (difference.inDays >= 1) {
          _saveCheckedState(false);
        }
      }
    } catch (e) {
      // Handle error
      print('Error fetching checkbox state: $e');
    }
  }

  Future<void> _saveCheckedState(bool state) async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      await FirebaseFirestore.instance
          .collection('checkboxStates')
          .doc('${widget.parentID}_${widget.childName}_dropoff_$currentDate')
          .set({
        'isChecked': state,
        'date': DateTime.now(),
      });
    } catch (e) {
      // Handle error
      print('Error saving checkbox state: $e');
    }
  }

  Future<void> sendDropoffMessage() async {
    String currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    try {
      await sendNotification(widget.parentID, 'DROPOFF', '${widget.childName} has been dropped off at $currentTime');
    } catch (error) {
      // Handle error
      print('Error sending dropoff message: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value ?? false;
        });
        if (isChecked) {
          sendDropoffMessage();
        }
        _saveCheckedState(isChecked);
      },
    );
  }
}
