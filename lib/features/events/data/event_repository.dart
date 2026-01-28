import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventora/features/events/data/event_model.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createEvent(EventModel event) async {
    try {
      final docRef = event.eventId.isNotEmpty
          ? _firestore.collection('events').doc(event.eventId)
          : _firestore.collection('events').doc();

      final eventWithId = event.copyWith(eventId: docRef.id);

      await docRef.set(eventWithId.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  Future<List<EventModel>> getAllEvents() async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EventModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  Stream<List<EventModel>> getEventsStream() {
    return _firestore
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EventModel.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<List<EventModel>> getEventsByCreator(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('createdBy', isEqualTo: userId)
          .get();

      final events = snapshot.docs
          .map((doc) => EventModel.fromJson(doc.data()))
          .toList();
      // Sort in memory to avoid needing Firebase index
      events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return events;
    } catch (e) {
      throw Exception('Failed to fetch user events: $e');
    }
  }

  Stream<List<EventModel>> getEventsByCreatorStream(String userId) {
    return _firestore
        .collection('events')
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final events = snapshot.docs
              .map((doc) => EventModel.fromJson(doc.data()))
              .toList();
          // Sort in memory to avoid needing Firebase index
          events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return events;
        });
  }

  Future<EventModel?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();

      if (!doc.exists) return null;

      return EventModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch event: $e');
    }
  }

  Future<void> updateEvent(EventModel event) async {
    try {
      await _firestore
          .collection('events')
          .doc(event.eventId)
          .update(event.toJson());
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  Future<void> updateAvailableSlots(String eventId, int newSlotCount) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'availableSlots': newSlotCount,
      });
    } catch (e) {
      throw Exception('Failed to update slots: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  Future<List<EventModel>> searchEvents(String query) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .orderBy('title')
          .get();

      final allEvents = snapshot.docs
          .map((doc) => EventModel.fromJson(doc.data()))
          .toList();

      return allEvents.where((event) {
        final titleMatch = event.title.toLowerCase().contains(
          query.toLowerCase(),
        );
        final descMatch = event.description.toLowerCase().contains(
          query.toLowerCase(),
        );
        final venueMatch = event.venue.toLowerCase().contains(
          query.toLowerCase(),
        );
        return titleMatch || descMatch || venueMatch;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search events: $e');
    }
  }

  Future<List<EventModel>> filterEvents({
    String? category,
    int? maxPrice,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      Query query = _firestore.collection('events');

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();
      var events = snapshot.docs
          .map((doc) => EventModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      if (maxPrice != null) {
        events = events.where((event) => event.price <= maxPrice).toList();
      }

      if (fromDate != null) {
        events = events
            .where(
              (event) =>
                  event.date.isAfter(fromDate) ||
                  event.date.isAtSameMomentAs(fromDate),
            )
            .toList();
      }

      if (toDate != null) {
        events = events
            .where(
              (event) =>
                  event.date.isBefore(toDate) ||
                  event.date.isAtSameMomentAs(toDate),
            )
            .toList();
      }

      return events;
    } catch (e) {
      throw Exception('Failed to filter events: $e');
    }
  }
}
