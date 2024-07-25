import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:metroshuttle/controller/service.dart';
import 'package:metroshuttle/views/driver/Location.dart';
import 'package:metroshuttle/views/driver/Taskpage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metroshuttle/views/driver/server_notification.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

 
class RequestsPage extends StatefulWidget {
  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<List<QueryDocumentSnapshot>> _getDriverRequests(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('children')
        .where('driver', isEqualTo: userId)
        .where('request', isNull: true)  // Ensure only documents with a null request field are fetched
        .get();

    return querySnapshot.docs;
  }
  @override
void initState() {
  super.initState();
  _initializeNotifications();
}

void _initializeNotifications() async {
  const InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@drawable/ic_notification'),
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Configure message handling for foreground and background messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message while in the foreground!');
    print('Message data: ${message.data}');

    _handleNotification(message.data);
  });

  // Request permissions for notifications (optional for Android)
  if (Platform.isAndroid) {
    await _fcm.requestPermission();
  }

  // Handle initial message when the app is launched from a notification
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      print("Received message on app launch: $message");
      _handleNotification(message.data);
    }
  });

  await _checkStoredNotification();
}


  Future<void> _storeNotificationData(Map<String, dynamic> messageData) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('notificationData', jsonEncode(messageData));
}

  Future<void> _checkStoredNotification() async {
  final prefs = await SharedPreferences.getInstance();
  final storedData = prefs.getString('notificationData');

  if (storedData != null) {
    final dataMap = jsonDecode(storedData) as Map<String, dynamic>;
    _showLocalNotification(dataMap);
  }
}

  Future<void> _showLocalNotification(Map<String, dynamic> messageData) async {
    String childId = messageData['childId']; // Assuming the child ID is sent in the notification data
    String status = messageData['status']; 
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('channel_id', 'channel_name', channelDescription: 'channel description');

 
  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
  );

  
await flutterLocalNotificationsPlugin.show(
  0,
  'Hello, ${childId}', // Include the user's name in the title
  'Your request has been ${status}', // Include the request status
  notificationDetails,
);
}

  void _handleNotification(Map<String, dynamic> messageData) async {
    String childId = messageData['childId']; // Assuming the child ID is sent in the notification data
    String status = messageData['status']; // Assuming the request status (accepted/denied) is sent

    // Update UI based on the notification data (e.g., show a snackbar)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == 'accepted' ? 'Request accepted for child $childId' : 'Request denied for child $childId',
          style: GoogleFonts.lato(fontSize: 16),
        ),
        backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
      ),
    );

    // You can also refresh the data here if needed
    refreshRequests();

    await _storeNotificationData(messageData);
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
                  if (requestsSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (requestsSnapshot.hasError) {
                    return Text('Error: ${requestsSnapshot.error}');
                  } else {
                    List<QueryDocumentSnapshot> requests = requestsSnapshot.data!;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: requests == null || requests.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'No requests found',
                                        style: GoogleFonts.lato(fontSize: 24, color: Colors.red),
                                      ).animate().fadeIn(duration: 600.ms),
                                      SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => TasksPage()),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                                          child: Text('Tasks', style: GoogleFonts.lato(fontSize: 18)),
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
                                    var request = requestDoc.data() as Map<String, dynamic>;
                                    var deviceToken = request['deviceToken'];
                                    return RequestCard(
                                      request: request,
                                      docId: requestDoc.id,
                                      onUpdate: refreshRequests,
                                      deviceToken: deviceToken, // Trigger refresh
                                    );
                                  },
                                ),
                        ),
                        if (requests != null && requests.isNotEmpty)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => TasksPage()),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                              child: Text('Tasks', style: GoogleFonts.lato(fontSize: 18)),
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
  final String deviceToken;

  const RequestCard({Key? key, required this.request, required this.docId, required this.onUpdate, required this.deviceToken}) : super(key: key);

  @override
  _RequestCardState createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  final FirestoreService _firestoreService = FirestoreService();

  void _acceptRequest() async {
    await FirebaseFirestore.instance.collection('children').doc(widget.docId).update({
      'request': true,
    });
    await _firestoreService.copySchoolToDriverRoutes(widget.docId);
    widget.onUpdate(); // Trigger page refresh
  }

  void _denyRequest() async {
    await FirebaseFirestore.instance.collection('children').doc(widget.docId).update({
      'request': false,
    });
    widget.onUpdate(); // Trigger page refresh
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
              Text('Name: ${widget.request['name']}', style: GoogleFonts.lato(fontSize: 16)),
              Text('Region: ${widget.request['region']}', style: GoogleFonts.lato(fontSize: 16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton( 
                    onPressed: () { 
                      _acceptRequest();
                      PushNotificationService.sendNotificationToDriver(widget.deviceToken, context);
                      }, 
                    child: Text('Accept Request', style: GoogleFonts.lato(fontSize: 14)),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                     onPressed: () {
                    _denyRequest();
                    PushNotificationService.sendNotificationToDriver(widget.deviceToken, context);
                    }, 
                    child: Text('Deny Request', style: GoogleFonts.lato(fontSize: 14)),
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


