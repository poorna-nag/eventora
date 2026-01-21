import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventora/features/bookings/bloc/booking_event.dart';
import 'package:eventora/features/bookings/bloc/booking_state.dart';
import 'package:eventora/features/bookings/data/booking_repository.dart';
import 'package:eventora/features/auth/data/repo/auth_repo_impl.dart';
import 'package:eventora/features/bookings/data/booking_model.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository bookingRepository;
  final AuthRepository authRepository;
  StreamSubscription? _bookingsSubscription;

  BookingBloc({required this.bookingRepository, required this.authRepository})
    : super(BookingInitial()) {
    on<BookingLoadRequested>(_onBookingLoadRequested);
    on<_BookingsUpdated>(_onBookingsUpdated);
    on<_BookingsError>(_onBookingsError);
    on<BookingCreateRequested>(_onBookingCreateRequested);
    on<BookingCancelRequested>(_onBookingCancelRequested);
  }

  Future<void> _onBookingLoadRequested(
    BookingLoadRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    await _bookingsSubscription?.cancel();
    _bookingsSubscription = bookingRepository
        .getUserBookingsStream(event.userId)
        .listen(
          (bookings) {
            if (!isClosed) {
              add(_BookingsUpdated(bookings: bookings));
            }
          },
          onError: (error) {
            if (!isClosed) {
              add(_BookingsError(message: error.toString()));
            }
          },
        );
  }

  Future<void> _onBookingCreateRequested(
    BookingCreateRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingCreating());

    try {
      // Calculate Splits
      // Platform Fee: 10%
      // Razorpay Fee: ~2% (Estimated)
      // Organizer Earnings: Remaining
      final double totalAmount = event.totalAmount;
      final double platformFee = totalAmount * 0.10;
      final double razorpayFee = totalAmount * 0.02;
      final double organizerEarnings = totalAmount - platformFee - razorpayFee;

      await bookingRepository.createBooking(
        eventId: event.eventId,
        userId: event.userId,
        slotsBooked: event.slotsBooked,
        paymentId: event.paymentId,
        amountPaid: totalAmount.toInt(),
        platformFee: platformFee,
        razorpayFee: razorpayFee,
        organizerEarnings: organizerEarnings,
      );

      await authRepository.incrementBookingsMade(event.userId);

      emit(BookingCreated());
      add(BookingLoadRequested(userId: event.userId));
    } catch (e) {
      emit(BookingError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onBookingCancelRequested(
    BookingCancelRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingCancelling());

    try {
      await bookingRepository.cancelBooking(event.bookingId);
      emit(BookingCancelled());
    } catch (e) {
      emit(BookingError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<void> close() {
    _bookingsSubscription?.cancel();
    return super.close();
  }
}

/// Internal event used to safely update state from the Firestore stream
/// without emitting after the original event handler has completed.
class _BookingsUpdated extends BookingEvent {
  final List<BookingModel> bookings;

  const _BookingsUpdated({required this.bookings});

  @override
  List<Object?> get props => [bookings];
}

class _BookingsError extends BookingEvent {
  final String message;

  const _BookingsError({required this.message});

  @override
  List<Object?> get props => [message];
}

void _onBookingsUpdated(_BookingsUpdated event, Emitter<BookingState> emit) {
  emit(BookingLoaded(bookings: event.bookings));
}

void _onBookingsError(_BookingsError event, Emitter<BookingState> emit) {
  emit(BookingError(message: event.message));
}
