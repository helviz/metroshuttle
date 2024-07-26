class Notification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String targetUser;

  Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp, 
    required this.targetUser,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int), // Handle null gracefully
        targetUser: json['targetUser'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'targetUser': targetUser,
      };
}
