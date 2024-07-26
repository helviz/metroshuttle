import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metroshuttle/controller/service.dart';
import 'package:metroshuttle/views/driver/Location.dart';
import 'package:metroshuttle/views/driver/Taskpage.dart';
import 'package:google_fonts/google_fonts.dart';

class RequestsPage extends StatefulWidget {
  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<List<QueryDocumentSnapshot>> _getDriverRequests(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('children')
        .where('driver', isEqualTo: userId)
        .where('request',
            isNull:
                true) // Ensure only documents with a null request field are fetched
        .get();

    return querySnapshot.docs;
  }

  void refreshRequests() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<User?>(
          future: _getCurrentUser(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (userSnapshot.hasError) {
              return Text('Error: ${userSnapshot.error}');
            } else if (!userSnapshot.hasData || userSnapshot.data == null) {
              return Text(
                'No user logged in',
                style: GoogleFonts.lato(fontSize: 24, color: Colors.red),
              ).animate().fadeIn(duration: 600.ms);
            } else {
              User user = userSnapshot.data!;
              return FutureBuilder<List<QueryDocumentSnapshot>>(
                future: _getDriverRequests(user.uid),
                builder: (context, requestsSnapshot) {
                  if (requestsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (requestsSnapshot.hasError) {
                    return Text('Error: ${requestsSnapshot.error}');
                  } else {
                    List<QueryDocumentSnapshot> requests =
                        requestsSnapshot.data!;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: requests.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'No requests found',
                                        style: GoogleFonts.lato(
                                            fontSize: 24, color: Colors.red),
                                      ).animate().fadeIn(duration: 600.ms),
                                      SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    TasksPage()),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 24.0),
                                          child: Text('Tasks',
                                              style: GoogleFonts.lato(
                                                  fontSize: 18)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(150, 50),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: requests.length,
                                  itemBuilder: (context, index) {
                                    var requestDoc = requests[index];
                                    var request = requestDoc.data()
                                        as Map<String, dynamic>;
                                    return RequestCard(
                                      request: request,
                                      docId: requestDoc.id,
                                      onUpdate:
                                          refreshRequests, // Trigger refresh
                                    );
                                  },
                                ),
                        ),
                        if (requests.isNotEmpty)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TasksPage()),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 24.0),
                              child: Text('Tasks',
                                  style: GoogleFonts.lato(fontSize: 18)),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(150, 50),
                            ),
                          ),
                      ],
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class RequestCard extends StatefulWidget {
  final Map<String, dynamic> request;
  final String docId;
  final VoidCallback onUpdate;

  const RequestCard(
      {Key? key,
      required this.request,
      required this.docId,
      required this.onUpdate})
      : super(key: key);

  @override
  _RequestCardState createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  final FirestoreService _firestoreService = FirestoreService();

  void _acceptRequest() async {
    // Update request field
    await FirebaseFirestore.instance
        .collection('children')
        .doc(widget.docId)
        .update({
      'request': true,
    });

    // Copy school data to driver routes
    await _firestoreService.copySchoolToDriverRoutes(widget.docId);

    // Get user ID
    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('children')
        .doc(widget.docId)
        .get();

    if (snapshot.exists) {
      final Map<String, dynamic>? data =
          snapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        final String? parentID = data['userId'] as String?;

        if (parentID != null) {
          sendNotification(
              parentID, "REQUEST STATUS", "Driver Accepted your request");
        } else {
          // Handle the case where userID is null
          print("userID is null");
        }
      }

      // Use the retrieved userId here (optional)
      if (mounted) {
        widget.onUpdate(); // Pass userId to onUpdate if needed
      }
    } else {
      print("Document not found for child: ${widget.docId}");
    }
  }

  void _denyRequest() async {
    await FirebaseFirestore.instance
        .collection('children')
        .doc(widget.docId)
        .update({
      'request': false,
    });

    // Get user ID
    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('children')
        .doc(widget.docId)
        .get();

    if (snapshot.exists) {
      final Map<String, dynamic>? data =
          snapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        final String? parentID = data['userId'] as String?;

        if (parentID != null) {
          sendNotification(parentID, "REQUEST STATUS", "Request Denied");
        } else {
          // Handle the case where userID is null
          print("userID is null");
        }
      }
      if (mounted) {
        widget.onUpdate(); // Trigger page refresh
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        String pickupLocation = widget.request['pickupLocation'];
        String destinationLocation = widget.request['destinationLocation'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationMapScreen(
              pickupLocation: pickupLocation,
              destinationLocation: destinationLocation,
            ),
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${widget.request['name']}',
                  style: GoogleFonts.lato(fontSize: 16)),
              Text('Region: ${widget.request['region']}',
                  style: GoogleFonts.lato(fontSize: 16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _acceptRequest,
                    child: Text('Accept Request',
                        style: GoogleFonts.lato(fontSize: 14)),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _denyRequest,
                    child: Text('Deny Request',
                        style: GoogleFonts.lato(fontSize: 14)),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 600.ms),
    );
  }
}
