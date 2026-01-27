class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String? eventId;
  final String
  type; // 'event_created', 'booking_confirmed', 'join_request', etc.
  final String? userId; // Null for global, set for specific user
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.eventId,
    required this.type,
    this.userId,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] as dynamic).toDate()
          : DateTime.now(),
      eventId: json['eventId'],
      type: json['type'] ?? 'general',
      userId: json['userId'],
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp,
      'eventId': eventId,
      'type': type,
      'userId': userId,
      'isRead': isRead,
    };
  }
}
