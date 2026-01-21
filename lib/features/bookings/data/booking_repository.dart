import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventora/features/bookings/data/booking_model.dart';
import 'package:eventora/features/events/data/event_repository.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EventRepository _eventRepository = EventRepository();

  Future<String> createBooking({
    required String eventId,
    required String userId,
    required int slotsBooked,
  }) async {
    try {
      final event = await _eventRepository.getEventById(eventId);

      if (event == null) {
        throw Exception('Event not found');
      }

      if (event.availableSlots < slotsBooked) {
        throw Exception('Not enough slots available');
      }

      final docRef = _firestore.collection('bookings').doc();

      // Generate unique QR data for the ticket
      final qrData =
          '${docRef.id}|$eventId|$userId|${DateTime.now().millisecondsSinceEpoch}';

      final booking = BookingModel(
        bookingId: docRef.id,
        eventId: eventId,
        userId: userId,
        slotsBooked: slotsBooked,
        amountPaid: event.price * slotsBooked,
        bookingTime: Timestamp.now(),
        status: 'confirmed',
        eventTitle: event.title,
        eventImageUrl: event.imageUrl,
        eventDate: event.date,
        qrData: qrData,
      );

      await _firestore.runTransaction((transaction) async {
        final eventDoc = _firestore.collection('events').doc(eventId);
        final eventSnapshot = await transaction.get(eventDoc);

        if (!eventSnapshot.exists) {
          throw Exception('Event not found');
        }

        final currentSlots = eventSnapshot.data()!['availableSlots'] as int;

        if (currentSlots < slotsBooked) {
          throw Exception('Not enough slots available');
        }

        transaction.set(docRef, booking.toJson());
        transaction.update(eventDoc, {
          'availableSlots': currentSlots - slotsBooked,
        });
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .get();

      final bookings = snapshot.docs
          .map((doc) => BookingModel.fromJson(doc.data()))
          .toList();
      // Sort in memory to avoid Firebase index
      bookings.sort((a, b) => b.bookingTime.compareTo(a.bookingTime));
      return bookings;
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  Stream<List<BookingModel>> getUserBookingsStream(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final bookings = snapshot.docs
              .map((doc) => BookingModel.fromJson(doc.data()))
              .toList();
          // Sort in memory to avoid Firebase index
          bookings.sort((a, b) => b.bookingTime.compareTo(a.bookingTime));
          return bookings;
        });
  }

  Future<List<BookingModel>> getEventBookings(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('eventId', isEqualTo: eventId)
          .get();

      final bookings = snapshot.docs
          .map((doc) => BookingModel.fromJson(doc.data()))
          .toList();
      // Sort in memory to avoid Firebase index
      bookings.sort((a, b) => b.bookingTime.compareTo(a.bookingTime));
      return bookings;
    } catch (e) {
      throw Exception('Failed to fetch event bookings: $e');
    }
  }

  Stream<List<BookingModel>> getEventBookingsStream(String eventId) {
    return _firestore
        .collection('bookings')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
          final bookings = snapshot.docs
              .map((doc) => BookingModel.fromJson(doc.data()))
              .toList();
          // Sort in memory to avoid Firebase index
          bookings.sort((a, b) => b.bookingTime.compareTo(a.bookingTime));
          return bookings;
        });
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      final bookingDoc = await _firestore
          .collection('bookings')
          .doc(bookingId)
          .get();

      if (!bookingDoc.exists) {
        throw Exception('Booking not found');
      }

      final booking = BookingModel.fromJson(bookingDoc.data()!);

      await _firestore.runTransaction((transaction) async {
        final eventDoc = _firestore.collection('events').doc(booking.eventId);
        final eventSnapshot = await transaction.get(eventDoc);

        if (eventSnapshot.exists) {
          final currentSlots = eventSnapshot.data()!['availableSlots'] as int;
          transaction.update(eventDoc, {
            'availableSlots': currentSlots + booking.slotsBooked,
          });
        }

        transaction.update(_firestore.collection('bookings').doc(bookingId), {
          'status': 'cancelled',
        });
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  Future<int> getBookingCountForEvent(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('eventId', isEqualTo: eventId)
          .where('status', isEqualTo: 'confirmed')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get booking count: $e');
    }
  }

  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();

      if (!doc.exists) return null;

      return BookingModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch booking: $e');
    }
  }
}
