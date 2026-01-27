import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventora/features/bookings/data/booking_repository.dart';
import 'package:eventora/features/join_requests/data/join_request_model.dart';
import 'package:eventora/features/notifications/data/notification_repository.dart';

class JoinRequestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a join request
  Future<void> createJoinRequest(JoinRequestModel request) async {
    try {
      final docRef = _firestore.collection('join_requests').doc();
      final requestWithId = request.copyWith(requestId: docRef.id);
      await docRef.set(requestWithId.toJson());
    } catch (e) {
      throw Exception('Failed to create join request: $e');
    }
  }

  // Get join requests for a specific event (for host)
  Stream<List<JoinRequestModel>> getEventJoinRequests(String eventId) {
    return _firestore
        .collection('join_requests')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs
              .map((doc) => JoinRequestModel.fromJson(doc.data()))
              .toList();
          requests.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
          return requests;
        });
  }

  // Get join requests by user (for user to see their requests)
  Stream<List<JoinRequestModel>> getUserJoinRequests(String userId) {
    return _firestore
        .collection('join_requests')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs
              .map((doc) => JoinRequestModel.fromJson(doc.data()))
              .toList();
          requests.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
          return requests;
        });
  }

  // Get pending requests for host
  Stream<List<JoinRequestModel>> getHostPendingRequests(String hostId) {
    return _firestore
        .collection('join_requests')
        .where('hostId', isEqualTo: hostId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs
              .map((doc) => JoinRequestModel.fromJson(doc.data()))
              .toList();
          requests.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
          return requests;
        });
  }

  // Check if user has already requested to join
  Future<JoinRequestModel?> getUserRequestForEvent(
    String userId,
    String eventId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('join_requests')
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return JoinRequestModel.fromJson(snapshot.docs.first.data());
    } catch (e) {
      throw Exception('Failed to check join request: $e');
    }
  }

  // Accept a join request
  Future<void> acceptJoinRequest(String requestId) async {
    try {
      final docSnapshot = await _firestore
          .collection('join_requests')
          .doc(requestId)
          .get();
      if (!docSnapshot.exists) throw Exception('Request not found');

      final request = JoinRequestModel.fromJson(docSnapshot.data()!);

      // Update status to accepted
      await _firestore.collection('join_requests').doc(requestId).update({
        'status': 'accepted',
        'respondedAt': Timestamp.now(),
      });

      if (request.eventPrice == 0) {
        // Free event: Auto-confirm booking
        try {
          // Check if user already booked to avoid double booking
          final bookings = await BookingRepository().getUserBookings(
            request.userId,
          );
          final hasBooked = bookings.any(
            (b) => b.eventId == request.eventId && b.status == 'confirmed',
          );

          if (!hasBooked) {
            await BookingRepository().createBooking(
              eventId: request.eventId,
              userId: request.userId,
              slotsBooked: request.slotsRequested,
              amountPaid: 0,
              paymentId:
                  'free_via_request_${Timestamp.now().millisecondsSinceEpoch}',
              platformFee: 0,
              organizerEarnings: 0,
              razorpayFee: 0,
            );

            // Mark as paid since it's free
            await _firestore.collection('join_requests').doc(requestId).update({
              'isPaid': true,
            });
          }
        } catch (e) {
          print('Error auto-booking free event: $e');
          // Don't throw here, as acceptance was successful
        }
      } else {
        // Paid event: Send notification
        await NotificationRepository().sendJoinRequestAcceptedNotification(
          userId: request.userId,
          eventId: request.eventId,
          eventTitle: request.eventTitle,
        );
      }
    } catch (e) {
      throw Exception('Failed to accept join request: $e');
    }
  }

  // Reject a join request
  Future<void> rejectJoinRequest(String requestId) async {
    try {
      final docSnapshot = await _firestore
          .collection('join_requests')
          .doc(requestId)
          .get();
      if (!docSnapshot.exists) throw Exception('Request not found');

      final request = JoinRequestModel.fromJson(docSnapshot.data()!);

      await _firestore.collection('join_requests').doc(requestId).update({
        'status': 'rejected',
        'respondedAt': Timestamp.now(),
      });

      // Send rejection notification
      await NotificationRepository().sendJoinRequestRejectedNotification(
        userId: request.userId,
        eventId: request.eventId,
        eventTitle: request.eventTitle,
      );
    } catch (e) {
      throw Exception('Failed to reject join request: $e');
    }
  }

  // Mark request as paid
  Future<void> markRequestAsPaid(String requestId) async {
    try {
      await _firestore.collection('join_requests').doc(requestId).update({
        'isPaid': true,
      });
    } catch (e) {
      throw Exception('Failed to mark request as paid: $e');
    }
  }

  // Delete a join request
  Future<void> deleteJoinRequest(String requestId) async {
    try {
      await _firestore.collection('join_requests').doc(requestId).delete();
    } catch (e) {
      throw Exception('Failed to delete join request: $e');
    }
  }
}
