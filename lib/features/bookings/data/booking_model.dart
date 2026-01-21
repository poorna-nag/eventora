import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String bookingId;
  final String eventId;
  final String userId;
  final int slotsBooked;
  final int amountPaid;
  final Timestamp bookingTime;
  final String status;
  final String? eventTitle;
  final String? eventImageUrl;
  final DateTime? eventDate;
  final bool isCheckedIn;
  final Timestamp? checkedInAt;
  final String qrData;

  const BookingModel({
    required this.bookingId,
    required this.eventId,
    required this.userId,
    required this.slotsBooked,
    required this.amountPaid,
    required this.bookingTime,
    this.status = 'confirmed',
    this.eventTitle,
    this.eventImageUrl,
    this.eventDate,
    this.isCheckedIn = false,
    this.checkedInAt,
    required this.qrData,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingId: json['bookingId'] ?? '',
      eventId: json['eventId'] ?? '',
      userId: json['userId'] ?? '',
      slotsBooked: json['slotsBooked'] ?? 0,
      amountPaid: json['amountPaid'] ?? 0,
      bookingTime: json['bookingTime'] ?? Timestamp.now(),
      status: json['status'] ?? 'confirmed',
      eventTitle: json['eventTitle'],
      eventImageUrl: json['eventImageUrl'],
      eventDate: json['eventDate'] != null
          ? (json['eventDate'] as Timestamp).toDate()
          : null,
      isCheckedIn: json['isCheckedIn'] ?? false,
      checkedInAt: json['checkedInAt'],
      qrData:
          json['qrData'] ??
          '${json['bookingId']}|${json['eventId']}|${json['userId']}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'eventId': eventId,
      'userId': userId,
      'slotsBooked': slotsBooked,
      'amountPaid': amountPaid,
      'bookingTime': bookingTime,
      'status': status,
      'eventTitle': eventTitle,
      'eventImageUrl': eventImageUrl,
      'eventDate': eventDate != null ? Timestamp.fromDate(eventDate!) : null,
      'isCheckedIn': isCheckedIn,
      'checkedInAt': checkedInAt,
      'qrData': qrData,
    };
  }

  BookingModel copyWith({
    String? bookingId,
    String? eventId,
    String? userId,
    int? slotsBooked,
    int? amountPaid,
    Timestamp? bookingTime,
    String? status,
    String? eventTitle,
    String? eventImageUrl,
    DateTime? eventDate,
    bool? isCheckedIn,
    Timestamp? checkedInAt,
    String? qrData,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      slotsBooked: slotsBooked ?? this.slotsBooked,
      amountPaid: amountPaid ?? this.amountPaid,
      bookingTime: bookingTime ?? this.bookingTime,
      status: status ?? this.status,
      eventTitle: eventTitle ?? this.eventTitle,
      eventImageUrl: eventImageUrl ?? this.eventImageUrl,
      eventDate: eventDate ?? this.eventDate,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      qrData: qrData ?? this.qrData,
    );
  }
}
