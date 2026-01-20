import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventora/features/bookings/bloc/booking_event.dart';
import 'package:eventora/features/bookings/bloc/booking_state.dart';
import 'package:eventora/features/bookings/data/booking_repository.dart';
import 'package:eventora/features/auth/data/repo/auth_repo_impl.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository bookingRepository;
  final AuthRepository authRepository;
  StreamSubscription? _bookingsSubscription;

  BookingBloc({
    required this.bookingRepository,
    required this.authRepository,
  }) : super(BookingInitial()) {
    on<BookingLoadRequested>(_onBookingLoadRequested);
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
          emit(BookingLoaded(bookings: bookings));
        }
      },
      onError: (error) {
        if (!isClosed) {
          emit(BookingError(message: error.toString()));
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
      await bookingRepository.createBooking(
        eventId: event.eventId,
        userId: event.userId,
        slotsBooked: event.slotsBooked,
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
