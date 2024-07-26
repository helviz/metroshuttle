import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:metroshuttle/controller/service.dart';

class ChildArrivalTable extends StatefulWidget {
  @override
  _ChildArrivalTableState createState() => _ChildArrivalTableState();
}

class _ChildArrivalTableState extends State<ChildArrivalTable> {
  late Future<List<Map<String, String>>> _childrenAndDrivers;

  @override
  void initState() {
    super.initState();
    _childrenAndDrivers = _fetchChildrenAndDriverDetails();
  }

  Future<String?> _getSchoolName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Get.snackbar('Error', 'No user is logged in!');
      return null;
    }

    String userId = currentUser.uid;
    DocumentSnapshot coordinatorDoc = await FirebaseFirestore.instance
        .collection('coordinators')
        .doc(userId)
        .get();

    if (coordinatorDoc.exists && coordinatorDoc['schoolName'] != null) {
      String schoolName = coordinatorDoc['schoolName'];
      print('School Name: $schoolName'); // Debug print
      return schoolName;
    } else {
      Get.snackbar('Error', 'Coordinator data not found!');
      return null;
    }
  }

  Future<List<Map<String, String>>> _fetchChildrenAndDriverDetails() async {
    String? schoolName = await _getSchoolName();
    if (schoolName == null) {
      return [];
    }

    QuerySnapshot childrenSnapshot = await FirebaseFirestore.instance
        .collection('children')
        .where('schoolAddress', isEqualTo: schoolName)
        .where('request', isEqualTo: true)
        .get();

    print('Children Snapshot Docs: ${childrenSnapshot.docs.length}'); // Debug print

    List<Map<String, String>> childrenDetails = [];

    for (var childDoc in childrenSnapshot.docs) {
      String? childName = childDoc['name'];
      String? driverId = childDoc['driver'];
      String? parentId = childDoc['userId'];

      if (childName != null && driverId != null && parentId != null) {
        print('Child Name: $childName, Driver ID: $driverId'); // Debug print

        DocumentSnapshot driverDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(driverId)
            .get();

        if (driverDoc.exists) {
          String? driverName = driverDoc['driverName'];
          String? carRegistrationNumber = driverDoc['vehicleRegistration'];

          if (driverName != null && carRegistrationNumber != null) {
            print('Driver Name: $driverName, Car Registration Number: $carRegistrationNumber'); // Debug print

            childrenDetails.add({
              'childName': childName,
              'driverName': driverName,
              'parentId': parentId,
              'carRegistrationNumber': carRegistrationNumber,
            });
          }
        }
      }
    }

    return childrenDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, String>>>(
        future: _childrenAndDrivers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}'); // Debug print
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('No data found'); // Debug print
            return Center(child: Text('No data found'));
          } else {
            List<Map<String, String>> data = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  Text(
                    'Arrival and Departure',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  DataTable(
                    columnSpacing: 20,
                    columns: [
                      DataColumn(label: Text('Child Name')),
                      DataColumn(label: Text('Driver Name')),
                      DataColumn(label: Text('Car Registration Number')),
                      DataColumn(label: Text('Arrival')),
                      DataColumn(label: Text('Departure')),
                    ],
                    rows: data.map((entry) {
                      return DataRow(cells: [
                        DataCell(Text(entry['childName']!)),
                        DataCell(Text(entry['driverName']!)),
                        DataCell(Text(entry['carRegistrationNumber']!)),
                        DataCell(ArrivalCheckbox(entry['parentId']!, entry['childName']!)),
                        DataCell(DepartureCheckbox(entry['parentId']!, entry['childName']!)),
                      ]);
                    }).toList(),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class ArrivalCheckbox extends StatefulWidget {
  final String parentId;
  final String childName;
  ArrivalCheckbox(this.parentId, this.childName);

  @override
  _ArrivalCheckboxState createState() => _ArrivalCheckboxState();
}

class _ArrivalCheckboxState extends State<ArrivalCheckbox> {
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    _fetchCheckedState();
  }

  Future<void> _fetchCheckedState() async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('checkboxStates')
        .doc('${widget.parentId}_${widget.childName}_arrival_$currentDate')
        .get();

    if (snapshot.exists && snapshot['isChecked'] != null) {
      setState(() {
        isChecked = snapshot['isChecked'];
      });

      // Check if the checkbox needs to be reset
      DateTime storedDate = (snapshot['date'] as Timestamp).toDate();
      Duration difference = DateTime.now().difference(storedDate);
      if (difference.inDays >= 1) {
        // Reset the checkbox state
        _saveCheckedState(false);
      }
    }
  }

  Future<void> _saveCheckedState(bool state) async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await FirebaseFirestore.instance
        .collection('checkboxStates')
        .doc('${widget.parentId}_${widget.childName}_arrival_$currentDate')
        .set({
      'isChecked': state,
      'date': DateTime.now(),
    });
  }

  Future<void> sendArrivedMessage() async {
    String currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    try {
      await sendNotification(widget.parentId, 'ARRIVED', '${widget.childName} has arrived at school at $currentTime');
    } catch (error) {
      // Handle error
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
          sendArrivedMessage();
          _saveCheckedState(true);
        } else {
          _saveCheckedState(false);
        }
      },
    );
  }
}

class DepartureCheckbox extends StatefulWidget {
  final String parentId;
  final String childName;
  DepartureCheckbox(this.parentId, this.childName);

  @override
  _DepartureCheckboxState createState() => _DepartureCheckboxState();
}

class _DepartureCheckboxState extends State<DepartureCheckbox> {
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    _fetchCheckedState();
  }

  Future<void> _fetchCheckedState() async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('checkboxStates')
        .doc('${widget.parentId}_${widget.childName}_departure_$currentDate')
        .get();

    if (snapshot.exists && snapshot['isChecked'] != null) {
      setState(() {
        isChecked = snapshot['isChecked'];
      });

      // Check if the checkbox needs to be reset
      DateTime storedDate = (snapshot['date'] as Timestamp).toDate();
      Duration difference = DateTime.now().difference(storedDate);
      if (difference.inDays >= 1) {
        // Reset the checkbox state
        _saveCheckedState(false);
      }
    }
  }

  Future<void> _saveCheckedState(bool state) async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await FirebaseFirestore.instance
        .collection('checkboxStates')
        .doc('${widget.parentId}_${widget.childName}_departure_$currentDate')
        .set({
      'isChecked': state,
      'date': DateTime.now(),
    });
  }

  Future<void> sendDepartedMessage() async {
    String currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    try {
      await sendNotification(widget.parentId, 'DEPARTED', '${widget.childName} has left the school at $currentTime');
    } catch (error) {
      // Handle error
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
          sendDepartedMessage();
          _saveCheckedState(true);
        } else {
          _saveCheckedState(false);
        }
      },
    );
  }
}
