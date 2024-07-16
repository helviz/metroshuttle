import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  final List<String> notifications = [
    'Bus is running 5 minutes late',
    'New driver assigned to your route',
    'Reminder: Bus fee due tomorrow',
    'Safety alert: Please ensure your child wears a seatbelt',
    'Updated route information available',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Icon(Icons.notification_important, color: Colors.green),
              title: Text(notifications[index]),
              subtitle: Text('2 hours ago'), // Placeholder for notification time
            ),
          );
        },
      ),
    );
  }
}
