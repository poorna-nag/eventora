import 'package:cloud_firestore/cloud_firestore.dart';

class JoinRequestModel {
  final String requestId;
  final String eventId;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final String eventTitle;
  final String hostId;
  final int slotsRequested;
  final String status; // 'pending', 'accepted', 'rejected'
  final Timestamp requestedAt;
  final Timestamp? respondedAt;
  final int eventPrice;
  final bool isPaid;

  const JoinRequestModel({
    required this.requestId,
    required this.eventId,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.eventTitle,
    required this.hostId,
    required this.slotsRequested,
    this.status = 'pending',
    required this.requestedAt,
    this.respondedAt,
    required this.eventPrice,
    this.isPaid = false,
  });

  factory JoinRequestModel.fromJson(Map<String, dynamic> json) {
    return JoinRequestModel(
      requestId: json['requestId'] ?? '',
      eventId: json['eventId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userProfileImage: json['userProfileImage'],
      eventTitle: json['eventTitle'] ?? '',
      hostId: json['hostId'] ?? '',
      slotsRequested: json['slotsRequested'] ?? 1,
      status: json['status'] ?? 'pending',
      requestedAt: json['requestedAt'] ?? Timestamp.now(),
      respondedAt: json['respondedAt'],
      eventPrice: json['eventPrice'] ?? 0,
      isPaid: json['isPaid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'eventTitle': eventTitle,
      'hostId': hostId,
      'slotsRequested': slotsRequested,
      'status': status,
      'requestedAt': requestedAt,
      'respondedAt': respondedAt,
      'eventPrice': eventPrice,
      'isPaid': isPaid,
    };
  }

  JoinRequestModel copyWith({
    String? requestId,
    String? eventId,
    String? userId,
    String? userName,
    String? userProfileImage,
    String? eventTitle,
    String? hostId,
    int? slotsRequested,
    String? status,
    Timestamp? requestedAt,
    Timestamp? respondedAt,
    int? eventPrice,
    bool? isPaid,
  }) {
    return JoinRequestModel(
      requestId: requestId ?? this.requestId,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      eventTitle: eventTitle ?? this.eventTitle,
      hostId: hostId ?? this.hostId,
      slotsRequested: slotsRequested ?? this.slotsRequested,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      eventPrice: eventPrice ?? this.eventPrice,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
