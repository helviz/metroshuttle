class Notification {
  final String id;
  final String title;
  final String body;
  final DateTime? timestamp;

  Notification({
    required this.id,
    required this.title,
    required this.body,
    this.timestamp,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        timestamp: json['timestamp'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        if (timestamp != null) 'timestamp': timestamp!.millisecondsSinceEpoch,
      };
}
