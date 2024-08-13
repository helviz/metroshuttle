import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> notifications = [];
  String? userId;
  StreamSubscription<QuerySnapshot>? notificationSubscription;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  @override
  void dispose() {
    notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      _fetchAndListenForNotifications(user.uid);
    } else {
      print('No user is currently logged in.');
    }
  }

  void _fetchAndListenForNotifications(String userId) {
    // Fetch all existing notifications first
    FirebaseFirestore.instance
        .collection('UserNotifications')
        .where('targetUser', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          notifications = snapshot.docs
              .map((doc) => NotificationModel.fromJson(doc.data()))
              .toList();
        });
      }
    });

    // Listen for new notifications in real-time
    notificationSubscription = FirebaseFirestore.instance
        .collection('UserNotifications')
        .where('targetUser', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final notificationData = change.doc.data();
          if (notificationData != null) {
            final notification = NotificationModel.fromJson(notificationData);
            if (mounted) {
              setState(() {
                notifications.insert(0, notification);
              });
            }
          }
        }
      }
    });
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final formattedDate =
        DateFormat('yyyy-MM-dd – kk:mm').format(notification.timestamp);
    return Card(
      child: ListTile(
        leading: Icon(Icons.notification_important, color: Colors.green),
        title: Text(notification.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            SizedBox(height: 4.0),
            Text(formattedDate,
                style: TextStyle(fontSize: 12.0, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationItem(notifications[index]);
        },
      ),
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };
}
