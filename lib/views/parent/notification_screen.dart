import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<NotificationModel> notifications = [];
  String? userId;
  Set<String> processedNotificationIds = {};
  bool listenerSetUp = false;
  StreamSubscription<QuerySnapshot>? notificationSubscription;

  @override
  void initState() {
    super.initState();
    // _initializeNotifications();
    _getCurrentUserId();
  }

  @override
  void dispose() {
    notificationSubscription?.cancel();
    super.dispose();
  }

  // void _initializeNotifications() {
  //   const AndroidInitializationSettings initializationSettingsAndroid =
  //       AndroidInitializationSettings('@mipmap/ic_launcher');
  //   final InitializationSettings initializationSettings =
  //       InitializationSettings(
  //     android: initializationSettingsAndroid,
  //   );
  //   flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // }

  Future<void> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      if (!listenerSetUp) {
        _listenForNotifications(user.uid);
        listenerSetUp = true;
      }
    } else {
      print('No user is currently logged in.');
    }
  }

  void _listenForNotifications(String userId) {
    notificationSubscription = FirebaseFirestore.instance
        .collection('UserNotifications')
        .where('targetUser', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((event) {
      setState(() {
        notifications.clear();
        processedNotificationIds.clear();
      });
      for (var change in event.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final notificationData = change.doc.data();
          if (notificationData != null) {
            final notification = NotificationModel.fromJson(notificationData);
            if (!processedNotificationIds.contains(notification.id)) {
              // _showLocalNotification(notification.title, notification.body);
              if (mounted) {
                setState(() {
                  notifications.add(notification);
                  processedNotificationIds.add(notification.id);
                  notifications
                      .sort((a, b) => b.timestamp.compareTo(a.timestamp));
                });
                _listKey.currentState?.insertItem(0);
              }
            }
          }
        } else if (change.type == DocumentChangeType.removed) {
          // Notification removed, remove ID from processed set
          int index = notifications.indexWhere((n) => n.id == change.doc.id);
          if (index != -1) {
            setState(() {
              notifications.removeAt(index);
              processedNotificationIds.remove(change.doc.id);
            });
            _listKey.currentState?.removeItem(index, (context, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: _buildNotificationItem(notifications[index]),
              );
            });
          }
        }
      }
    });
  }

  // Future<void> _showLocalNotification(String title, String body) async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     'metro001',
  //     'metroshuttle',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     showWhen: false,
  //   );
  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);
  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     title,
  //     body,
  //     platformChannelSpecifics,
  //     payload: 'item x',
  //   );
  // }

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
      body: AnimatedList(
        key: _listKey,
        initialItemCount: notifications.length,
        itemBuilder: (context, index, animation) {
          return SizeTransition(
            sizeFactor: animation,
            child: _buildNotificationItem(notifications[index]),
          );
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
