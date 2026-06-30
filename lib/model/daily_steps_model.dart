import 'package:cloud_firestore/cloud_firestore.dart';

/// Average stride length in meters, used to estimate distance
/// from step count. ~0.762m (30 inches) is a common average
/// adult stride length used by most fitness apps.
const double averageStrideLengthMeters = 0.762;

/// Estimated calories burned per step (rough average).
/// Real apps vary this by weight; this is a simple flat estimate.
const double caloriesPerStep = 0.04;

class DailySteps {
  final String dateKey; // format: "2026-06-30"
  final int steps;
  final DateTime lastUpdated;

  DailySteps({
    required this.dateKey,
    required this.steps,
    required this.lastUpdated,
  });

  double get distanceMeters =>
      steps * averageStrideLengthMeters;

  double get distanceKm => distanceMeters / 1000;

  double get caloriesBurned => steps * caloriesPerStep;

  factory DailySteps.fromFirestore(
      String id, Map<String, dynamic> data) {
    return DailySteps(
      dateKey: id,
      steps: (data['steps'] ?? 0).toInt(),
      lastUpdated:
          (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'steps': steps,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  factory DailySteps.empty(String dateKey) => DailySteps(
        dateKey: dateKey,
        steps: 0,
        lastUpdated: DateTime.now(),
      );
}