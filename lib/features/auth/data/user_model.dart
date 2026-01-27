import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String? phoneNumber;
  final String? bio;
  final String? workplace;
  final List<String>? interests;
  final String? instagram;
  final String? twitter;
  final Timestamp? createdAt;
  final int eventsCreated;
  final int bookingsMade;
  final bool? isAgeVerified;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.phoneNumber,
    this.bio,
    this.workplace,
    this.interests,
    this.instagram,
    this.twitter,
    this.createdAt,
    this.eventsCreated = 0,
    this.bookingsMade = 0,
    this.isAgeVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      phoneNumber: json['phoneNumber'],
      bio: json['bio'],
      workplace: json['workplace'],
      interests: json['interests'] != null
          ? List<String>.from(json['interests'])
          : null,
      instagram: json['instagram'],
      twitter: json['twitter'],
      createdAt: json['createdAt'],
      eventsCreated: json['eventsCreated'] ?? 0,
      bookingsMade: json['bookingsMade'] ?? 0,
      isAgeVerified: json['isAgeVerified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'workplace': workplace,
      'interests': interests,
      'instagram': instagram,
      'twitter': twitter,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'eventsCreated': eventsCreated,
      'bookingsMade': bookingsMade,
      'isAgeVerified': isAgeVerified,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? profileImageUrl,
    String? phoneNumber,
    String? bio,
    String? workplace,
    List<String>? interests,
    String? instagram,
    String? twitter,
    Timestamp? createdAt,
    int? eventsCreated,
    int? bookingsMade,
    bool? isAgeVerified,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      workplace: workplace ?? this.workplace,
      interests: interests ?? this.interests,
      instagram: instagram ?? this.instagram,
      twitter: twitter ?? this.twitter,
      createdAt: createdAt ?? this.createdAt,
      eventsCreated: eventsCreated ?? this.eventsCreated,
      bookingsMade: bookingsMade ?? this.bookingsMade,
      isAgeVerified: isAgeVerified ?? this.isAgeVerified,
    );
  }
}
