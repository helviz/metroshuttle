import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:metroshuttle/views/parent/parent_homescreen.dart';

class DriverSelectionScreen extends StatelessWidget {
  final String docId;
  final String userId;

  DriverSelectionScreen({required this.docId, required this.userId});

  Future<String> _fetchRegion() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('children')
        .doc(docId)
        .get();

    return docSnapshot['region'];
  }

  Future<List<Map<String, dynamic>>> _fetchDrivers(String region) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('region', isEqualTo: region)
        .get();

    return querySnapshot.docs
        .map((doc) => {
              'driverId': doc.id,  // Add driverId for later use
              'driverName': doc['driverName'],
              'phoneNumber': doc['phoneNumber'],
              'region': doc['region'],
              'schools': doc['schools'],
              'vehicleRegistration': doc['vehicleRegistration'],
            })
        .toList();
  }

  Future<void> _updateDriverField(String driverId) async {
    await FirebaseFirestore.instance
        .collection('children')
        .doc(docId)
        .update({'driver': driverId});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Selection'),
      ),
      body: FutureBuilder<String>(
        future: _fetchRegion(),
        builder: (context, regionSnapshot) {
          if (regionSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (regionSnapshot.hasError) {
            return Center(child: Text('Error: ${regionSnapshot.error}'));
          } else if (!regionSnapshot.hasData) {
            return Center(child: Text('No region found'));
          } else {
            final region = regionSnapshot.data!;
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchDrivers(region),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('No drivers found for $region region'));
                } else {
                  final drivers = snapshot.data!;
                  return ListView.builder(
                    itemCount: drivers.length,
                    itemBuilder: (context, index) {
                      final driver = drivers[index];
                      return InkWell(
                        onTap: () async {
                          await _updateDriverField(driver['driverId']);
                          Get.offAll(() => ParentHomeScreen(userId: userId));
                        },
                        child: Card(
                          margin: EdgeInsets.all(10.0),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  driver['driverName'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text('Phone: ${driver['phoneNumber']}'),
                                Text('Region: ${driver['region']}'),
                                SizedBox(height: 10),
                                Text(
                                  'Rating: 4.5',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Schools:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                ...List<Widget>.generate(
                                  (driver['schools'] as List<dynamic>).length,
                                  (schoolIndex) => Row(
                                    children: [
                                      Icon(Icons.circle, size: 8),
                                      SizedBox(width: 5),
                                      Text((driver['schools']
                                          as List<dynamic>)[schoolIndex]),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                    'Vehicle Registration: ${driver['vehicleRegistration']}'),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
