import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventora/features/moderation/data/moderation_models.dart';

class ModerationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Report a user or event
  Future<void> submitReport({
    required String reporterId,
    required String reporterName,
    required String reportedUserId,
    String? reportedEventId,
    required String reportType,
    required String reason,
    required String description,
  }) async {
    try {
      final reportId = _firestore.collection('reports').doc().id;

      final report = ReportModel(
        reportId: reportId,
        reporterId: reporterId,
        reporterName: reporterName,
        reportedUserId: reportedUserId,
        reportedEventId: reportedEventId,
        reportType: reportType,
        reason: reason,
        description: description,
        createdAt: DateTime.now(),
        status: 'pending',
      );

      await _firestore.collection('reports').doc(reportId).set(report.toMap());
    } catch (e) {
      throw Exception('Failed to submit report: $e');
    }
  }

  // Block a user
  Future<void> blockUser({
    required String blockerId,
    required String blockedUserId,
  }) async {
    try {
      final blockId = '${blockerId}_$blockedUserId';

      final block = BlockedUserModel(
        blockId: blockId,
        blockerId: blockerId,
        blockedUserId: blockedUserId,
        blockedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(blockerId)
          .collection('blockedUsers')
          .doc(blockId)
          .set(block.toMap());
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  // Unblock a user
  Future<void> unblockUser({
    required String blockerId,
    required String blockedUserId,
  }) async {
    try {
      final blockId = '${blockerId}_$blockedUserId';

      await _firestore
          .collection('users')
          .doc(blockerId)
          .collection('blockedUsers')
          .doc(blockId)
          .delete();
    } catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }

  // Check if a user is blocked
  Future<bool> isUserBlocked({
    required String blockerId,
    required String blockedUserId,
  }) async {
    try {
      final blockId = '${blockerId}_$blockedUserId';

      final doc = await _firestore
          .collection('users')
          .doc(blockerId)
          .collection('blockedUsers')
          .doc(blockId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get all blocked users for a user
  Future<List<BlockedUserModel>> getBlockedUsers(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('blockedUsers')
          .get();

      return snapshot.docs
          .map((doc) => BlockedUserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get blocked users: $e');
    }
  }

  // Get all reports (for admin/moderation)
  Stream<List<ReportModel>> getReportsStream({String? status}) {
    Query query = _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Update report status (for moderation)
  Future<void> updateReportStatus({
    required String reportId,
    required String status,
  }) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update report status: $e');
    }
  }

  // Delete a report
  Future<void> deleteReport(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).delete();
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }
}
