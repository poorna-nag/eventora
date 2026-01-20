import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class BookingLoadRequested extends BookingEvent {
  final String userId;

  const BookingLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class BookingCreateRequested extends BookingEvent {
  final String eventId;
  final String userId;
  final int slotsBooked;

  const BookingCreateRequested({
    required this.eventId,
    required this.userId,
    required this.slotsBooked,
  });

  @override
  List<Object?> get props => [eventId, userId, slotsBooked];
}

class BookingCancelRequested extends BookingEvent {
  final String bookingId;

  const BookingCancelRequested({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}
