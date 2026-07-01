import 'package:cloud_firestore/cloud_firestore.dart';

class Referral {
  final String id;
  final String type;          // "app" | "gym"
  final String referredName;
  final String? referredPhone; // gym referrals only
  final String status;        // "pending" | "verified" | "rejected"
  final int pointsAwarded;
  final DateTime createdAt;

  Referral({
    required this.id,
    required this.type,
    required this.referredName,
    this.referredPhone,
    required this.status,
    required this.pointsAwarded,
    required this.createdAt,
  });

  factory Referral.fromFirestore(
      String id, Map<String, dynamic> data) {
    return Referral(
      id: id,
      type: data['type'] ?? 'app',
      referredName: data['referredName'] ?? '',
      referredPhone: data['referredPhone'],
      status: data['status'] ?? 'pending',
      pointsAwarded:
          (data['pointsAwarded'] ?? 0).toInt(),
      createdAt:
          (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'referredName': referredName,
      if (referredPhone != null)
        'referredPhone': referredPhone,
      'status': status,
      'pointsAwarded': pointsAwarded,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}