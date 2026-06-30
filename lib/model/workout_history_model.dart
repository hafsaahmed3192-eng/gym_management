import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutHistory {
  final String id;
  final String workoutName;
  final double caloriesBurned;
  final int duration; // seconds
  final DateTime date;

  WorkoutHistory({
    required this.id,
    required this.workoutName,
    required this.caloriesBurned,
    required this.duration,
    required this.date,
  });

  factory WorkoutHistory.fromFirestore(
      String id, Map<String, dynamic> data) {
    return WorkoutHistory(
      id: id,
      workoutName: data['workoutName'] ?? '',
      caloriesBurned:
          (data['caloriesBurned'] ?? 0).toDouble(),
      duration: (data['duration'] ?? 0).toInt(),
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'workoutName': workoutName,
      'caloriesBurned': caloriesBurned,
      'duration': duration,
      'date': Timestamp.fromDate(date),
    };
  }
}