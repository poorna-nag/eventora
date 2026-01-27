class ReportModel {
  final String reportId;
  final String reporterId;
  final String reporterName;
  final String reportedUserId;
  final String? reportedEventId;
  final String reportType; // 'user', 'event', 'content'
  final String reason;
  final String description;
  final DateTime createdAt;
  final String status; // 'pending', 'reviewed', 'resolved', 'dismissed'

  ReportModel({
    required this.reportId,
    required this.reporterId,
    required this.reporterName,
    required this.reportedUserId,
    this.reportedEventId,
    required this.reportType,
    required this.reason,
    required this.description,
    required this.createdAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reportedUserId': reportedUserId,
      'reportedEventId': reportedEventId,
      'reportType': reportType,
      'reason': reason,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      reportId: map['reportId'] ?? '',
      reporterId: map['reporterId'] ?? '',
      reporterName: map['reporterName'] ?? '',
      reportedUserId: map['reportedUserId'] ?? '',
      reportedEventId: map['reportedEventId'],
      reportType: map['reportType'] ?? 'user',
      reason: map['reason'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      status: map['status'] ?? 'pending',
    );
  }
}

class BlockedUserModel {
  final String blockId;
  final String blockerId;
  final String blockedUserId;
  final DateTime blockedAt;

  BlockedUserModel({
    required this.blockId,
    required this.blockerId,
    required this.blockedUserId,
    required this.blockedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'blockId': blockId,
      'blockerId': blockerId,
      'blockedUserId': blockedUserId,
      'blockedAt': blockedAt.toIso8601String(),
    };
  }

  factory BlockedUserModel.fromMap(Map<String, dynamic> map) {
    return BlockedUserModel(
      blockId: map['blockId'] ?? '',
      blockerId: map['blockerId'] ?? '',
      blockedUserId: map['blockedUserId'] ?? '',
      blockedAt: DateTime.parse(map['blockedAt']),
    );
  }
}
