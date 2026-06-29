import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/workout_model.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Workout workout;

  const ActiveWorkoutScreen({
    super.key,
    required this.workout,
  });

  @override
  State<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState
    extends State<ActiveWorkoutScreen> {

  int currentIndex = 0;
  int remainingSeconds = 0;
  int totalPhaseSeconds = 0;
  bool isResting = false;
  Timer? timer;

  double caloriesBurned = 0;

  final AudioPlayer player = AudioPlayer();

  WorkoutExercise get currentExercise =>
      widget.workout.exercises[currentIndex];

  @override
  void initState() {
    super.initState();
    startExercise();
  }

  //////////////////////////////////////////////////////
  /// START EXERCISE
  //////////////////////////////////////////////////////

  void startExercise() {
    setState(() {
      isResting = false;
      remainingSeconds = currentExercise.duration;
      totalPhaseSeconds = currentExercise.duration;
    });

    startTimer();
  }

  //////////////////////////////////////////////////////
  /// START REST
  //////////////////////////////////////////////////////

  void startRest() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 300);
    }

    setState(() {
      isResting = true;
      remainingSeconds = currentExercise.rest;
      totalPhaseSeconds = currentExercise.rest;
    });

    startTimer();
  }

  //////////////////////////////////////////////////////
  /// TIMER
  //////////////////////////////////////////////////////

  void startTimer() {
    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) {
        if (remainingSeconds > 0) {
          setState(() {
            remainingSeconds--;

            if (!isResting) {
              caloriesBurned += 0.12; // basic estimation
            }
          });
        } else {
          timer?.cancel();
          playBeep();
          nextStep();
        }
      },
    );
  }

  //////////////////////////////////////////////////////
  /// PLAY SOUND
  //////////////////////////////////////////////////////

  void playBeep() async {
    await player.play(
      AssetSource("sounds/beep.mp3"),
    );
  }

  //////////////////////////////////////////////////////
  /// NEXT STEP
  //////////////////////////////////////////////////////

  void nextStep() {
    if (!isResting) {
      if (currentExercise.rest > 0) {
        startRest();
      } else {
        moveToNextExercise();
      }
    } else {
      moveToNextExercise();
    }
  }

  //////////////////////////////////////////////////////
  /// NEXT EXERCISE
  //////////////////////////////////////////////////////

  void moveToNextExercise() {
    if (currentIndex <
        widget.workout.exercises.length - 1) {
      setState(() {
        currentIndex++;
      });
      startExercise();
    } else {
      showCompletion();
    }
  }

  //////////////////////////////////////////////////////
  /// SAVE HISTORY
  //////////////////////////////////////////////////////

  Future<void> saveWorkoutHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("workoutHistory")
        .add({
      "workoutName": widget.workout.name,
      "date": Timestamp.now(),
      "caloriesBurned": caloriesBurned,
      "duration": widget.workout.estimatedTotalTime,
    });
  }

  //////////////////////////////////////////////////////
  /// COMPLETION
  //////////////////////////////////////////////////////

  void showCompletion() async {
    await saveWorkoutHistory();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F26),
        title: const Text(
          "Workout Completed 🎉",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Calories Burned: ${caloriesBurned.toStringAsFixed(1)} kcal",
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              "Done",
              style: TextStyle(color: Color(0xFFFFD700)),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    player.dispose();
    super.dispose();
  }

  //////////////////////////////////////////////////////
  /// UI
  //////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    double progress = totalPhaseSeconds == 0
        ? 0
        : remainingSeconds / totalPhaseSeconds;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      body: SafeArea(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            //////////////////////////////////////////////////////
            /// EXERCISE GIF
            //////////////////////////////////////////////////////

            if (!isResting)
              Image.asset(
                "assets/exercises/${currentExercise.exerciseId}.gif",
                height: 200,
              )
            else
              const Icon(
                Icons.hotel,
                size: 120,
                color: Color(0xFFFFD700),
              ),

            const SizedBox(height: 30),

            //////////////////////////////////////////////////////
            /// TITLE
            //////////////////////////////////////////////////////

            Text(
              isResting
                  ? "REST"
                  : currentExercise.exerciseId
                      .replaceAll("_", " ")
                      .toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            //////////////////////////////////////////////////////
            /// TIMER + PROGRESS
            //////////////////////////////////////////////////////

            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade800,
                    valueColor:
                        const AlwaysStoppedAnimation(
                      Color(0xFFFFD700),
                    ),
                  ),
                  Text(
                    "$remainingSeconds",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "Calories: ${caloriesBurned.toStringAsFixed(1)} kcal",
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}