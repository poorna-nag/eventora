import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventora/features/notifications/data/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final notifications = snapshot.docs
              .map((doc) => NotificationModel.fromJson(doc.data()))
              .toList();
          notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return notifications;
        });
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // This would typically be done by a Cloud Function trigger, but for this demo
  // we can simulate it or call it when creating an event.
  // Ideally, 'sendNotificationToAllUsers' is a heavy operation and should NOT be done client-side
  // in a real production app with many users.
  Future<void> createNotificationForEvent(
    String eventId,
    String eventTitle,
    String creatorName,
  ) async {
    // WARNING: heavy operation. In production use Cloud Functions.
    // For this demo, we will create a global notification document or
    // simply let the UI query for 'global' notifications.

    // Simpler approach for demo: Create a 'global_notifications' collection
    // that all users subscribe to.

    try {
      final notificationId = _firestore
          .collection('global_notifications')
          .doc()
          .id;
      final notification = NotificationModel(
        id: notificationId,
        title: 'New Event Alert! 🎉',
        body: '$creatorName is hosting "$eventTitle". Check it out!',
        timestamp: DateTime.now(),
        eventId: eventId,
        type: 'event_created',
      );

      await _firestore
          .collection('global_notifications')
          .doc(notificationId)
          .set(notification.toJson());
    } catch (e) {
      print('Error creating global notification: $e');
    }
  }

  Future<void> sendJoinRequestAcceptedNotification({
    required String userId,
    required String eventId,
    required String eventTitle,
  }) async {
    try {
      final notificationId = _firestore.collection('notifications').doc().id;
      final notification = NotificationModel(
        id: notificationId,
        title: 'Request Accepted! ✅',
        body:
            'Your request to join "$eventTitle" has been accepted. Complete payment to secure your spot.',
        timestamp: DateTime.now(),
        eventId: eventId,
        type: 'request_accepted',
        userId: userId,
      );

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .set(notification.toJson());
    } catch (e) {
      print('Error sending join request accepted notification: $e');
    }
  }

  Future<void> sendJoinRequestRejectedNotification({
    required String userId,
    required String eventId,
    required String eventTitle,
  }) async {
    try {
      final notificationId = _firestore.collection('notifications').doc().id;
      final notification = NotificationModel(
        id: notificationId,
        title: 'Request Rejected ❌',
        body:
            'Your request to join "$eventTitle" has been rejected by the host.',
        timestamp: DateTime.now(),
        eventId: eventId,
        type: 'request_rejected',
        userId: userId,
      );

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .set(notification.toJson());
    } catch (e) {
      print('Error sending join request rejected notification: $e');
    }
  }
}
