import 'package:eventora/core/widgets/booking_card.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_state.dart';
import 'package:eventora/features/bookings/bloc/booking_bloc.dart';
import 'package:eventora/features/bookings/bloc/booking_event.dart';
import 'package:eventora/features/bookings/bloc/booking_state.dart';
import 'package:eventora/features/events/event_details_screen.dart';
import 'package:eventora/features/events/data/event_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final EventRepository _eventRepository = EventRepository();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<BookingBloc>().add(
        BookingLoadRequested(userId: authState.user.uid),
      );
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<BookingBloc>().add(
        BookingCancelRequested(bookingId: bookingId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            context.read<BookingBloc>().add(
              BookingLoadRequested(userId: authState.user.uid),
            );
          }
        } else if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'My Bookings',
            style: TextStyle(color: Colors.orange),
          ),
          iconTheme: const IconThemeData(color: Colors.orange),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthAuthenticated) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Please login to view bookings',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return BlocBuilder<BookingBloc, BookingState>(
              builder: (context, bookingState) {
                if (bookingState is BookingLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (bookingState is BookingError) {
                  return Center(child: Text('Error: ${bookingState.message}'));
                }

                if (bookingState is BookingLoaded) {
                  if (bookingState.bookings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No bookings yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Book an event to see it here',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<BookingBloc>().add(
                        BookingLoadRequested(userId: authState.user.uid),
                      );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: bookingState.bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookingState.bookings[index];
                        return BookingCard(
                          booking: booking,
                          onTap: () async {
                            final event = await _eventRepository.getEventById(
                              booking.eventId,
                            );
                            if (event != null && mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EventDetailsScreen(event: event),
                                ),
                              );
                            }
                          },
                          onCancel: booking.status != 'cancelled'
                              ? () => _cancelBooking(booking.bookingId)
                              : null,
                        );
                      },
                    ),
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            );
          },
        ),
      ),
    );
  }
}
