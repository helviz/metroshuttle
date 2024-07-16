import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metroshuttle/views/driver/Location.dart';


class RequestsPage extends StatelessWidget {
  Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<List<QueryDocumentSnapshot>> _getDriverRequests(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('children')
        .where('driver', isEqualTo: userId)
        .get();
    
    return querySnapshot.docs;
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
                style: TextStyle(fontSize: 24, color: Colors.red),
              ).animate().fadeIn(duration: 600.ms);
            } else {
              User user = userSnapshot.data!;
              return FutureBuilder<List<QueryDocumentSnapshot>>(
                future: _getDriverRequests(user.uid),
                builder: (context, requestsSnapshot) {
                  if (requestsSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (requestsSnapshot.hasError) {
                    return Text('Error: ${requestsSnapshot.error}');
                  } else if (!requestsSnapshot.hasData || requestsSnapshot.data!.isEmpty) {
                    return Text(
                      'No requests found',
                      style: TextStyle(fontSize: 24, color: Colors.red),
                    ).animate().fadeIn(duration: 600.ms);
                  } else {
                    List<QueryDocumentSnapshot> requests = requestsSnapshot.data!;
                    return ListView.builder(
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        var requestDoc = requests[index];
                        var request = requestDoc.data() as Map<String, dynamic>;
                        return RequestCard(request: request, docId: requestDoc.id);
                      },
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

  const RequestCard({Key? key, required this.request, required this.docId}) : super(key: key);

  @override
  _RequestCardState createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  bool isAccepted = false;
  bool isDenied = false;

  void _acceptRequest() async {
    await FirebaseFirestore.instance.collection('children').doc(widget.docId).update({
      'request': true,
    });
    setState(() {
      isAccepted = true;
    });
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
        color: isAccepted ? Colors.lightGreen : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${widget.request['name']}'),
              Text('Region: ${widget.request['region']}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _acceptRequest,
                    child: Text('Accept Request'),
                  ),
                  SizedBox(width: 8),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isDenied = true;
                          });
                        },
                        child: Text(isDenied ? 'Denied' : 'Deny Request'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            isDenied ? Colors.red : Colors.blue,
                          ),
                        ),
                      );
                    },
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
