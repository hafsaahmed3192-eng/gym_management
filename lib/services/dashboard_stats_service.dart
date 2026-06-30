import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/daily_steps_model.dart';

class DashboardStats {
  final int exercisesToday;
  final double caloriesBurnedToday;
  final int stepsToday;
  final double distanceWalkedTodayKm;

  DashboardStats({
    required this.exercisesToday,
    required this.caloriesBurnedToday,
    required this.stepsToday,
    required this.distanceWalkedTodayKm,
  });

  factory DashboardStats.empty() => DashboardStats(
        exercisesToday: 0,
        caloriesBurnedToday: 0,
        stepsToday: 0,
        distanceWalkedTodayKm: 0,
      );
}

class DashboardStatsService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  ({DateTime start, DateTime end}) _todayRange() {
    final now = DateTime.now();
    final start =
        DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (start: start, end: end);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  //////////////////////////////////////////////////////
  /// ONE-TIME FETCH
  //////////////////////////////////////////////////////

  Future<DashboardStats> fetchTodayStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return DashboardStats.empty();

    final range = _todayRange();

    // ── Workout exercises + calories for today ──
    final workoutSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('workoutHistory')
        .where('date',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(range.start))
        .where('date',
            isLessThan: Timestamp.fromDate(range.end))
        .get();

    int exerciseCount = workoutSnapshot.docs.length;
    double workoutCalories = 0;
    for (final doc in workoutSnapshot.docs) {
      workoutCalories +=
          (doc.data()['caloriesBurned'] ?? 0).toDouble();
    }

    // ── Today's step count (single doc, not a range query) ──
    final stepsDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('dailySteps')
        .doc(_todayKey())
        .get();

    final dailySteps = stepsDoc.exists
        ? DailySteps.fromFirestore(
            stepsDoc.id, stepsDoc.data()!)
        : DailySteps.empty(_todayKey());

    return DashboardStats(
      exercisesToday: exerciseCount,
      caloriesBurnedToday:
          workoutCalories + dailySteps.caloriesBurned,
      stepsToday: dailySteps.steps,
      distanceWalkedTodayKm: dailySteps.distanceKm,
    );
  }

  //////////////////////////////////////////////////////
  /// LIVE STREAM — combines workoutHistory snapshots
  /// with the dailySteps doc, both for today.
  //////////////////////////////////////////////////////

  Stream<DashboardStats> watchTodayStats() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value(DashboardStats.empty());
    }

    final range = _todayRange();

    final workoutStream = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('workoutHistory')
        .where('date',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(range.start))
        .where('date',
            isLessThan: Timestamp.fromDate(range.end))
        .snapshots();

    final stepsStream = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('dailySteps')
        .doc(_todayKey())
        .snapshots();

    // Combine both streams into one DashboardStats stream.
    // Using a simple manual merge since both streams are
    // independent and we want the latest of each.
    late DashboardStats latest;
    latest = DashboardStats.empty();

    final controller =
        StreamController<DashboardStats>.broadcast();

    int exerciseCount = 0;
    double workoutCalories = 0;
    int steps = 0;
    double stepsCalories = 0;
    double distanceKm = 0;

    void emit() {
      latest = DashboardStats(
        exercisesToday: exerciseCount,
        caloriesBurnedToday:
            workoutCalories + stepsCalories,
        stepsToday: steps,
        distanceWalkedTodayKm: distanceKm,
      );
      controller.add(latest);
    }

    final sub1 = workoutStream.listen((snap) {
      exerciseCount = snap.docs.length;
      workoutCalories = 0;
      for (final doc in snap.docs) {
        workoutCalories +=
            (doc.data()['caloriesBurned'] ?? 0)
                .toDouble();
      }
      emit();
    });

    final sub2 = stepsStream.listen((doc) {
      if (doc.exists) {
        final daily = DailySteps.fromFirestore(
            doc.id, doc.data()!);
        steps = daily.steps;
        stepsCalories = daily.caloriesBurned;
        distanceKm = daily.distanceKm;
      } else {
        steps = 0;
        stepsCalories = 0;
        distanceKm = 0;
      }
      emit();
    });

    controller.onCancel = () {
      sub1.cancel();
      sub2.cancel();
    };

    return controller.stream;
  }
}