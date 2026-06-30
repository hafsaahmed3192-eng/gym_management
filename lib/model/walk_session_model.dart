import 'package:cloud_firestore/cloud_firestore.dart';

class WalkSession {
  final String id;
  final double distanceMeters;
  final int durationSeconds;
  final double caloriesBurned;
  final DateTime date;
  final List<Map<String, double>> routePoints; // [{lat, lng}, ...]

  WalkSession({
    required this.id,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.caloriesBurned,
    required this.date,
    required this.routePoints,
  });

  // Convenience getters
  double get distanceKm => distanceMeters / 1000;

  factory WalkSession.fromFirestore(
      String id, Map<String, dynamic> data) {
    final rawPoints =
        (data['routePoints'] as List<dynamic>?) ?? [];

    return WalkSession(
      id: id,
      distanceMeters:
          (data['distanceMeters'] ?? 0).toDouble(),
      durationSeconds:
          (data['durationSeconds'] ?? 0).toInt(),
      caloriesBurned:
          (data['caloriesBurned'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      routePoints: rawPoints
          .map((p) => {
                'lat': (p['lat'] as num).toDouble(),
                'lng': (p['lng'] as num).toDouble(),
              })
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'distanceMeters': distanceMeters,
      'durationSeconds': durationSeconds,
      'caloriesBurned': caloriesBurned,
      'date': Timestamp.fromDate(date),
      'routePoints': routePoints,
    };
  }
}