import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String eventId;
  final String title;
  final String description;
  final DateTime date;
  final DateTime time;
  final String venue;
  final int price;
  final int totalSlots;
  final int availableSlots;
  final String createdBy;
  final String imageUrl;
  final String category;
  final Timestamp createdAt;
  final double? latitude;
  final double? longitude;
  final String? address;

  const EventModel({
    required this.eventId,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.venue,
    required this.price,
    required this.totalSlots,
    required this.availableSlots,
    required this.createdBy,
    required this.imageUrl,
    required this.category,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.address,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      eventId: json['eventId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      time: (json['time'] as Timestamp).toDate(),
      venue: json['venue'] ?? '',
      price: json['price'] ?? 0,
      totalSlots: json['totalSlots'] ?? 0,
      availableSlots: json['availableSlots'] ?? 0,
      createdBy: json['createdBy'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'Other',
      createdAt: json['createdAt'] ?? Timestamp.now(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'time': Timestamp.fromDate(time),
      'venue': venue,
      'price': price,
      'totalSlots': totalSlots,
      'availableSlots': availableSlots,
      'createdBy': createdBy,
      'imageUrl': imageUrl,
      'category': category,
      'createdAt': createdAt,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  EventModel copyWith({
    String? eventId,
    String? title,
    String? description,
    DateTime? date,
    DateTime? time,
    String? venue,
    int? price,
    int? totalSlots,
    int? availableSlots,
    String? createdBy,
    String? imageUrl,
    String? category,
    Timestamp? createdAt,
    double? latitude,
    double? longitude,
    String? address,
  }) {
    return EventModel(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      venue: venue ?? this.venue,
      price: price ?? this.price,
      totalSlots: totalSlots ?? this.totalSlots,
      availableSlots: availableSlots ?? this.availableSlots,
      createdBy: createdBy ?? this.createdBy,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
    );
  }
}