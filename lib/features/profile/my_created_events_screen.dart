import 'package:eventora/core/widgets/event_card.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_state.dart';
import 'package:eventora/features/events/data/event_repository.dart';
import 'package:eventora/features/events/event_details_screen.dart';
import 'package:eventora/features/events/event_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCreatedEventsScreen extends StatelessWidget {
  final String userId;

  const MyCreatedEventsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final EventRepository eventRepository = EventRepository();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Created Events',
          style: TextStyle(color: Colors.orange),
        ),
        iconTheme: const IconThemeData(color: Colors.orange),
      ),
      body: StreamBuilder(
        stream: eventRepository.getEventsByCreatorStream(userId),
        builder: (context, snapshot) {
          print(
            'MyCreatedEventsScreen - ConnectionState: ${snapshot.connectionState}',
          );
          print('MyCreatedEventsScreen - HasData: ${snapshot.hasData}');
          print(
            'MyCreatedEventsScreen - Data length: ${snapshot.data?.length ?? 0}',
          );

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('MyCreatedEventsScreen - Error: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 80, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading events',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No events created yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first event to see it here',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          final events = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return EventCard(
                event: event,
                onTap: () {
                  final authState = context.read<AuthBloc>().state;
                  final isOwner =
                      authState is AuthAuthenticated &&
                      authState.user.uid == userId;

                  if (isOwner) {
                    // Navigate to tracking screen for my own events
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventTrackingScreen(event: event),
                      ),
                    );
                  } else {
                    // Navigate to event details for others' events
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsScreen(event: event),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
