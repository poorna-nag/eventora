import 'package:equatable/equatable.dart';
import 'package:eventora/features/bookings/data/booking_model.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<BookingModel> bookings;

  const BookingLoaded({required this.bookings});

  @override
  List<Object?> get props => [bookings];
}

class BookingCreating extends BookingState {}

class BookingCreated extends BookingState {}

class BookingCancelling extends BookingState {}

class BookingCancelled extends BookingState {}

class BookingError extends BookingState {
  final String message;

  const BookingError({required this.message});

  @override
  List<Object?> get props => [message];
}
