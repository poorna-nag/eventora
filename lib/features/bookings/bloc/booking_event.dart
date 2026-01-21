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
  final double totalAmount;
  final String paymentId;

  const BookingCreateRequested({
    required this.eventId,
    required this.userId,
    required this.slotsBooked,
    required this.totalAmount,
    required this.paymentId,
  });

  @override
  List<Object?> get props => [
    eventId,
    userId,
    slotsBooked,
    totalAmount,
    paymentId,
  ];
}

class BookingCancelRequested extends BookingEvent {
  final String bookingId;

  const BookingCancelRequested({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}
