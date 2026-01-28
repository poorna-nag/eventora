import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventora/core/utils/date_formatter.dart';
import 'package:eventora/features/events/data/event_model.dart';
import 'package:eventora/features/events/event_details_screen.dart';
import 'package:eventora/features/notifications/data/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventora/features/notifications/data/notification_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationModel> _globalNotifications = [];
  final List<NotificationModel> _personalNotifications = [];
  StreamSubscription? _globalSub;
  StreamSubscription? _personalSub;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupStreams();
    _markAllRead();
  }

  void _markAllRead() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      NotificationRepository().markAllAsRead(authState.user.uid);
    }
  }

  void _setupStreams() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final repo = NotificationRepository();

      _globalSub = repo.getGlobalNotifications().listen((notifications) {
        setState(() {
          _globalNotifications.clear();
          _globalNotifications.addAll(notifications);
          _isLoading = false;
        });
      });

      _personalSub = repo.getUserNotifications(authState.user.uid).listen((
        notifications,
      ) {
        setState(() {
          _personalNotifications.clear();
          _personalNotifications.addAll(notifications);
          _isLoading = false;
        });
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _globalSub?.cancel();
    _personalSub?.cancel();
    super.dispose();
  }

  List<NotificationModel> get _allNotifications {
    final all = [..._globalNotifications, ..._personalNotifications];
    all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return all;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allNotifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: _allNotifications.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                return _buildNotificationCard(
                  context,
                  _allNotifications[index],
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
  ) {
    return GestureDetector(
      onTap: () async {
        if (notification.eventId != null) {
          try {
            final eventDoc = await FirebaseFirestore.instance
                .collection('events')
                .doc(notification.eventId)
                .get();

            if (eventDoc.exists) {
              final event = EventModel.fromFirestore(eventDoc);
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventDetailsScreen(event: event),
                  ),
                );
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event no longer exists')),
                );
              }
            }
          } catch (e) {
            print('Error fetching event: $e');
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getIconColor(notification.type).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(notification.type),
                color: _getIconColor(notification.type),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormatter.getTimeAgo(notification.timestamp),
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'event_created':
        return Icons.celebration;
      case 'request_accepted':
        return Icons.check_circle;
      case 'request_rejected':
        return Icons.cancel;
      case 'booking_confirmed':
        return Icons.confirmation_number;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'event_created':
        return Colors.orange;
      case 'request_accepted':
        return Colors.green;
      case 'request_rejected':
        return Colors.red;
      case 'booking_confirmed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
