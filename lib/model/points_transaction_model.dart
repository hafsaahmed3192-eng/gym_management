import 'package:cloud_firestore/cloud_firestore.dart';

class PointsTransaction {
  final String id;
  final String type;        // "earned" | "redeemed"
  final String reason;      // "app_referral" | "gym_referral" | "welcome_bonus" | "redemption"
  final int points;
  final String description;
  final DateTime createdAt;

  PointsTransaction({
    required this.id,
    required this.type,
    required this.reason,
    required this.points,
    required this.description,
    required this.createdAt,
  });

  factory PointsTransaction.fromFirestore(
      String id, Map<String, dynamic> data) {
    return PointsTransaction(
      id: id,
      type: data['type'] ?? 'earned',
      reason: data['reason'] ?? '',
      points: (data['points'] ?? 0).toInt(),
      description: data['description'] ?? '',
      createdAt:
          (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'reason': reason,
      'points': points,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}